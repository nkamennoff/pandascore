defmodule Team do
  @moduledoc """
  Structure to gather team information (and a test to see how structures works in Elixir.
  """

  defstruct name: nil, id: nil

  @type t(name, id) :: %Team{name: name, id: id}

  @type t :: %Team{name: String.t, id: integer}

  defimpl String.Chars, for: Team do
    def to_string(team) do
      "#{team.name}"
    end
  end
end
