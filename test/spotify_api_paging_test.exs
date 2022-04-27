defmodule Spotify_API_Test do
  use ExUnit.Case
  doctest Spotify_API
  # ascending
  test "should create ascending pagination for result = page_size" do
    expected = [
      %{offset: 0, limit: 5}
    ]

    result = Spotify_API.Paging.create_paging_parameters(5, 5)
    assert(expected == result)
  end

  test "should create ascending pagination for result < page_size" do
    expected = [
      %{offset: 0, limit: 3}
    ]

    result = Spotify_API.Paging.create_paging_parameters(3, 5)
    assert(expected == result)
  end

  test "should create ascending pagination for result > page_size + remain" do
    expected = [
      %{offset: 0, limit: 5},
      %{offset: 5, limit: 5},
      %{offset: 10, limit: 5},
      %{offset: 15, limit: 2}
    ]

    result = Spotify_API.Paging.create_paging_parameters(17, 5)
    assert(expected == result)
  end

  test "should create ascending pagination for result > page_size" do
    expected = [
      %{offset: 0, limit: 5},
      %{offset: 5, limit: 5},
      %{offset: 10, limit: 5}
    ]

    result = Spotify_API.Paging.create_paging_parameters(15, 5)
    assert(expected == result)
  end

  # descending
  test "should create descending pagination for result = page_size" do
    expected = [
      %{offset: 0, limit: 5}
    ]

    result = Spotify_API.Paging.create_paging_parameters_desc(5, 5)
    assert(expected == result)
  end

  test "should create descending pagination for result < page_size" do
    expected = [
      %{offset: 0, limit: 3}
    ]

    result = Spotify_API.Paging.create_paging_parameters_desc(3, 5)
    assert(expected == result)
  end

  test "should create descending pagination for result > page_size + remain" do
    expected = [
      %{offset: 12, limit: 5},
      %{offset: 7, limit: 5},
      %{offset: 2, limit: 5},
      %{offset: 0, limit: 2}
    ]

    result = Spotify_API.Paging.create_paging_parameters_desc(17, 5)
    assert(expected == result)
  end

  test "should create descending pagination for result > page_size" do
    expected = [
      %{offset: 10, limit: 5},
      %{offset: 5, limit: 5},
      %{offset: 0, limit: 5}
    ]

    result = Spotify_API.Paging.create_paging_parameters_desc(15, 5)
    assert(expected == result)
  end
end
