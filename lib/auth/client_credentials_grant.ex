defmodule Auth.ClientCredentials do
  @base_url "https://accounts.spotify.com"
  @token_url "#{@base_url}/api/token"

  # todo cleanup all the auth stuff

  def get_auth_header do
    client_id = Application.fetch_env!(:fomos, :spotify_app_client_id)
    secret = Application.fetch_env!(:fomos, :spotify_app_secret)
    basic_auth = Base.encode64("#{client_id}:#{secret}")

    headers = [
      {"Authorization", "Basic #{basic_auth}"},
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}
    ]

    payload = %{
      "grant_type" => "client_credentials"
    }

    request_body = URI.encode_query(payload)

    # todo handle not error scenario
    result =
      HTTPoison.post(
        @token_url,
        request_body,
        headers
      )
      |> pick_body
      |> Jason.decode!()

    "#{result["token_type"]} #{result["access_token"]}"
  end

  defp pick_body({_, %{:body => body}}), do: body
end
