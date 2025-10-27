defmodule JamieWeb.OccurenceLive.Index do
  use JamieWeb, :live_view

  alias Jamie.Occurences

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    upcoming = Occurences.list_upcoming_occurences(user)
    past = Occurences.list_past_occurences(user)

    # Add participant stats to each occurrence
    upcoming_with_stats = Enum.map(upcoming, &add_participant_stats/1)
    past_with_stats = Enum.map(past, &add_participant_stats/1)

    socket =
      socket
      |> assign(:upcoming_occurences, upcoming_with_stats)
      |> assign(:past_occurences, past_with_stats)

    {:ok, socket}
  end

  defp add_participant_stats(occurence) do
    base_confirmed = Occurences.count_confirmed_participants(occurence.id, "base")
    flyer_confirmed = Occurences.count_confirmed_participants(occurence.id, "flyer")

    Map.merge(occurence, %{
      base_registered: base_confirmed,
      flyer_registered: flyer_confirmed
    })
  end

  def handle_event("delete", %{"id" => id}, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      {:ok, _} = Occurences.delete_occurence(occurence)

      socket =
        socket
        |> put_flash(:info, "Event deleted successfully")
        |> assign(:upcoming_occurences, Occurences.list_upcoming_occurences(user))
        |> assign(:past_occurences, Occurences.list_past_occurences(user))

      {:noreply, socket}
    else
      {:noreply, put_flash(socket, :error, "You are not authorized to delete this event")}
    end
  end

  def handle_event("copy_share_message", %{"id" => id}, socket) do
    occurence = Occurences.get_occurence!(id)
    user = socket.assigns.current_user

    if Occurences.can_manage_occurence?(occurence, user) do
      message = replace_message_placeholders(occurence.share_message || "", occurence)

      {:noreply,
       socket
       |> put_flash(:info, "Share message copied to clipboard!")
       |> push_event("copy_to_clipboard", %{text: message})}
    else
      {:noreply, put_flash(socket, :error, "You are not authorized to copy this message")}
    end
  end

  defp replace_message_placeholders(message, occurence) do
    message
    |> String.replace("{title}", occurence.title || "")
    |> String.replace("{location}", occurence.location || "")
    |> String.replace("{date}", format_date_italian(occurence.date))
    |> String.replace("{time}", format_time(occurence.date))
    |> String.replace("{datetime}", format_datetime_italian(occurence.date))
    |> String.replace("{cost}", format_cost(occurence.cost))
  end

  defp format_date_italian(date) do
    day = Calendar.strftime(date, "%-d")
    month = get_month_name_italian(date.month)
    year = date.year

    "#{day} #{month} #{year}"
  end

  defp format_time(date) do
    Calendar.strftime(date, "%H:%M")
  end

  defp format_datetime_italian(date) do
    day_name = get_day_name_italian(date)
    day = Calendar.strftime(date, "%-d")
    month = get_month_name_italian(date.month)
    time = Calendar.strftime(date, "%H:%M")

    "#{day_name} #{day} #{month}, dalle #{time}"
  end

  defp get_month_name_italian(month) do
    case month do
      1 -> "gennaio"
      2 -> "febbraio"
      3 -> "marzo"
      4 -> "aprile"
      5 -> "maggio"
      6 -> "giugno"
      7 -> "luglio"
      8 -> "agosto"
      9 -> "settembre"
      10 -> "ottobre"
      11 -> "novembre"
      12 -> "dicembre"
    end
  end

  defp get_day_name_italian(date) do
    day_of_week = Date.day_of_week(DateTime.to_date(date))

    case day_of_week do
      1 -> "Lunedì"
      2 -> "Martedì"
      3 -> "Mercoledì"
      4 -> "Giovedì"
      5 -> "Venerdì"
      6 -> "Sabato"
      7 -> "Domenica"
    end
  end

  defp format_cost(cost) when is_nil(cost), do: "0"

  defp format_cost(%Decimal{} = cost) do
    Decimal.to_string(cost)
  end

  defp format_cost(cost) do
    to_string(cost)
  end
end
