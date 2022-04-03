defmodule Fomos.Repo do
  use Ecto.Repo,
    otp_app: :fomos,
    adapter: Ecto.Adapters.Postgres
end
