defmodule Podcast.Tracking.Initilizer do
  require Logger

  def init_subscriptions_from_db() do
    Logger.debug("Init subscriptions from DB: start")
    Subscription.Repo.first() |> init_subscriptions_from_db
  end

  defp init_subscriptions_from_db(sub_id) when sub_id == nil do
    Logger.debug("Init subscriptions from DB: done")
  end

  defp init_subscriptions_from_db(sub_id) do
    Logger.debug("Add #{sub_id}'s shows")
    {_id, shows, _timestamp} = Subscription.Repo.get(sub_id)
    Logger.debug("Found #{length(shows)} shows to be saved")

    request_tracking_subscriber = fn show_id -> request_tracking(show_id, sub_id) end

    shows
    |> Enum.map(request_tracking_subscriber)

    next_sub_id = Subscription.Repo.next(sub_id)
    init_subscriptions_from_db(next_sub_id)
  end

  defp request_tracking(show_id, subscriber_id) do
    Logger.notice(" - #{show_id}")
    GenServer.call(ShowTrackingCoordinator, {:track, show_id, subscriber_id})
  end
end
