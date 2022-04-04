defmodule FomosWeb.SubscriptionController do
  @base_url "https://accounts.spotify.com"
  @authorize_url "#{@base_url}/authorize"
  @token_url "#{@base_url}/api/token"
  @scopes "user-read-private user-library-read"

  use FomosWeb, :controller

  @spec subscribe(Plug.Conn.t(), any) :: Plug.Conn.t()
  def subscribe(conn, _params) do
    client_id = Application.fetch_env!(:fomos, :spotify_app_client_id)
    callback_url = Routes.subscription_url(conn, :callback)

    url =
      "#{@authorize_url}?response_type=code&client_id=#{client_id}&scope=#{@scopes}&redirect_uri=#{callback_url}"

    redirect(conn, external: url)
  end

  @spec callback(Plug.Conn.t(), any) :: Plug.Conn.t()
  def callback(conn, %{"code" => code}) do
    client_id = Application.fetch_env!(:fomos, :spotify_app_client_id)
    secret = Application.fetch_env!(:fomos, :spotify_app_secret)

    basic_auth = Base.encode64("#{client_id}:#{secret}")

    headers = [
      {"Authorization", "Basic #{basic_auth}"},
      {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}
    ]

    payload = %{
      "grant_type" => "authorization_code",
      "redirect_uri" => Routes.subscription_url(conn, :callback),
      "code" => code
    }

    request_body = URI.encode_query(payload)

    {_, %{:body => body}} =
      HTTPoison.post(
        @token_url,
        request_body,
        headers
      )

    text(conn, body)
  end
end
