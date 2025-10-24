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
      assert length(public_list) == 1
      assert hd(public_list).id == public_occurence.id
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
      assert length(upcoming_list) == 1
      assert hd(upcoming_list).id == upcoming.id
    end
  end
end
