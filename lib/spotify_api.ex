defmodule Spotify_API do
  # dev mode only, tmp
  @api "https://api.spotify.com/v1"

  @type show_main_info :: %{
          id: String.t(),
          name: String.t()
        }

  defp pick_body(%{body: body}), do: body
  defp pick_items(%{"items" => items}), do: items
  defp pick_show(%{"show" => show}), do: show
  defp pick_show_main_info(%{"id" => id, "name" => name}), do: %{id: id, name: name}

  defp episode_main_info(%{"release_date" => release_date, "name" => name}) do
    %{release_date: release_date, name: name}
  end

  @spec get_shows(String.t()) :: list
  def get_shows(authorization) do
    url = "#{@api}/me/shows"

    transformation = fn arg ->
      arg
      |> Enum.map(&pick_show/1)
      |> Enum.map(&pick_show_main_info/1)
    end

    fetch_all(url, authorization, transformation)
  end

  @spec get_user_info(String.t()) :: any
  def get_user_info(authorization) do
    url = "#{@api}/me"

    HTTPoison.get!(url, Authorization: authorization)
    |> pick_body()
    |> Jason.decode!()
  end

  defp fetch_all(url, authorization, transformation) do
    fetch_loop(url, authorization, [], transformation)
  end

  defp fetch_loop(url, authorization, elements, transformation) do
    response =
      HTTPoison.get!(url, Authorization: authorization)
      |> pick_body()
      |> Jason.decode!()

    new_elements =
      response
      |> pick_items()
      |> transformation.()

    elements = elements ++ new_elements

    %{"next" => next_url} = response

    case next_url do
      nil -> elements
      _ -> fetch_loop(next_url, authorization, elements, transformation)
    end
  end

  @spec get_episodes_by_show_id(String.t(), String.t()) :: list
  def get_episodes_by_show_id(authorization, show_id) do
    HTTPoison.get!("#{@api}/shows/#{show_id}/episodes", Authorization: authorization)
    |> pick_body()
    |> Jason.decode!()
    |> pick_items()
    |> Enum.map(&episode_main_info/1)
  end
end
