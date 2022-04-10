defmodule Spotify_API do
  # dev mode only, tmp
  @api "https://api.spotify.com/v1"

  @type show_main_info :: %{
          id: String.t(),
          name: String.t()
        }

  def api_url(), do: @api

  def pick_body(%{body: body}), do: body
  def pick_items(%{"items" => items}), do: items

  def fetch_all(url, authorization, transformation) do
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
end
