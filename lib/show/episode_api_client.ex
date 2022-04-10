defmodule Episode.SpotifyApiClient do
  @spec get_episodes_by_show_id(String.t(), String.t()) :: list
  def get_episodes_by_show_id(authorization, show_id) do
    url = "#{Spotify_API.api_url()}/shows/#{show_id}/episodes"
    transform = fn r -> Enum.map(r, &episode_main_info/1) end
    Spotify_API.fetch_all(url, authorization, transform)
  end

  defp episode_main_info(%{"release_date" => release_date, "name" => name}) do
    %{release_date: release_date, name: name}
  end
end
