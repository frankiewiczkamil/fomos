defmodule Episode.Service do
  require Logger

  def get_by_date(date) do
    get_by_date(date, &pick_episode/1)
  end

  def get_by_date(date, transformation) do
    case result = Episode.Repo.get_by_date(date) do
      {:error, reason} -> %{"error" => reason}
      [_ | _] -> result |> Enum.map(transformation)
    end
  end

  defp pick_episode({_date, episode}), do: episode
end
