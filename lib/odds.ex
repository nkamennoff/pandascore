defmodule Odds do
  @moduledoc false

  require Logger

  def compute_with_winner(teams, winner) do
    for team <- teams, into: %{} do
      if team.id == winner do
        {team.name, 100}
      else
        {team.name, 0}
      end
    end
  end

  def compute(teams) do
    team1 = List.first(teams)
    team2 = List.last(teams)
    p_team2_wins_over_team1 = get_probabilities(team2.id, team1.id)
    Logger.debug "historical ratio of #{team2.name} over #{team1.name} is #{p_team2_wins_over_team1}"
    p_team1 = get_probabilities(team1.id, nil)
    Logger.debug "historical ratio of victories for #{team1.name} is #{p_team1}"
    p_team2 = get_probabilities(team2.id, nil)
    Logger.debug "historical ratio of victories for #{team2.name} is #{p_team2}"
    team1_odds = p_team2_wins_over_team1 * p_team1 / p_team2 * 100
    %{team1.name => team1_odds, team2.name => 100 - team1_odds}
  end

  defp get_probabilities(team1, team2) do
    Api.get!("/teams/#{team1}/matches?finished=true").body
    |> get_results(team1, team2)
    |> probabilites!
  end

  defp probabilites!(stats) do
    total = stats.matches - stats.draws
    if total != 0 do
      (stats.victories / total)
    else
      0.5
    end
  end

  defp get_results([head|tail], team_id, opponent_id) do
    Logger.debug "Checking match #{head["id"]}..."
    if opponent?(head["opponents"], opponent_id) do
      if done?(head) do
        Logger.debug "... get results"
        get_results(tail, team_id, opponent_id)
        |> Stats.add_match(winner?(head["winner_id"], team_id), head["draw"])
      else
        Logger.debug "... did not take place: #{head["status"]}"
        Logger.warn "match #{head["id"]} did not take place but considered finished with status: #{head["status"]}"
        get_results(tail, team_id, opponent_id)
      end
    else
      Logger.debug "... not the right opponent"
      get_results(tail, team_id, opponent_id)
    end
  end

  defp get_results([], team_id, _) do
    %Stats{team: team_id}
  end

  defp done?(game), do: game["draw"] or game["winner_id"] != nil

  defp winner?(winner, team_id), do: winner == team_id

  defp opponent?(_opponents, nil), do: true

  defp opponent?([opponent1 | opponents], opponent_id) do
    opponent1["opponent"]["id"] == opponent_id or opponent?(opponents, opponent_id)
  end

  defp opponent?([], _opponent_id), do: false

end
