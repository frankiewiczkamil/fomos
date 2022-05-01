defmodule Episode.Service do
  require Logger

  # todo this will return list of ids
  def get_id_by_date(date) do
    get_by_date(date, &pick_episode/1)
  end

  def get_by_date(date) do
    transformation = fn episode -> episode |> pick_episode() |> episode_with_show() end
    get_by_date(date, transformation)
  end

  def get_by_date(date, transformation) do
    case result = Episode.Repo.get_by_date(date) do
      {:error, reason} -> %{"error" => reason}
      [_ | _] -> result |> Enum.map(transformation)
    end
  end

  defp pick_episode({_date, episode}), do: episode

  defp episode_with_show(%{show_id: show_id, name: name}) do
    %{
      show: Show.Repo.get_show_name(show_id),
      name: name
    }
  end
end
