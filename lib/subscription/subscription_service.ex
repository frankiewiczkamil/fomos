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

    %{user_id: user_id, showz: show_ids}
  end
end
