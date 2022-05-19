defmodule Episode.Service do
  require Logger

  def get_id_by_date(date) do
    # todo this will return list of ids - requires storing id
    get_by_date(date, &epoisodes_to_episode_ids/1)
  end

  defp epoisodes_to_episode_ids(episodes) do
    episodes
    |> Enum.map(&pick_episode_id/1)
  end

  def get_by_date(date) do
    get_by_date(date, &episodes_to_grouped_episodes/1)
  end

  defp episodes_to_grouped_episodes(episodes) do
    episodes
    |> Enum.map(&pick_episode/1)
    |> Enum.group_by(&pick_show_id/1)
    |> Map.to_list()
    |> Enum.map(&to_human_readable/1)
    |> Enum.into(%{})
  end

  def get_by_date_test(show_id) do
    my_filter_fn = fn episode_tuple ->
      episode_tuple |> pick_episode() |> is_show_id_matching_factory(show_id).()
    end

    get_by_date_generic(
      "2022-05-05",
      &episodes_to_grouped_episodes/1,
      my_filter_fn
    )
  end

  def get_by_date_test() do
    get_by_date_generic(
      "2022-05-05",
      &episodes_to_grouped_episodes/1,
      nil
    )
  end

  defp get_by_date_generic(date, transformation, filter) do
    case result = Episode.Repo.get_by_date(date) do
      {:error, reason} ->
        %{"error" => reason}

      [] ->
        []

      [_ | _] ->
        result
        |> filter_episodes(filter).()
        |> transformation.()
    end
  end

  defp filter_episodes(filter_fn) do
    case filter_fn do
      nil -> fn episodes -> episodes end
      _ -> fn episodes -> Enum.filter(episodes, filter_fn) end
    end
  end

  defp is_show_id_matching_factory(given_show_id) do
    fn %{show_id: show_id} -> show_id === given_show_id end
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
  defp pick_episode_id({_date, %{id: id}}), do: id
  defp pick_show_id(%{show_id: show_id}), do: show_id

  defp pick_episode_human_readable_data(episode) do
    %{name: episode[:name], duration: episode[:duration], uri: episode[:uri]}
  end

  defp to_human_readable({show_id, episodes}) do
    {
      show_id |> Show.Repo.get_show_name(),
      episodes |> Enum.map(&pick_episode_human_readable_data/1)
    }
  end
end
