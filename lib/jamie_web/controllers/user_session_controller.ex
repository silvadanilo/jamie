defmodule JamieWeb.UserSessionController do
  use JamieWeb, :controller

  alias Jamie.Accounts
  alias JamieWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = _params) do
    conn
    |> put_flash(
      :info,
      "Account created successfully! Check your email for a magic link to sign in."
    )
    |> redirect(to: ~p"/login")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    email = Map.get(user_params, "email")
    password = Map.get(user_params, "password")

    cond do
      is_nil(email) ->
        conn
        |> put_flash(:error, "Email is required")
        |> redirect(to: ~p"/login")

      is_nil(password) ->
        conn
        |> put_flash(:error, "Password is required")
        |> redirect(to: ~p"/login")

      user = Accounts.get_user_by_email_and_password(email, password) ->
        conn
        |> put_flash(:info, info)
        |> UserAuth.log_in_user(user, user_params)

      true ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, String.slice(email, 0, 160))
        |> redirect(to: ~p"/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
