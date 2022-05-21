defmodule Episode.SpotifyApiClient do
  @type episode_response :: %{
          items: list(Episode.Model.episode())
        }
  @type episodes_and_total :: %{
          episodes: list(Episode.Model.episode()),
          total: number()
        }

  @spec get_episodes_by_show_id(String.t(), String.t()) :: episode_response
  def get_episodes_by_show_id(authorization, show_id) do
    url = "#{Spotify_API.api_url()}/shows/#{show_id}/episodes"
    transform = fn r -> Enum.map(r, episode_main_info_factory(show_id)) end
    Spotify_API.fetch_all(url, authorization, transform)
  end

  @spec get_episodes_by_show_id(String.t(), String.t(), number(), number()) :: episode_response
  def get_episodes_by_show_id(authorization, show_id, offset, limit) do
    url = "#{Spotify_API.api_url()}/shows/#{show_id}/episodes"
    transform = fn r -> Enum.map(r, episode_main_info_factory(show_id)) end
    Spotify_API.fetch(url, authorization, offset, limit, transform)
  end

  @spec get_episodes_and_total_by_show_id(String.t(), String.t(), number(), number()) ::
          episodes_and_total()
  def get_episodes_and_total_by_show_id(authorization, show_id, offset, limit) do
    url = "#{Spotify_API.api_url()}/shows/#{show_id}/episodes"

    Spotify_API.fetch(url, authorization, offset, limit)
    |> episodes_main_info_and_total_factory(show_id).()
  end

  @spec episode_main_info_factory(String.t()) ::
          (Episode.Model.spotify_episode() -> Episode.Model.episode())
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

  @spec episodes_main_info_and_total_factory(String.t()) ::
          (episode_response -> episodes_and_total())
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
