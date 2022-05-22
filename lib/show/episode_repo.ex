defmodule Episode.Repo do
  require Logger

  @spec save(Episode.Model.episode()) :: :ok
  def save(episode) do
    GenServer.cast(EpisodeRepo, {:save, episode})
  end

  @spec get_by_date(String.t()) :: list(Episode.Model.episode())
  def get_by_date(date) do
    GenServer.call(EpisodeRepo, {:get_by_date, date})
  end

  @spec get_by_show_id(String.t()) :: list(Episode.Model.episode())
  def get_by_show_id(show_id) do
    GenServer.call(EpisodeRepo, {:get_by_show_id, show_id})
  end

  @spec get_all_keys :: list(String.t())
  def get_all_keys() do
    # tmp for dev purposes
    GenServer.call(EpisodeRepo, :get_all_keys)
    |> Enum.sort()
  end
end
