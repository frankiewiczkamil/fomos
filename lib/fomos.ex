defmodule Fomos do
  # use HTTPoison
  @moduledoc """
  Documentation for `Fomos`.
  """

  @doc """
  """
  def hello do
    # val = Application.fetch_env!(:fomos, :hello)
    token = Application.fetch_env!(:fomos, :token)
    greet = Application.fetch_env!(:fomos, :greet)
    {token, greet}
  end
end
