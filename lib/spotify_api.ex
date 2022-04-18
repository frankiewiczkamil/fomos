defmodule Spotify_API do
  # dev mode only, tmp
  @api "https://api.spotify.com/v1"

  def api_url(), do: @api

  def pick_body(%{body: body}), do: body
  def pick_items(%{"items" => items}), do: items

  def fetch_all(url, authorization, transformation) do
    fetch_loop(url, authorization, [], transformation)
  end

  def fetch(url, authorization, offset, limit) do
    fetch("#{url}?limit=#{limit}&offset=#{offset}", authorization)
  end

  def create_pagination_parameters(elements_to_fetch, page_size) do
    division = div(elements_to_fetch, page_size)
    remainder = rem(elements_to_fetch, page_size)

    rest =
      case remainder do
        0 -> []
        _ -> [pagination_parameters(division * page_size, remainder)]
      end

    aliquotes =
      case division do
        0 ->
          []

        _ ->
          Enum.map(1..division, fn x -> (x - 1) * page_size end)
          |> Enum.map(fn offset -> %{offset: offset, limit: page_size} end)
      end

    aliquotes ++ rest
  end

  def pagination_parameters(offset, limit), do: %{offset: offset, limit: limit}

  def fetch(url, authorization) do
    HTTPoison.get!(url, Authorization: authorization)
    |> pick_body()
    |> Jason.decode!()
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
