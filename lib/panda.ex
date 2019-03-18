defmodule Panda do
  @moduledoc """
  Panda is a test program for Pandascore interview process.
  This module implements the following required methods:
    - upcoming_matches
    - odds_for_match
  """

  require Logger

  @upcoming_fields ~w(begin_at id name)

  @doc """
  Get a list of upcoming matches.
  There is two parameters:
    - page: page number of results (default 1)
    - per_page: number of matches per page (default 5)

  Return a list of Map that includes:
    - begin_at: match start date
    - id: match identifier
    - name: match name
  """
  def upcoming_matches(page \\ 1, per_page \\ 5) do
    Logger.info "retrieving upcoming [#{per_page}] matches starting at [#{page}]"
    try do
      for match <- Api.get!("/matches/upcoming?page=#{page}&per_page=#{per_page}").body do
        Map.take(match, @upcoming_fields)
      end
    rescue
       e -> "Oops, something get wrong while get upcoming matches: got [#{elem(e.term, 0)}] reason [#{elem(e.term, 1)}]"
    end
  end

  @doc """
  return odds for the given match.
  """
  def odds_for_match(match_id) do
    Logger.info "getting odds for the match #{match_id}"
    {winner, teams} = get_match_opponents(match_id)
    if winner == nil do
      Odds.compute(teams)
    else
      Odds.compute_with_winner(teams, winner)
    end

  end

  defp get_match_opponents(match_id) do
    match = Api.get!("/matches/#{match_id}").body

    game = Enum.at(match["games"], 0)
    opponents = match["opponents"]

    {
      game["winner"]["id"],
      for opponent <- opponents do
        Team.new(opponent["opponent"]["name"], opponent["opponent"]["id"])
      end
    }
  end

end
