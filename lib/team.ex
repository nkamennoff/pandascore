defmodule Team do
  @moduledoc false

  defstruct name: nil, id: nil

  @type t(name, id) :: %Team{name: name, id: id}

  @type t :: %Team{name: String.t, id: integer}

  def new(name, id) do
    %Team{name: name, id: id}
  end

  defimpl String.Chars, for: Team do
    def to_string(team) do
      "#{team.name}"
    end
  end
end
