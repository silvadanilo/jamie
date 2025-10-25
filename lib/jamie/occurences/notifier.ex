defmodule Jamie.Occurences.Notifier do
  import Swoosh.Email

  alias Jamie.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Jamie", "noreply@jamapp.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_coorganizer_invitation_existing_user(coorganizer, occurence, invited_by) do
    event_url = "#{JamieWeb.Endpoint.url()}/occurences/#{occurence.id}/edit"

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
end
