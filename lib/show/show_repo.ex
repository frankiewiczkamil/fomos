defmodule Show.Repo do
  require Logger

  def save(%{id: id} = show, updated) do
    GenServer.cast(ShowRepo, {:save, id, show, updated})
  end

  def get_by_id(show_id) do
    GenServer.call(ShowRepo, {:get_by_id, show_id})
  end

  def get_show_name(show_id) do
    case show = get_by_id(show_id) do
      nil ->
        nil

      _ ->
        show
        |> pick_show()
        |> pick_name()
    end
  end

  def pick_name(%{name: name}), do: name
  def pick_show(%{show: show}), do: show
end
