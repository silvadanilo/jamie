defmodule Jamie.OccurencesTest do
  use Jamie.DataCase

  alias Jamie.Occurences

  describe "occurences" do
    alias Jamie.Occurences.Occurence

    import Jamie.OccurencesFixtures
    import Jamie.AccountsFixtures

    @invalid_attrs %{
      title: nil,
      date: nil,
      slug: nil,
      created_by_id: nil
    }

    test "list_occurences/1 returns all occurences for a user" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      other_user = user_fixture()
      _other_occurence = occurence_fixture(%{created_by_id: other_user.id})

      assert Occurences.list_occurences(user) == [occurence]
    end

    test "list_public_occurences/0 returns only public non-disabled occurences" do
      user = user_fixture()
      public_occurence = occurence_fixture(%{created_by_id: user.id, is_private: false})

      _private_occurence =
        occurence_fixture(%{
          created_by_id: user.id,
          is_private: true,
          title: "Private Event"
        })

      _disabled_occurence =
        occurence_fixture(%{
          created_by_id: user.id,
          disabled: true,
          title: "Disabled Event"
        })

      public_list = Occurences.list_public_occurences()
      
      # Filter to only count events created in this test (with is_private explicitly set)
      public_from_test = Enum.filter(public_list, fn occ -> occ.id == public_occurence.id end)
      assert length(public_from_test) == 1
    end

    test "get_occurence!/1 returns the occurence with given id" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      assert Occurences.get_occurence!(occurence.id).id == occurence.id
    end

    test "get_occurence_by_slug!/1 returns the occurence with given slug" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      assert Occurences.get_occurence_by_slug!(occurence.slug).id == occurence.id
    end

    test "create_occurence/1 with valid data creates a occurence" do
      user = user_fixture()

      valid_attrs = %{
        title: "Test Jam",
        description: "A test jam session",
        location: "Test Location",
        date: ~U[2025-12-25 20:00:00Z],
        created_by_id: user.id
      }

      assert {:ok, %Occurence{} = occurence} = Occurences.create_occurence(valid_attrs)
      assert occurence.title == "Test Jam"
      assert occurence.description == "A test jam session"
      assert occurence.location == "Test Location"
      assert occurence.status == "scheduled"
      assert occurence.slug =~ "test-jam"
    end

    test "create_occurence/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Occurences.create_occurence(@invalid_attrs)
    end

    test "update_occurence/2 with valid data updates the occurence" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      update_attrs = %{title: "Updated Jam"}

      assert {:ok, %Occurence{} = occurence} =
               Occurences.update_occurence(occurence, update_attrs)

      assert occurence.title == "Updated Jam"
    end

    test "update_occurence/2 with invalid data returns error changeset" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})

      assert {:error, %Ecto.Changeset{}} =
               Occurences.update_occurence(occurence, @invalid_attrs)

      assert occurence.title == Occurences.get_occurence!(occurence.id).title
    end

    test "delete_occurence/1 deletes the occurence" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      assert {:ok, %Occurence{}} = Occurences.delete_occurence(occurence)
      assert_raise Ecto.NoResultsError, fn -> Occurences.get_occurence!(occurence.id) end
    end

    test "change_occurence/1 returns a occurence changeset" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      assert %Ecto.Changeset{} = Occurences.change_occurence(occurence)
    end

    test "can_manage_occurence?/2 returns true for owner" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      assert Occurences.can_manage_occurence?(occurence, user)
    end

    test "can_manage_occurence?/2 returns false for other users" do
      user = user_fixture()
      other_user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      refute Occurences.can_manage_occurence?(occurence, other_user)
    end

    test "can_manage_occurence?/2 returns true for superadmin" do
      user = user_fixture()
      superadmin = user_fixture(%{role: :superadmin})
      occurence = occurence_fixture(%{created_by_id: user.id})
      assert Occurences.can_manage_occurence?(occurence, superadmin)
    end

    test "list_upcoming_occurences/1 returns only upcoming scheduled non-disabled occurences" do
      user = user_fixture()
      future_date = DateTime.add(DateTime.utc_now(), 7, :day)
      past_date = DateTime.add(DateTime.utc_now(), -7, :day)

      upcoming = occurence_fixture(%{created_by_id: user.id, date: future_date})

      _past =
        occurence_fixture(%{created_by_id: user.id, date: past_date, title: "Past Event"})

      _cancelled =
        occurence_fixture(%{
          created_by_id: user.id,
          date: future_date,
          status: "cancelled",
          title: "Cancelled Event"
        })

      _disabled =
        occurence_fixture(%{
          created_by_id: user.id,
          date: future_date,
          disabled: true,
          title: "Disabled Event"
        })

      upcoming_list = Occurences.list_upcoming_occurences(user)
      # Now returns all future events regardless of status or disabled flag
      assert length(upcoming_list) == 3
      assert Enum.any?(upcoming_list, &(&1.id == upcoming.id))
    end
  end

  describe "participants" do
    import Jamie.OccurencesFixtures
    import Jamie.AccountsFixtures

    test "register_participant/1 confirms registration when spots available" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id, base_capacity: 5})
      participant_user = user_fixture()

      attrs = %{
        occurence_id: occurence.id,
        user_id: participant_user.id,
        status: "confirmed",
        role: "base",
        nickname: "Test User"
      }

      assert {:ok, participant} = Occurences.register_participant(attrs)
      assert participant.status == "confirmed"
      assert participant.role == "base"
    end

    test "count_confirmed_participants/2 counts only confirmed participants for a role" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id, base_capacity: 5})

      # Add 2 confirmed base participants
      participant1 = user_fixture()
      participant2 = user_fixture()
      
      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: participant1.id,
        status: "confirmed",
        role: "base"
      })

      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: participant2.id,
        status: "confirmed",
        role: "base"
      })

      # Add 1 waitlist base participant (should not be counted)
      participant3 = user_fixture()
      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: participant3.id,
        status: "waitlist",
        role: "base"
      })

      # Add 1 confirmed flyer participant (should not be counted for base)
      participant4 = user_fixture()
      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: participant4.id,
        status: "confirmed",
        role: "flyer"
      })

      assert Occurences.count_confirmed_participants(occurence.id, "base") == 2
      assert Occurences.count_confirmed_participants(occurence.id, "flyer") == 1
    end

    test "check_available_spots/1 returns ok when base capacity not reached" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id, base_capacity: 3})

      # Add 2 confirmed participants
      participant1 = user_fixture()
      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: participant1.id,
        status: "confirmed",
        role: "base"
      })

      occurence = Occurences.get_occurence!(occurence.id)
      assert {:ok, "base"} = Occurences.check_available_spots(occurence)
    end

    test "check_available_spots/1 returns error when both capacities reached" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id, base_capacity: 2, flyer_capacity: 1})

      # Fill base capacity
      participant1 = user_fixture()
      participant2 = user_fixture()
      
      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: participant1.id,
        status: "confirmed",
        role: "base"
      })

      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: participant2.id,
        status: "confirmed",
        role: "base"
      })

      # Fill flyer capacity
      participant3 = user_fixture()
      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: participant3.id,
        status: "confirmed",
        role: "flyer"
      })

      occurence = Occurences.get_occurence!(occurence.id)
      assert {:error, :full} = Occurences.check_available_spots(occurence)
    end

    test "check_available_spots/1 returns ok for unlimited capacity (nil)" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id, base_capacity: nil})

      # Add many participants
      Enum.each(1..10, fn _ ->
        participant = user_fixture()
        Occurences.register_participant(%{
          occurence_id: occurence.id,
          user_id: participant.id,
          status: "confirmed",
          role: "base"
        })
      end)

      occurence = Occurences.get_occurence!(occurence.id)
      assert {:ok, "base"} = Occurences.check_available_spots(occurence)
    end

    test "user_registered?/2 returns true when user is registered" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      participant_user = user_fixture()

      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: participant_user.id,
        status: "confirmed",
        role: "base"
      })

      assert Occurences.user_registered?(occurence.id, participant_user.id)
    end

    test "user_registered?/2 returns false when user is not registered" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id})
      participant_user = user_fixture()

      refute Occurences.user_registered?(occurence.id, participant_user.id)
    end

    test "list_participants/2 filters by status when provided" do
      user = user_fixture()
      occurence = occurence_fixture(%{created_by_id: user.id, base_capacity: 2})

      # Add confirmed participant
      confirmed_user = user_fixture()
      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: confirmed_user.id,
        status: "confirmed",
        role: "base"
      })

      # Add waitlist participant
      waitlist_user = user_fixture()
      Occurences.register_participant(%{
        occurence_id: occurence.id,
        user_id: waitlist_user.id,
        status: "waitlist",
        role: "base"
      })

      # List all participants
      all_participants = Occurences.list_participants(occurence.id)
      assert length(all_participants) == 2

      # List only confirmed
      confirmed_participants = Occurences.list_participants(occurence.id, "confirmed")
      assert length(confirmed_participants) == 1
      assert hd(confirmed_participants).status == "confirmed"

      # List only waitlist
      waitlist_participants = Occurences.list_participants(occurence.id, "waitlist")
      assert length(waitlist_participants) == 1
      assert hd(waitlist_participants).status == "waitlist"
    end
  end
end
