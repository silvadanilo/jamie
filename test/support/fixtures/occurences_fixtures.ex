defmodule Jamie.OccurencesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Jamie.Occurences` context.
  """

  def unique_occurence_title, do: "Jam Event #{System.unique_integer([:positive])}"

  def occurence_fixture(attrs \\ %{}) do
    title = Map.get(attrs, :title, unique_occurence_title())
    date = Map.get(attrs, :date, DateTime.add(DateTime.utc_now(), 7, :day))
    is_private = Map.get(attrs, :is_private, false)

    {:ok, occurence} =
      attrs
      |> Enum.into(%{
        title: title,
        description: "A test jam session",
        location: "Test Studio",
        date: date,
        status: "scheduled",
        is_private: is_private,
        disabled: false,
        show_available_spots: true,
        show_partecipant_list: if(is_private, do: true, else: false)
      })
      |> Jamie.Occurences.create_occurence()

    occurence
  end

  def participant_fixture(attrs \\ %{}) do
    {:ok, participant} =
      attrs
      |> Enum.into(%{
        status: "confirmed",
        role: "base",
        notes: nil,
        nickname: nil,
        name: "Test User",
        email: "test@example.com"
      })
      |> Jamie.Occurences.register_participant()

    participant
  end
end
