defmodule Jamie.Occurences.Notifier do
  import Swoosh.Email

  use JamieWeb, :verified_routes

  alias Jamie.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Jamie", "danilo@html5.it"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_coorganizer_invitation_existing_user(coorganizer, occurence, invited_by) do
    event_url = url(~p"/organizer/occurences/#{occurence.id}/edit")

    deliver(coorganizer.invited_email, "You've been added as a co-organizer", """

    ==============================

    Hi #{coorganizer.invited_email},

    #{invited_by.email} has added you as a co-organizer for the event:

    #{occurence.title}
    Date: #{Calendar.strftime(occurence.date, "%B %d, %Y at %I:%M %p")}

    You can manage this event at:
    #{event_url}

    ==============================
    """)
  end

  def deliver_coorganizer_invitation_new_user(coorganizer, occurence, invited_by, token_url) do
    deliver(coorganizer.invited_email, "You've been invited to co-organize an event", """

    ==============================

    Hi #{coorganizer.invited_email},

    #{invited_by.email} has invited you to co-organize the event:

    #{occurence.title}
    Date: #{Calendar.strftime(occurence.date, "%B %d, %Y at %I:%M %p")}

    To accept this invitation and start co-organizing, please click the link below:

    #{token_url}

    This invitation will expire in 48 hours.

    If you didn't expect this invitation, you can safely ignore this email.

    ==============================
    """)
  end

  def deliver_subscription_email(participant, occurence) do
    email_address = get_participant_email(participant)

    if email_address do
      subject = "Conferma prenotazione: #{occurence.title}"
      body = replace_template_placeholders(occurence.subscription_message, participant, occurence)

      deliver(email_address, subject, body)
    end
  end

  def deliver_cancellation_email(participant, occurence) do
    email_address = get_participant_email(participant)

    if email_address do
      subject = "Cancellazione prenotazione: #{occurence.title}"
      body = replace_template_placeholders(occurence.cancellation_message, participant, occurence)

      deliver(email_address, subject, body)
    end
  end

  defp get_participant_email(%{user: %{email: email}}) when not is_nil(email), do: email
  defp get_participant_email(%{email: email}) when not is_nil(email), do: email
  defp get_participant_email(_), do: nil

  defp replace_template_placeholders(template, participant, occurence) do
    # Format date and time
    date_str = format_date(occurence.date)
    time_str = format_time(occurence.date)
    datetime_str = format_datetime(occurence.date)

    # Format cost
    cost_str = format_cost(occurence.cost)

    # Get participant name
    name = get_participant_name(participant)

    # Get role in Italian
    role_str = get_role_label(participant.role)

    # Build event_url using Phoenix verified routes
    event_url = url(~p"/events/#{occurence.slug}")

    template
    |> String.replace("{title}", occurence.title || "")
    |> String.replace("{date}", date_str)
    |> String.replace("{time}", time_str)
    |> String.replace("{datetime}", datetime_str)
    |> String.replace("{location}", occurence.location || "")
    |> String.replace("{cost}", cost_str)
    |> String.replace("{name}", name)
    |> String.replace("{nickname}", participant.nickname || "")
    |> String.replace("{role}", role_str)
    |> String.replace("{event_url}", event_url)
    |> String.replace("{unsubscribe_url}", event_url)
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y")
  end

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y alle %H:%M")
  end

  defp format_cost(%Decimal{} = cost), do: "#{Decimal.to_float(cost)} €"
  defp format_cost(cost) when is_number(cost), do: "#{cost} €"
  defp format_cost(_), do: "gratuito"

  defp get_participant_name(%{user: %{name: name}}) when not is_nil(name), do: name
  defp get_participant_name(%{nickname: nickname}) when not is_nil(nickname), do: nickname
  defp get_participant_name(%{name: name}) when not is_nil(name), do: name
  defp get_participant_name(_), do: ""

  defp get_role_label("base"), do: "Base"
  defp get_role_label("flyer"), do: "Flyer"
  defp get_role_label(_), do: ""
end
