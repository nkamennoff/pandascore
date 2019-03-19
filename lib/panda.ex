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
  @spec upcoming_matches(integer, integer) :: List.t
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
  @spec odds_for_match(integer) :: %{String => number, String => number}
  def odds_for_match(match_id) do
    try do
      case :ets.lookup(:odds, match_id) do
        [{^match_id, odds}] -> odds
        [] ->
          match = Api.get!("/matches/#{match_id}").body
          Logger.info "getting odds for the match #{match_id}: #{match["name"]}"
          teams = get_match_opponents(match)
          odds = if match["winner_id"] == nil do
            Odds.compute(teams)
          else
            Odds.compute_with_winner(teams, match["winner_id"])
          end
          :ets.insert(:odds, {match_id, odds})
          odds
      end
    rescue
      _ in ArgumentError -> :ets.new(:odds, [:named_table, :set]); odds_for_match(match_id)
    end
  end

#  @doc """
#  get opponents of a given match as Team structures
#
#  input: match map
#  output: list of teams
#  """
  @spec get_match_opponents(Map) :: List
  defp get_match_opponents(match) do
    for opponent <- match["opponents"] do
      %Team{name: opponent["opponent"]["name"], id: opponent["opponent"]["id"]}
    end
  end

end
