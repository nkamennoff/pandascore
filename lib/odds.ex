defmodule Odds do
  @moduledoc false

  def compute_with_winner(teams, winner) do
    for team <- teams, into: %{} do
      if team.id == winner do
        {team.name, 100}
      else
        {team.name, 0}
      end
    end
  end
end
