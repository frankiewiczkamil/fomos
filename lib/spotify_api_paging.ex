defmodule Spotify_API.Paging do
  def create_paging_parameters(elements_to_fetch, page_size) do
    division = div(elements_to_fetch, page_size)
    remainder = rem(elements_to_fetch, page_size)

    rest =
      case remainder do
        0 -> []
        _ -> [paging_parameters(division * page_size, remainder)]
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

  defp paging_parameters(offset, limit), do: %{offset: offset, limit: limit}
end
