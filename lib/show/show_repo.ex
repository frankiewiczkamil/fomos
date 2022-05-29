defmodule Show.Repo do
  require Logger

  @spec save(Show.Model.mini(), integer()) :: :ok
  def save(%{id: id} = show, updated) do
    GenServer.cast(ShowRepo, {:save, id, show, updated})
  end

  @spec get_by_id(String.t()) :: Show.Model.repo_response()
  def get_by_id(show_id) do
    GenServer.call(ShowRepo, {:get_by_id, show_id})
  end

  @spec get_show_name(String.t()) :: String.t()
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

  @spec pick_name(Show.Model.mini()) :: String.t()
  def pick_name(%{name: name}), do: name
  @spec pick_show(Show.Model.repo_response()) :: Show.Model.mini()
  def pick_show(%{show: show}), do: show
end
