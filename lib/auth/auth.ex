defmodule Auth do
  def get_dev_token do
    Application.fetch_env!(:fomos, :token)
  end
end
