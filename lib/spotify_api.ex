defmodule Spotify_API do
  # dev mode only, tmp
  @api "https://api.spotify.com/v1"
  @headers [Authorization: "Bearer #{Auth.get_dev_token()}"]

  @type main_info :: %{
          id: String.t(),
          name: String.t()
        }

  defp pick_body(%{body: body}), do: body
  defp pick_items(%{"items" => items}), do: items
  defp pick_show(%{"show" => show}), do: show
  defp show_main_info(%{"id" => id, "name" => name}), do: %{id: id, name: name}

  defp episode_main_info(%{"release_date" => release_date, "name" => name}) do
    %{release_date: release_date, name: name}
  end

  @spec get_my_shows() :: [main_info]
  def get_my_shows() do
    HTTPoison.get!("#{@api}/me/shows", @headers)
    |> pick_body()
    |> Jason.decode!()
    |> pick_items()
    |> Enum.map(&pick_show/1)
    |> Enum.map(&show_main_info/1)
  end

  def get_episodes_by_show_id(show_id) do
    HTTPoison.get!("#{@api}/shows/#{show_id}/episodes", @headers)
    |> pick_body()
    |> Jason.decode!()
    |> pick_items()
    |> Enum.map(&episode_main_info/1)
  end
end
