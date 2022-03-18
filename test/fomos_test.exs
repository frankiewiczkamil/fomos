defmodule FomosTest do
  use ExUnit.Case
  doctest Fomos

  test "greets the world" do
    assert Fomos.hello() == :world
  end
end
