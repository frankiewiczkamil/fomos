defmodule FomosWeb.EpisodeController do
  use FomosWeb, :controller

  def get_id_by_date(conn, %{"date" => date, "days" => days}) do
    get_id_by_date(conn, Date.from_iso8601!(date), days)
  end

  def get_id_by_date(conn, %{"days" => days}) do
    get_id_by_date(conn, Date.utc_today(), days)
  end

  def get_id_by_date(conn, %{"date" => date}) do
    date
    |> Episode.Service.get_id_by_date()
    |> respond_factory(conn).()
  end

  defp get_id_by_date(conn, date_to, days) do
    {days_number, _} = Integer.parse(days)

    0..(days_number - 1)
    |> Enum.map(fn n -> Date.add(date_to, -n) end)
    |> Enum.map(&Date.to_iso8601/1)
    |> Enum.reduce(%{}, fn date, acc ->
      Map.put(acc, date, Episode.Service.get_id_by_date(date))
    end)
    |> respond_factory(conn).()
  end

  def get_by_date(conn, %{"date" => date, "days" => days}) do
    get_by_date(conn, Date.from_iso8601!(date), days)
  end

  def get_by_date(conn, %{"date" => date}) do
    date
    |> Episode.Service.get_by_date()
    |> respond_factory(conn).()
  end

  def get_by_date(conn, %{"days" => days}) do
    get_by_date(conn, Date.utc_today(), days)
  end

  defp get_by_date(conn, date_to, days) do
    {days_number, _} = Integer.parse(days)

    0..(days_number - 1)
    |> Enum.map(fn n -> Date.add(date_to, -n) end)
    |> Enum.map(&Date.to_iso8601/1)
    |> Enum.reduce(%{}, fn date, acc -> Map.put(acc, date, Episode.Service.get_by_date(date)) end)
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
