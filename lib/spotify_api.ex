defmodule Spotify_API do
  use GenServer
  require Logger
  @api "https://api.spotify.com/v1"

  def api_url(), do: @api

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: SpotifyAPI)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({url, auth}, _from, state) do
    Logger.debug("fetch #{url} requested")
    {:reply, fetch_handler(url, auth), state}
  end

  def pick_body(%{body: body}), do: body
  def pick_items(%{"items" => items}), do: items

  def fetch_all(url, authorization, transformation) do
    fetch_loop(url, authorization, [], transformation)
  end

  def fetch(url, authorization, offset, limit) do
    fetch("#{url}?limit=#{limit}&offset=#{offset}", authorization)
  end

  def fetch(url, authorization, offset, limit, transformation) do
    fetch(url, authorization, offset, limit)
    |> pick_items()
    |> transformation.()
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

  defp pagination_parameters(offset, limit), do: %{offset: offset, limit: limit}

  def fetch(url, authorization) do
    # spotify limits amount of parallel requests and responds 429 when flooded
    GenServer.call(SpotifyAPI, {url, authorization})
  end

  def fetch_handler(url, authorization) do
    HTTPoison.get!(url, Authorization: authorization)
    |> pick_body()
    |> Jason.decode!()
  end

  defp fetch_loop(url, authorization, elements, transformation) do
    response = fetch(url, authorization)

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
