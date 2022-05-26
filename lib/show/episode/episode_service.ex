defmodule Episode.Service do
  require Logger

  @spec get_id_by_date(String.t()) :: list(Episode.Model.episode())
  def get_id_by_date(date) do
    # todo this will return list of ids - requires storing id
    get_by_date(date, &epoisodes_to_episode_ids/1)
  end

  @spec epoisodes_to_episode_ids(list(Episode.Model.episode())) :: list(String.t())
  defp epoisodes_to_episode_ids(episodes) do
    episodes
    |> Enum.map(&pick_episode_id/1)
  end

  @spec get_by_date(String.t()) :: list(Episode.Model.episode())
  def get_by_date(date) do
    get_by_date(date, &episodes_to_grouped_episodes/1)
  end

  # todo define type for grouped episodes
  @spec episodes_to_grouped_episodes(list(Episode.Model.episode())) :: any
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

  @spec get_by_date_generic(
          String.t(),
          (list(Episode.Model.episode()) -> any),
          (list(Episode.Model.episode()) -> boolean()) | nil
        ) ::
          list(Episode.Model.episode())
  defp get_by_date_generic(date, transformation, filter) do
    Episode.Repo.get_by_date(date)
    |> filter_episodes(filter).()
    |> transformation.()
  end

  @spec filter_episodes((list(Episode.Model.episode()) -> boolean()) | nil) ::
          (list(Episode.Model.episode()) -> list(Episode.Model.episode()))
  defp filter_episodes(filter_fn) do
    case filter_fn do
      nil -> fn episodes -> episodes end
      _ -> fn episodes -> Enum.filter(episodes, filter_fn) end
    end
  end

  @spec is_show_id_matching_factory(String.t()) :: (%{show_id: String.t()} -> boolean())
  defp is_show_id_matching_factory(given_show_id) do
    fn %{show_id: show_id} -> show_id === given_show_id end
  end

  @spec get_by_date(String.t(), (Spotify.Model.episode() -> any)) :: any
  def get_by_date(date, transformation) do
    Episode.Repo.get_by_date(date)
    |> transformation.()
  end

  @spec pick_episode({String.t(), Spotify.Model.episode()}) :: Spotify.Model.episode()
  defp pick_episode({_date, episode}), do: episode

  @spec pick_episode_id({String.t(), %{id: String.t()}}) :: String.t()
  defp pick_episode_id({_date, %{id: id}}), do: id

  @spec pick_episode_id(%{show_id: String.t()}) :: String.t()
  defp pick_show_id(%{show_id: show_id}), do: show_id

  @spec pick_episode_human_readable_data(Episode.Model.episode()) ::
          Episode.Model.episode_mini()
  defp pick_episode_human_readable_data(episode) do
    %{name: episode[:name], duration: episode[:duration], uri: episode[:uri]}
  end

  @spec to_human_readable({String.t(), list(Episode.Model.episode())}) ::
          {String.t(), list(Episode.Model.episode_mini())}
  defp to_human_readable({show_id, episodes}) do
    {
      show_id |> Show.Repo.get_show_name(),
      episodes |> Enum.map(&pick_episode_human_readable_data/1)
    }
  end
end
