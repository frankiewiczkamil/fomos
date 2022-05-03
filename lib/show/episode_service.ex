defmodule Episode.Service do
  require Logger

  def get_id_by_date(date) do
    # todo this will return list of ids - requires storing id
    get_by_date(date, &epoisodes_to_episode_ids/1)
  end

  defp epoisodes_to_episode_ids(episodes) do
    episodes
    |> Enum.map(&pick_episode/1)
  end

  def get_by_date(date) do
    get_by_date(date, &epoisodes_to_grouped_episodes/1)
  end

  defp epoisodes_to_grouped_episodes(episodes) do
    episodes
    |> Enum.map(&pick_episode/1)
    |> Enum.group_by(&pick_show_id/1)
    |> Map.to_list()
    |> Enum.map(&to_human_readable/1)
    |> Enum.into(%{})
  end

  @spec get_by_date(any, any) :: any
  def get_by_date(date, transformation) do
    case result = Episode.Repo.get_by_date(date) do
      {:error, reason} -> %{"error" => reason}
      [] -> result |> transformation.()
      [_ | _] -> result |> transformation.()
    end
  end

  defp pick_episode({_date, episode}), do: episode
  defp pick_show_id(%{show_id: show_id}), do: show_id
  defp pick_name(%{name: name}), do: name

  defp to_human_readable({show_id, episodes}) do
    {
      show_id |> Show.Repo.get_show_name(),
      episodes |> Enum.map(&pick_name/1)
    }
  end
end
