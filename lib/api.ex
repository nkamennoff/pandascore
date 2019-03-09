defmodule Api do
  @moduledoc """

  """

  use HTTPoison.Base
  require Logger

  @endpoint "https://api.pandascore.co"

  def process_url(url) do
    Logger.debug "Querying panda api: GET [#{url}] using token [#{get_token()}]"
    separator = if String.contains?(url, "?"), do: "&token=", else: "?token="
    @endpoint <> url <> separator <> get_token()
  end

  def process_response_body(body) do
    Poison.decode! body
  end

  defp get_token() do
    unless System.get_env("TOKEN") do
      exit "No TOKEN in environment variables, usage: TOKEN=<your panda token> iex -S mix"
    end
    System.get_env("TOKEN")
  end
end
