defmodule Show.SpotifyApiClient do
  @spec get_show(String.t(), String.t()) :: Show.Model.mini()
  def(get_show(authorization, id)) do
    "#{Spotify_API.api_url()}/shows?ids=#{id}"
    |> Spotify_API.fetch(authorization)
    |> pick_shows()
    |> List.first()
    |> pick_show_main_info()
  end

  @spec pick_shows(%{shows: list(Spotify.Model.show())}) :: list(Spotify.Model.show())
  def pick_shows(%{"shows" => shows}), do: shows

  @spec pick_show(%{show: Spotify.Model.show()}) :: Spotify.Model.show()
  def pick_show(%{"show" => show}), do: show

  @spec pick_show_main_info(map) :: %{id: any, name: any, total_episodes: any}
  def pick_show_main_info(%{"id" => id, "name" => name, "total_episodes" => total_episodes}) do
    %{id: id, name: name, total_episodes: total_episodes}
  end
end
