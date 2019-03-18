defmodule Stats do
  @moduledoc """
  presents a stats structure to count match history for a team (number of loss / draw and total number of matches)
  also present a method to add a match to the stat and a method to compute winning probabilities based on a stats structure.
  """

  @enforce_keys [:team]
  defstruct team: nil, matches: 0, victories: 0, draws: 0

  @type t(team) :: %Stats{team: team}
  @type t :: %Stats{team: integer, matches: integer, victories: integer, draws: integer}

  @doc """
  Add information about a new match in a stat structure

  inputs:
  - stats: Stats structure to update
  - victory: boolean, does team as won ?
  - draw: boolean, does match ended with a draw

  ouput: updated Stats structure
  """
  @spec add_match(Stats.t, boolean, boolean) :: Stats.t
  def add_match(stats, victory, draw) do
    %{stats |
      matches: stats.matches + 1,
      victories: stats.victories + (if victory, do: 1, else: 0),
      draws: stats.draws + (if draw, do: 1, else: 0)
    }
  end

  @doc """
  compute winning probabilities of a given Stats structure.
  input: Stats structure to compute
  output: winning probabilities based on the given Stats structure
  if there is no match (or all are draws) then return 0.5
  """
  @spec probabilites!(Stats.t) :: number
  def probabilites!(stats) do
    total = stats.matches - stats.draws
    if total != 0 do
      (stats.victories / total)
    else
      0.5
    end
  end



end
