defmodule Spotify_API2_Test do
  use ExUnit.Case
  doctest Subscribtion.Token.Repo

  test "should save given value if it does not exist" do
    user_id = "tester"
    token_metadata = %{token: "token123456"}

    Subscribtion.Token.Repo.save(user_id, token_metadata)
    fetched = GenServer.call(SubscriberTokenRepo, {:get_token_metadata, user_id})

    assert(fetched == token_metadata)
  end

  test "should return saved" do
    user_id = "tester"
    token_metadata = %{token: "token123456"}
    GenServer.cast(SubscriberTokenRepo, {:save_token_metadata, user_id, token_metadata})

    result = Subscribtion.Token.Repo.get(user_id)
    assert(token_metadata == result)
  end

  test "should overwrite given value if it does exist already" do
    user_id = "tester"
    token_metadata = %{token: "token123456"}
    new_token_metadata = %{token: "token654321"}
    GenServer.cast(SubscriberTokenRepo, {:save_token_metadata, user_id, token_metadata})
    Subscribtion.Token.Repo.save(user_id, new_token_metadata)
    fetched = GenServer.call(SubscriberTokenRepo, {:get_token_metadata, user_id})

    assert(fetched == new_token_metadata)
  end
end
