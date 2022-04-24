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

    Process.sleep(expires_in * 1_000)
    Logger.debug("refresh token for user: #{user_id}")
    token_metadata = case token_response = Auth.Code.fetch_token(refresh_token) do
      %{"refresh_token" => _} -> token_response
      _ -> Map.put(token_response, "refresh_token", refresh_token)
    end

    Subscribtion.Token.Repo.save(user_id, token_metadata)

    refresh_token(user_id)
  end
end
