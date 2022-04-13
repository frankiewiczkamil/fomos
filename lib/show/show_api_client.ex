defmodule Show.SpotifyApiClient do
  @type show_main_info :: %{
          id: String.t(),
          name: String.t(),
          total_episodes: number()
        }

  @spec get_show(String.t(), String.t()) :: show_main_info
  def(get_show(authorization, id)) do
    url = "#{Spotify_API.api_url()}/shows?ids=#{id}"

    Spotify_API.fetch(url, authorization)
    |> pick_shows()
    |> List.first()
    |> pick_show_main_info()
  end

  def pick_shows(%{"shows" => shows}), do: shows
  def pick_show(%{"show" => show}), do: show

  def pick_show_main_info(%{"id" => id, "name" => name, "total_episodes" => total_episodes}) do
    %{id: id, name: name, total_episodes: total_episodes}
  end
end
