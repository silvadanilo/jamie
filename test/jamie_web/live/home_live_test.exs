defmodule JamieWeb.HomeLiveTest do
  use JamieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Jamie.OccurencesFixtures
  import Jamie.AccountsFixtures

  describe "Home page" do
    test "renders home page with public occurences", %{conn: conn} do
      user = user_fixture()
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      _public_occurence =
        occurence_fixture(%{
          created_by_id: user.id,
          is_private: false,
          date: future_date,
          title: "Public Jam"
        })

      {:ok, _lv, html} = live(conn, ~p"/")

      assert html =~ "Welcome to Jamie"
      assert html =~ "Public Jam"
      assert html =~ "Upcoming Public Events"
    end

    test "shows empty state when no public occurences", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/")

      assert html =~ "Welcome to Jamie"
      assert html =~ "No public events scheduled yet"
    end

    test "shows sign in and get started buttons when not authenticated", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/")

      assert html =~ "Get Started"
      assert html =~ "Sign In"
      refute html =~ "My Events"
    end

    test "shows my events button when authenticated", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, _lv, html} = live(conn, ~p"/")

      assert html =~ "My Events"
      refute html =~ "Get Started"
    end

    test "does not show private occurences", %{conn: conn} do
      user = user_fixture()
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      _private_occurence =
        occurence_fixture(%{
          created_by_id: user.id,
          is_private: true,
          date: future_date,
          title: "Private Jam"
        })

      {:ok, _lv, html} = live(conn, ~p"/")

      refute html =~ "Private Jam"
    end

    test "does not show disabled occurences", %{conn: conn} do
      user = user_fixture()
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      _disabled_occurence =
        occurence_fixture(%{
          created_by_id: user.id,
          disabled: true,
          date: future_date,
          title: "Disabled Jam"
        })

      {:ok, _lv, html} = live(conn, ~p"/")

      refute html =~ "Disabled Jam"
    end
  end

  defp log_in_user(conn, user) do
    token = Jamie.Accounts.generate_user_session_token(user)
    conn |> Phoenix.ConnTest.init_test_session(%{}) |> Plug.Conn.put_session(:user_token, token)
  end
end
