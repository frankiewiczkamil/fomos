defmodule Subscription.Service do
  require Logger

  defp pick_id(%{:id => id}), do: id

  def subscribe(token_response) do
    authorization = "#{token_response["token_type"]} #{token_response["access_token"]}"
    shows = Subscribtion.UserSpotifyApiClient.get_user_shows(authorization)

    %{"id" => user_id} = Subscribtion.UserSpotifyApiClient.get_user_info(authorization)

    show_ids = shows |> Enum.map(&pick_id/1)
    Subscription.Repo.store(user_id, show_ids)
    Subscribtion.Token.Repo.save(user_id, token_response)

    # todo add sending msg to requester, so it fires tracking shows that are currently not tracked
    spawn(fn -> refresh_token(user_id) end)
    %{user_id: user_id, showz: show_ids}
  end

  def refresh_token(user_id) do
    %{"refresh_token" => refresh_token, "expires_in" => expires_in} =
      Subscribtion.Token.Repo.get(user_id)

    Process.sleep(3 * 1_000)
    # tkn = Subscribtion.Token.Repo.get(user_id)
    # Logger.debug("refresh token for user: #{user_id} #{refresh_token}")
    token_response = Auth.Code.fetch_token(refresh_token)

    Subscribtion.Token.Repo.save(
      user_id,
      Map.put(token_response, "refresh_token", refresh_token)
    )

    # Logger.debug("response: ")
    # IO.inspect(token_response)
    refresh_token(user_id)
  end
end
