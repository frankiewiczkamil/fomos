defmodule Subscription.Repo do
  require Logger

  @spec save(String.t(), list(String.t())) :: :ok
  def save(subscriber_id, show_ids) do
    GenServer.cast(
      SubscriptionRepo,
      {:save, subscriber_id, show_ids, DateTime.utc_now()}
    )
  end

  @spec get(String.t()) :: {String.t(), list(String.t()), DateTime.t()} | nil
  def get(subscriber_id) do
    GenServer.call(SubscriptionRepo, {:get_by_id, subscriber_id})
  end

  @spec first() :: String.t() | nil
  def first() do
    GenServer.call(SubscriptionRepo, :get_first)
  end

  @spec next(String.t()) :: String.t() | nil
  def next(previous_subscriber_id) do
    GenServer.call(SubscriptionRepo, {:get_next, previous_subscriber_id})
  end
end
