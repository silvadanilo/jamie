defmodule JamieWeb.UserRegistrationLiveTest do
  use JamieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/register")

      assert html =~ "Join Jamie"
      assert html =~ "Sign in"
    end

    test "redirects if already logged in", %{conn: conn} do
      user = insert_user()
      conn = log_in_user(conn, user)

      {:error, redirect} = live(conn, ~p"/register")
      assert {:redirect, %{to: path}} = redirect
      assert path == ~p"/"
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"email" => "invalid"})

      assert result =~ "must have the @ sign and no spaces"
    end

    test "creates account and sends magic link", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/register")

      email = unique_user_email()

      form =
        lv
        |> form("#registration_form",
          user: %{
            "email" => email,
            "name" => "Test",
            "surname" => "User",
            "phone" => "1234567890",
            "preferred_role" => "base"
          }
        )

      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/login"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Account created successfully! Check your email"
    end
  end

  defp insert_user(attrs \\ %{}) do
    params =
      Enum.into(attrs, %{
        email: unique_user_email(),
        name: "Test",
        surname: "User",
        phone: "1234567890",
        preferred_role: "base"
      })

    {:ok, user} = Jamie.Accounts.register_user(params)
    user
  end

  defp unique_user_email, do: "user#{System.unique_integer()}@example.com"

  defp log_in_user(conn, user) do
    token = Jamie.Accounts.generate_user_session_token(user)
    conn |> Phoenix.ConnTest.init_test_session(%{}) |> Plug.Conn.put_session(:user_token, token)
  end
end
