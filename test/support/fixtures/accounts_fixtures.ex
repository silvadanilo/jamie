defmodule Jamie.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Jamie.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def user_fixture(attrs \\ %{}) do
    role = Map.get(attrs, :role, :user)

    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        name: "Test",
        surname: "User",
        phone: "1234567890",
        preferred_role: "base"
      })
      |> Jamie.Accounts.register_user()

    if role != :user do
      Jamie.Repo.update!(Ecto.Changeset.change(user, role: Atom.to_string(role)))
    else
      user
    end
  end
end
