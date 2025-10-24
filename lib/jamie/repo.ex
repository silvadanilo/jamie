defmodule Jamie.Repo do
  use Ecto.Repo,
    otp_app: :jamie,
    adapter: Ecto.Adapters.Postgres
end
