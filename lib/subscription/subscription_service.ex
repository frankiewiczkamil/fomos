defmodule Subscription do
  require Logger

  defp pick_id(%{:id => id}), do: id

  @spec subscribe(String.t()) :: any
  def subscribe(authorization) do
    shows = Spotify_API.get_shows(authorization)

    Logger.debug(length(shows))
    %{"id" => user_id} = Spotify_API.get_user_info(authorization)

    show_ids = shows |> Enum.map(&pick_id/1)
    subscriber = {user_id, show_ids}

    %{user_id: user_id, showz: show_ids}
  end
end
