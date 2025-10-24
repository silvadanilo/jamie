defmodule JamieWeb.UserLoginLiveTest do
  use JamieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Jamie.AccountsFixtures

  describe "Login page" do
    test "renders login page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/login")

      assert html =~ "Sign in to account"
      assert html =~ "Sign up"
      assert html =~ "Send me a magic link"
    end

    test "redirects if already logged in", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:error, redirect} = live(conn, ~p"/login")
      assert {:redirect, %{to: path}} = redirect
      assert path == ~p"/"
    end

    test "sends magic link when valid email provided", %{conn: conn} do
      user = user_fixture()
      {:ok, lv, _html} = live(conn, ~p"/login")

      lv
      |> form("#login_form", user: %{"email" => user.email})
      |> render_change()

      lv |> element("button", "Send me a magic link") |> render_click()

      flash = assert_redirect(lv, ~p"/login")
      assert flash["info"] =~ "If your email is in our system"
    end

    test "handles magic link click without email gracefully", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/login")

      html = lv |> element("button", "Send me a magic link") |> render_click()

      assert html =~ "Sign in to account"
    end

    test "login with valid email and password", %{conn: conn} do
      password = "password123456"
      user = user_with_password_fixture(%{password: password})

      {:ok, lv, _html} = live(conn, ~p"/login")

      form =
        lv
        |> form("#login_form",
          user: %{
            "email" => user.email,
            "password" => password,
            "remember_me" => "true"
          }
        )

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back"
    end

    test "shows error with invalid password", %{conn: conn} do
      user = user_with_password_fixture(%{password: "password123456"})

      {:ok, lv, _html} = live(conn, ~p"/login")

      form =
        lv
        |> form("#login_form",
          user: %{
            "email" => user.email,
            "password" => "wrongpassword"
          }
        )

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/login"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid email or password"
    end

    test "preserves email on failed login", %{conn: conn} do
      user = user_with_password_fixture(%{password: "password123456"})

      {:ok, lv, _html} = live(conn, ~p"/login")

      form =
        lv
        |> form("#login_form",
          user: %{
            "email" => user.email,
            "password" => "wrongpassword"
          }
        )

      conn = submit_form(form, conn)

      {:ok, _lv, html} = live(conn, ~p"/login")
      assert html =~ user.email
    end
  end

  defp user_with_password_fixture(attrs \\ %{}) do
    password = Map.get(attrs, :password, "password123456")

    user = user_fixture()

    {:ok, user} =
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(
        :hashed_password,
        Bcrypt.hash_pwd_salt(password)
      )
      |> Jamie.Repo.update()

    user
  end

  defp log_in_user(conn, user) do
    token = Jamie.Accounts.generate_user_session_token(user)
    conn |> Phoenix.ConnTest.init_test_session(%{}) |> Plug.Conn.put_session(:user_token, token)
  end
end
