defmodule JamieWeb.OccurenceLive.Register do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def mount(%{"slug" => slug}, _session, socket) do
    user = socket.assigns.current_user
    occurence = Occurences.get_occurence_by_slug!(slug)

    # Check if event is in the future
    now = DateTime.utc_now()

    if DateTime.compare(occurence.date, now) != :gt do
      socket =
        socket
        |> put_flash(:error, "This event has already passed. Registration is closed.")
        |> push_navigate(to: ~p"/events/#{slug}")

      {:ok, socket}
    else
      # Check if user is already registered (exclude cancelled status)
      existing_participation = Occurences.get_participant(occurence.id, user.id)

      if existing_participation && existing_participation.status != "cancelled" do
        socket =
          socket
          |> put_flash(:info, "You are already registered for this event.")
          |> push_navigate(to: ~p"/events/#{slug}")

        {:ok, socket}
      else
        # Check if event is full
        initial_params = %{
          "role" => user.preferred_role || "base",
          "nickname" => user.nickname || user.name || ""
        }

        case Occurences.check_available_spots(occurence) do
          {:ok, _role} ->
            {:ok,
             socket
             |> assign(:occurence, occurence)
             |> assign(:is_full, false)
             |> assign(:registering, false)
             |> assign(:existing_participation, existing_participation)
             |> assign_form(initial_params)}

          {:error, :full} ->
            {:ok,
             socket
             |> assign(:occurence, occurence)
             |> assign(:is_full, true)
             |> assign(:registering, false)
             |> assign(:existing_participation, existing_participation)
             |> assign_form(initial_params)}
        end
      end
    end
  end

  def handle_event("register", %{"participant" => participant_params}, socket) do
    user = socket.assigns.current_user
    occurence = socket.assigns.occurence

    # Use the role from the form
    role = participant_params["role"] || user.preferred_role || "base"

    # Check if there are available spots for the chosen role
    confirmed_count = Occurences.count_confirmed_participants(occurence.id, role)
    capacity = if role == "base", do: occurence.base_capacity, else: occurence.flyer_capacity

    status =
      cond do
        # Unlimited capacity
        is_nil(capacity) -> "confirmed"
        # Available spots
        confirmed_count < capacity -> "confirmed"
        # Full - add to waitlist
        true -> "waitlist"
      end

    attrs =
      participant_params
      |> Map.put("occurence_id", occurence.id)
      |> Map.put("user_id", user.id)
      |> Map.put("status", status)
      |> Map.put("role", role)

    socket = assign(socket, :registering, true)

    case Occurences.register_or_update_participant(attrs) do
      {:ok, _participant} ->
        # Update user's preferred role and nickname if provided
        user_updates = %{}

        user_updates =
          if participant_params["role"], do: Map.put(user_updates, "preferred_role", role), else: user_updates

        user_updates =
          if participant_params["nickname"] && participant_params["nickname"] != "",
            do: Map.put(user_updates, "nickname", participant_params["nickname"]),
            else: user_updates

        if map_size(user_updates) > 0 do
          Jamie.Accounts.update_user_profile(user, user_updates)
        end

        # TODO: Send email notification
        existing = socket.assigns.existing_participation

        message =
          cond do
            existing && existing.status == "cancelled" ->
              if status == "waitlist" do
                "Your participation has been reactivated! You've been added to the waitlist. We'll notify you if a spot becomes available."
              else
                "Your participation has been reactivated! Registration successful!"
              end

            status == "waitlist" ->
              "You have been added to the waitlist. We'll notify you if a spot becomes available."

            true ->
              "Registration successful! You will receive a confirmation email shortly."
          end

        {:noreply,
         socket
         |> put_flash(:success, message)
         |> push_navigate(to: ~p"/events/#{occurence.slug}")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:registering, false)
         |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, changeset_or_params) do
    form =
      case changeset_or_params do
        %Ecto.Changeset{} = changeset ->
          to_form(changeset)

        params ->
          %Jamie.Occurences.Participant{}
          |> Jamie.Occurences.Participant.changeset(params)
          |> to_form()
      end

    assign(socket, :form, form)
  end
end
