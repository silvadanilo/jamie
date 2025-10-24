defmodule Jamie.Accounts do
  import Ecto.Query, warn: false
  alias Jamie.Repo

  alias Jamie.Accounts.{User, UserToken}

  ## User registration

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Session

  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Magic links

  def deliver_user_magic_link(user, magic_link_url_fun) when is_function(magic_link_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "magic_link")
    Repo.insert!(user_token)
    Jamie.Accounts.UserNotifier.deliver_magic_link(user, magic_link_url_fun.(encoded_token))
  end

  def get_user_by_magic_link_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "magic_link"),
         %User{} = user <- Repo.one(query) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  def delete_magic_link_tokens_for_user(user) do
    Repo.delete_all(UserToken.by_user_and_contexts_query(user, ["magic_link"]))
  end

  ## User confirmation

  def confirm_user(user) do
    user
    |> User.confirm_changeset()
    |> Repo.update()
  end

  ## User queries

  def get_user!(id), do: Repo.get!(User, id)

  def list_users do
    Repo.all(User)
  end

  def list_users_by_role(role) do
    Repo.all(from u in User, where: u.role == ^role and not u.blocked)
  end

  def change_user_profile(user, attrs \\ %{}) do
    User.profile_changeset(user, attrs)
  end

  def update_user_profile(user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  def block_user(user) do
    user
    |> Ecto.Changeset.change(blocked: true)
    |> Repo.update()
  end

  def unblock_user(user) do
    user
    |> Ecto.Changeset.change(blocked: false)
    |> Repo.update()
  end

  def change_user_role(user, role) when role in ["user", "superadmin"] do
    user
    |> Ecto.Changeset.change(role: role)
    |> Repo.update()
  end

  def superadmin?(user) do
    user.role == "superadmin"
  end

  def blocked?(user) do
    user.blocked
  end
end
