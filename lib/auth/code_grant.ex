defmodule Auth.Code do
  @base_url "https://accounts.spotify.com"
  @authorize_url "#{@base_url}/authorize"
  @scopes "user-read-private user-library-read"
  @token_url "#{@base_url}/api/token"

  def create_redirect_url(callback_url) do
    client_id = Application.fetch_env!(:fomos, :spotify_app_client_id)

    "#{@authorize_url}?response_type=code&client_id=#{client_id}&scope=#{@scopes}&redirect_uri=#{callback_url}"
  end

  def fetch_token(code, redirect_url) do
    client_id = Application.fetch_env!(:fomos, :spotify_app_client_id)
    secret = Application.fetch_env!(:fomos, :spotify_app_secret)

    basic_auth = Base.encode64("#{client_id}:#{secret}")

    headers = [
      {"Authorization", "Basic #{basic_auth}"},
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}
    ]

    payload = %{
      "grant_type" => "authorization_code",
      "redirect_uri" => redirect_url,
      "code" => code
    }

    request_body = URI.encode_query(payload)

    # todo handle error scenario

    result =
      HTTPoison.post(
        @token_url,
        request_body,
        headers
      )
      |> pick_body()
      |> Jason.decode!()

    IO.inspect(result)
    result
  end

  defp pick_body({_, %{:body => body}}), do: body
end
