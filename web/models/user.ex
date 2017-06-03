defmodule Bridge.User do
  @moduledoc """
  A User always belongs to a pod and has a specific role in the pod.
  """

  use Bridge.Web, :model

  alias Comeonin.Bcrypt
  alias Ecto.Changeset

  schema "users" do
    field :state, :integer
    field :role, :integer
    field :email, :string
    field :username, :string
    field :first_name, :string
    field :last_name, :string
    field :time_zone, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :pod, Bridge.Pod

    timestamps()
  end

  @doc """
  The regex format for a username.
  """
  def username_format do
    ~r/^(?>[a-z][a-z0-9-\.]*[a-z0-9])$/
  end

  @doc """
  The regex format for an email address.
  Borrowed from http://www.regular-expressions.info/email.html
  """
  def email_format do
    ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
  end

  @doc """
  Builds a changeset for signup based on the `struct` and `params`.
  This method gets used within the Signup.multi function.
  """
  def signup_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:pod_id, :email, :username, :time_zone, :password])
    |> put_default_time_zone
    |> put_pass_hash
    |> put_change(:state, 0)
    |> put_change(:role, 0)
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp put_default_time_zone(changeset) do
    case changeset do
      %Changeset{changes: %{time_zone: ""}} ->
        put_change(changeset, :time_zone, "UTC")
      %Changeset{changes: %{time_zone: _}} ->
        changeset
      _ ->
        put_change(changeset, :time_zone, "UTC")
    end
  end
end