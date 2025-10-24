defmodule JamieWeb.UserMagicLinkController do
  use JamieWeb, :controller

  alias Jamie.Accounts
  alias JamieWeb.UserAuth

  def show(conn, %{"token" => token}) do
    case Accounts.get_user_by_magic_link_token(token) do
      {:ok, user} ->
        Accounts.delete_magic_link_tokens_for_user(user)
        Accounts.confirm_user(user)

        conn
        |> put_flash(:info, "Welcome! You've been signed in successfully.")
        |> UserAuth.log_in_user(user)

      :error ->
        conn
        |> put_flash(:error, "Magic link is invalid or it has expired.")
        |> redirect(to: ~p"/login")
    end
  end
end
