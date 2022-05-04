defmodule Episode.SpotifyApiClient do
  def get_episodes_by_show_id(authorization, show_id) do
    url = "#{Spotify_API.api_url()}/shows/#{show_id}/episodes"
    transform = fn r -> Enum.map(r, episode_main_info_factory(show_id)) end
    Spotify_API.fetch_all(url, authorization, transform)
  end

  def get_episodes_by_show_id(authorization, show_id, offset, limit) do
    url = "#{Spotify_API.api_url()}/shows/#{show_id}/episodes"
    transform = fn r -> Enum.map(r, episode_main_info_factory(show_id)) end
    Spotify_API.fetch(url, authorization, offset, limit, transform)
  end

  def get_episodes_and_total_by_show_id(authorization, show_id, offset, limit) do
    url = "#{Spotify_API.api_url()}/shows/#{show_id}/episodes"

    Spotify_API.fetch(url, authorization, offset, limit)
    |> episodes_main_info_and_total_factory(show_id).()
  end

  defp episode_main_info_factory(show_id) do
    fn episode ->
      %{
        release_date: episode["release_date"],
        name: episode["name"],
        show_id: show_id,
        id: episode["id"],
        uri: episode["uri"],
        duration: ceil(episode["duration_ms"] / 60_000)
      }
    end
  end

  defp episodes_main_info_and_total_factory(show_id) do
    fn response ->
      episodes =
        response
        |> Spotify_API.pick_items()
        |> Enum.map(episode_main_info_factory(show_id))

      %{
        episodes: episodes,
        total: response |> Spotify_API.pick_total()
      }
    end
  end
end
