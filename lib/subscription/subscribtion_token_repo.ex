defmodule Subscribtion.Token.Repo do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: SubscriberTokenRepo)
  end

  def save(user_id, token_metadata) do
    GenServer.cast(SubscriberTokenRepo, {:save_token_metadata, user_id, token_metadata})
  end

  def get(user_id) do
    GenServer.call(SubscriberTokenRepo, {:get_token_metadata, user_id})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get_token_metadata, user_id}, _from, state) do
    IO.inspect(state)
    {:reply, Map.get(state, user_id), state}
  end

  def handle_cast({:save_token_metadata, user_id, token_metadata}, state) do
    {:noreply, Map.put(state, user_id, token_metadata)}
  end
end
