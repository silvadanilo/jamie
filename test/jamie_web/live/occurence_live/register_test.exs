defmodule JamieWeb.OccurenceLive.RegisterTest do
  use JamieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Jamie.OccurencesFixtures
  import Jamie.AccountsFixtures

  describe "Register page - access control" do
    setup do
      user = user_fixture(%{name: "John", surname: "Doe", email: "test@example.com"})
      creator = user_fixture(%{email: "creator@example.com"})
      %{user: user, creator: creator}
    end

    test "redirects to login if not authenticated", %{conn: conn, creator: creator} do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          slug: "test-event"
        })

      result = live(conn, ~p"/events/#{occurence.slug}/register")

      assert {:error, {:redirect, %{to: "/login"}}} = result
    end

    test "redirects if event is in the past", %{conn: conn, user: user, creator: creator} do
      past_date = DateTime.add(DateTime.utc_now(), -7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: past_date,
          slug: "past-event"
        })

      conn = log_in_user(conn, user)

      {:error, {:live_redirect, %{to: redirect_path, flash: flash}}} =
        live(conn, ~p"/events/#{occurence.slug}/register")

      assert redirect_path == ~p"/events/#{occurence.slug}"
      assert flash["error"] =~ "already passed"
    end

    test "redirects if user is already registered", %{conn: conn, user: user, creator: creator} do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          slug: "registered-event"
        })

      # Register user first
      participant_fixture(%{
        occurence_id: occurence.id,
        user_id: user.id,
        status: "confirmed"
      })

      conn = log_in_user(conn, user)

      {:error, {:live_redirect, %{to: redirect_path, flash: flash}}} =
        live(conn, ~p"/events/#{occurence.slug}/register")

      assert redirect_path == ~p"/events/#{occurence.slug}"
      assert flash["info"] =~ "already registered"
    end
  end

  describe "Register page - rendering" do
    setup do
      user = user_fixture(%{name: "John", surname: "Doe", preferred_role: "flyer"})
      creator = user_fixture(%{email: "creator@example.com"})
      %{user: user, creator: creator}
    end

    test "displays event information", %{conn: conn, user: user, creator: creator} do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          title: "Test Event",
          location: "Test Location",
          cost: Decimal.new("10.50"),
          description: "Test description",
          slug: "test-event"
        })

      conn = log_in_user(conn, user)
      {:ok, lv, html} = live(conn, ~p"/events/#{occurence.slug}/register")

      assert html =~ "Test Event"
      assert html =~ "Test Location"
      assert html =~ "€10.5"
      assert html =~ "Test description"
      assert has_element?(lv, "select[name='participant[role]']")
    end

    test "shows free badge when event is free", %{conn: conn, user: user, creator: creator} do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          cost: nil,
          slug: "free-event"
        })

      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/events/#{occurence.slug}/register")

      assert html =~ "Free"
      refute html =~ "€"
    end

    test "pre-fills registration type from user preference", %{
      conn: conn,
      user: user,
      creator: creator
    } do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          slug: "prefill-event"
        })

      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/events/#{occurence.slug}/register")

      # User has preferred_role = "flyer"
      assert has_element?(lv, "select[name='participant[role]'] option[selected][value='flyer']")
    end

    test "shows nickname field when participant list is public", %{
      conn: conn,
      user: user,
      creator: creator
    } do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          show_partecipant_list: true,
          slug: "public-list-event"
        })

      conn = log_in_user(conn, user)
      {:ok, lv, html} = live(conn, ~p"/events/#{occurence.slug}/register")

      assert html =~ "Public Nickname"
      assert html =~ "participant list publicly"
      assert has_element?(lv, "input[name='participant[nickname]'][required]")
    end

    test "pre-fills nickname with user name", %{conn: conn, user: user, creator: creator} do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          show_partecipant_list: true,
          slug: "nickname-event"
        })

      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/events/#{occurence.slug}/register")

      # User name is "John"
      assert has_element?(lv, "input[name='participant[nickname]'][value='John']")
    end

    test "shows waitlist alert when event is full", %{conn: conn, user: user, creator: creator} do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          base_capacity: 1,
          flyer_capacity: 0,
          slug: "full-event"
        })

      # Fill the event
      other_user = user_fixture(%{email: "other@example.com"})

      participant_fixture(%{
        occurence_id: occurence.id,
        user_id: other_user.id,
        status: "confirmed",
        role: "base"
      })

      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/events/#{occurence.slug}/register")

      assert html =~ "Event is full"
      assert html =~ "waitlist"
    end
  end

  describe "Register page - form submission" do
    setup do
      user = user_fixture(%{name: "John", preferred_role: "base"})
      creator = user_fixture(%{email: "creator@example.com"})
      %{user: user, creator: creator}
    end

    test "successfully registers user for event", %{conn: conn, user: user, creator: creator} do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          base_capacity: 10,
          slug: "register-success"
        })

      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/events/#{occurence.slug}/register")

      lv
      |> form("#participant-form", participant: %{role: "base", notes: "Test note"})
      |> render_submit()

      flash = assert_redirect(lv, ~p"/events/#{occurence.slug}")
      assert flash["success"] =~ "Registration successful"

      # Verify participant was created
      participant = Jamie.Occurences.get_participant(occurence.id, user.id)
      assert participant
      assert participant.status == "confirmed"
      assert participant.role == "base"
      assert participant.notes == "Test note"
    end

    test "registers user to waitlist when event is full", %{
      conn: conn,
      user: user,
      creator: creator
    } do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          base_capacity: 1,
          flyer_capacity: 0,
          slug: "waitlist-event"
        })

      # Fill the event
      other_user = user_fixture(%{email: "other@example.com"})

      participant_fixture(%{
        occurence_id: occurence.id,
        user_id: other_user.id,
        status: "confirmed",
        role: "base"
      })

      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/events/#{occurence.slug}/register")

      lv
      |> form("#participant-form", participant: %{role: "base"})
      |> render_submit()

      flash = assert_redirect(lv, ~p"/events/#{occurence.slug}")
      assert flash["success"] =~ "waitlist"

      # Verify participant was created with waitlist status
      participant = Jamie.Occurences.get_participant(occurence.id, user.id)
      assert participant
      assert participant.status == "waitlist"
    end

    test "updates user profile with registration preferences", %{
      conn: conn,
      user: user,
      creator: creator
    } do
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)

      occurence =
        occurence_fixture(%{
          created_by_id: creator.id,
          date: future_date,
          show_partecipant_list: true,
          slug: "profile-update-event"
        })

      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/events/#{occurence.slug}/register")

      lv
      |> form("#participant-form",
        participant: %{role: "flyer", nickname: "JohnnyTest"}
      )
      |> render_submit()

      # Verify user profile was updated
      updated_user = Jamie.Accounts.get_user!(user.id)
      assert updated_user.preferred_role == "flyer"
      assert updated_user.nickname == "JohnnyTest"
    end
  end

  defp log_in_user(conn, user) do
    token = Jamie.Accounts.generate_user_session_token(user)
    conn |> Phoenix.ConnTest.init_test_session(%{}) |> Plug.Conn.put_session(:user_token, token)
  end
end
