defmodule Api do
  @moduledoc """

  """

  use HTTPoison.Base

  @endpoint "https://api.pandascore.co"

  def process_url(url) do
    @endpoint <> url
  end

  def process_response_body(body) do
    Poison.decode! body
  end

end
