defmodule FomosWeb.SubscriptionController do
  use FomosWeb, :controller

  @spec subscribe(Plug.Conn.t(), any) :: Plug.Conn.t()
  def subscribe(conn, _params) do
    callback_url = Routes.subscription_url(conn, :callback)
    redirect_to_spotify_url = Auth.Code.create_redirect_url(callback_url)

    redirect(conn, external: redirect_to_spotify_url)
  end

  @spec callback(Plug.Conn.t(), any) :: Plug.Conn.t()
  def callback(conn, %{"code" => code}) do
    callback_url = Routes.subscription_url(conn, :callback)

    result = Auth.Code.fetch_token(code, callback_url)

    authorization = "#{result["token_type"]} #{result["access_token"]}"
    result = Subscription.Service.subscribe(authorization)

    json(conn, result)
  end
end
