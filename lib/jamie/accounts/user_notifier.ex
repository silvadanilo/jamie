defmodule Jamie.Accounts.UserNotifier do
  import Swoosh.Email

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

  def deliver_magic_link(user, url) do
    deliver(user.email, "Your Magic Link to Jamie", """

    ==============================

    Hi #{user.email},

    Click the link below to sign in to your Jamie account:

    #{url}

    This link will expire in 24 hours.

    If you didn't request this link, you can safely ignore this email.

    ==============================
    """)
  end

  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirm your Jamie account", """

    ==============================

    Hi #{user.email},

    Welcome to Jamie! Please confirm your account by visiting the URL below:

    #{url}

    This link will expire in 24 hours.

    If you didn't create an account with us, please ignore this email.

    ==============================
    """)
  end

  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset your Jamie password", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    This link will expire in 24 hours.

    If you didn't request this change, please ignore this email.

    ==============================
    """)
  end

  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update your Jamie email", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    This link will expire in 24 hours.

    If you didn't request this change, please ignore this email.

    ==============================
    """)
  end
end
