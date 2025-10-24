defmodule Jamie.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query
  alias Jamie.Accounts.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  @session_validity_in_days 14
  @magic_link_validity_in_days 1

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, Jamie.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserToken{token: token, context: "session", user_id: user.id}}
  end

  def verify_session_token_query(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("magic_link"), do: @magic_link_validity_in_days
  defp days_for_context("confirm"), do: @magic_link_validity_in_days
  defp days_for_context("reset_password"), do: 1

  def by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end

  def by_user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  def by_user_and_contexts_query(user, [_ | _] = contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end
end
