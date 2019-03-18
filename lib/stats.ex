defmodule Stats do
  @moduledoc false

  @enforce_keys [:team]
  defstruct team: nil, matches: 0, victories: 0, draws: 0

  @type t(team) :: %Stats{team: team}
  @type t :: %Stats{team: integer, matches: integer, victories: integer, draws: integer}

  def add_match(stats, victory, draw) do
    %{stats |
      matches: stats.matches + 1,
      victories: stats.victories + (if victory, do: 1, else: 0),
      draws: stats.draws + (if draw, do: 1, else: 0)
    }
  end

end
