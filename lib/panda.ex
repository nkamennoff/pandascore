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
    Logger.info "retrieving upcoming #{per_page} matches starting at #{page} with crendential #{get_token()}"
    try do
      for match <- Api.get!("/matches/upcoming?page=#{page}&per_page=#{per_page}&token=#{get_token()}").body do
        Map.take(match, @upcoming_fields)
      end
    rescue
       e -> "Oops, something get wrong while get upcoming matches: got [#{elem(e.term, 0)}] reason [#{elem(e.term, 1)}]"
    end
  end

  @doc """
  return odds for the given match
  """
  def odds_for_match(match) do
    "odds for the match #{match}"
  end

  defp get_token() do
    unless System.get_env("TOKEN") do
      exit "No TOKEN in environment variables, usage: TOKEN=<your panda token> iex -S mix"
    end
    System.get_env("TOKEN")
  end
end
