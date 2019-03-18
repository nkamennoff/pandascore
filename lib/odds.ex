defmodule Odds do
  @moduledoc """
  A basic toolbox to compute odds for a given match.
  Module presents two public methods:
  - compute_with_winner: for matches that are already finished
  - compute: for matches that are still to come
  """

  require Logger

  @doc """
  The match has already ended, thus the winner has 100% chances to win the match.
  Note that we could have compute the odds prior to the match, but I am a bit lazy right now.
  """
  @spec compute_with_winner(List.t, integer) :: %{String => number, String => number}
  def compute_with_winner(teams, winner) do
    for team <- teams, into: %{} do
      if team.id == winner do
        {team.name, 100}
      else
        {team.name, 0}
      end
    end
  end

  @doc """
  Compute the odds using bayesian inference:
  - compute historical victory ratio of team2 against team 1
  - compute historical victory ratio of team1
  - compute historical victory ratio of team2
  Compute belief using P(A|B)' = P(B|A)P(A) / P(B) (x 100 to get percentages)

  inputs: list with both teams (as Team)
  output: map with both team odds (team name => odds)
  """
  @spec compute(List) :: %{String => number, String => number}
  def compute(teams) do
    team1 = List.first(teams)
    team2 = List.last(teams)
    p_team1_wins_over_team2 = get_probabilities(team1.id, team2.id)
    Logger.debug "historical ratio of #{team1.name} over #{team2.name} is #{p_team1_wins_over_team2}"
    p_team2_wins_over_team1 = 1 - p_team1_wins_over_team2
    Logger.debug "historical ratio of #{team2.name} over #{team1.name} is #{p_team2_wins_over_team1}"
    p_team1 = get_probabilities(team1.id)
    Logger.debug "historical ratio of victories for #{team1.name} is #{p_team1}"
    p_team2 = get_probabilities(team2.id)
    Logger.debug "historical ratio of victories for #{team2.name} is #{p_team2}"
    if (p_team1_wins_over_team2 == 0) do
      team1_odds = p_team2_wins_over_team1 * p_team1 / p_team2 * 100
      %{team1.name => team1_odds, team2.name => 100 - team1_odds}
    else
      team2_odds = p_team1_wins_over_team2 * p_team2 / p_team1 * 100
      %{team1.name => 100 - team2_odds, team2.name => team2_odds}
    end
  end

#  @doc """
#  Gather team history and compute winning probabilities of team 1 (optionally against team 2)
#  """
  @spec get_probabilities(integer, integer) :: number
  defp get_probabilities(team1, team2 \\ nil) do
    Api.get!("/teams/#{team1}/matches?finished=true").body
    |> get_results(team1, team2)
    |> Stats.probabilites!
  end

#  @doc """
#  get stats from matches histories for a team and an optional opponent
#  list of mathes alternative
#
#  inputs:
#  - list of matches
#  - team id to consider
#  - opponent to consider (if nil, all opponent will be considered)
#  """
  @spec get_results(List, integer, integer) :: Stats.t
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

#  @doc """
#  get stats from matches histories for a team and an optional opponent
#  empty list of matches alternative
#  """
  @spec get_results(List, integer, integer) :: Stats.t
  defp get_results([], team_id, _) do
    %Stats{team: team_id}
  end

#  @doc """
#  is match is really done (either as a winner or declared draw)
#  input: match to check
#  output: boolean, true if match has a winner or is draw
#  """
  @spec done?(Map) :: boolean
  defp done?(game), do: game["draw"] or game["winner_id"] != nil

#  @doc """
#  is the team has won. Only use for readability purpose
#  input: winner id and team_id
#  ouput: true if team has won (winner == team_id)
#  """
  @spec winner?(integer, integer) :: boolean
  defp winner?(winner, team_id), do: winner == team_id

#  @doc """
#  define if match is to be considered
#  no opponent_id alternative
#  """
  @spec opponent?(List, nil) :: boolean
  defp opponent?(_opponents, nil), do: true

#  @doc """
#  define if match is to be considered
#  list of opponent with opponent_id alternative
#  """
  @spec opponent?(List, integer) :: boolean
  defp opponent?([opponent1 | opponents], opponent_id) do
    opponent1["opponent"]["id"] == opponent_id or opponent?(opponents, opponent_id)
  end

#  @doc """
#  define if match is to be considered
#  empty list of opponent alternative
#  """
  @spec opponent?(List, integer) :: boolean
  defp opponent?([], _opponent_id), do: false

end
