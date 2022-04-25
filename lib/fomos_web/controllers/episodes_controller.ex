defmodule FomosWeb.EpisodeController do
  use FomosWeb, :controller

  @spec get_by_date(Plug.Conn.t(), map) :: Plug.Conn.t()
  def get_by_date(conn, %{"date" => date}) do
    response =
      case result = Episode.Repo.get_by_date(date) do
        {:error, reason} -> %{"error" => reason}
        [_ | _] -> result |> Enum.map(fn {_, ep} -> ep end)
      end

    # IO.inspect(response)

    json(conn, response)
  end

  def dates(conn, _) do
    response = Episode.Repo.get_all_keys()
    json(conn, response)
  end
end
