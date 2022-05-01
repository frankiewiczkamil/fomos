defmodule FomosWeb.EpisodeController do
  use FomosWeb, :controller

  def get_id_by_date(conn, %{"date" => date}) do
    date
    |> Episode.Service.get_id_by_date()
    |> respond_factory(conn).()
  end

  def get_by_date(conn, %{"date" => date}) do
    date
    |> Episode.Service.get_by_date()
    |> respond_factory(conn).()
  end

  def dates(conn, _) do
    response = Episode.Repo.get_all_keys()
    json(conn, response)
  end

  defp respond_factory(conn) do
    fn response -> json(conn, response) end
  end
end
