defmodule Spotify_API_Test do
  use ExUnit.Case
  doctest Spotify_API

  test "should create pagination for result = page_size" do
    expected = [
      %{offset: 0, limit: 5}
    ]

    result = Spotify_API.Paging.create_paging_parameters(5, 5)
    assert(expected == result)
  end

  test "should create pagination for result < page_size" do
    expected = [
      %{offset: 0, limit: 3}
    ]

    result = Spotify_API.Paging.create_paging_parameters(3, 5)
    assert(expected == result)
  end

  test "should create pagination for result > page_size + remain" do
    expected = [
      %{offset: 0, limit: 5},
      %{offset: 5, limit: 5},
      %{offset: 10, limit: 5},
      %{offset: 15, limit: 2}
    ]

    result = Spotify_API.Paging.create_paging_parameters(17, 5)
    assert(expected == result)
  end

  test "should create pagination for result > page_size" do
    expected = [
      %{offset: 0, limit: 5},
      %{offset: 5, limit: 5},
      %{offset: 10, limit: 5}
    ]

    result = Spotify_API.Paging.create_paging_parameters(15, 5)
    assert(expected == result)
  end
end
