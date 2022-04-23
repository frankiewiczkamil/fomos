defmodule FomosWeb.SubscriptionController do
  use FomosWeb, :controller

  # todo decide what is the relation between subscribing and obtaining a token
  # it seems it would be best to create auth service that will take care of storing data and (maybe) refreshing the token

  @spec subscribe(Plug.Conn.t(), any) :: Plug.Conn.t()
  def subscribe(conn, _params) do
    callback_url = Routes.subscription_url(conn, :callback)
    redirect_to_spotify_url = Auth.Code.create_redirect_url(callback_url)

    redirect(conn, external: redirect_to_spotify_url)
  end

  @spec callback(Plug.Conn.t(), any) :: Plug.Conn.t()
  def callback(conn, %{"code" => code}) do
    callback_url = Routes.subscription_url(conn, :callback)

    token_response = Auth.Code.fetch_token(code, callback_url)

    result = Subscription.Service.subscribe(token_response)

    json(conn, result)
  end
end
