defmodule Services.CognitoWrapper do
  @moduledoc """
  Implementation for handling AWS Cognito API behaviour.
  """
  @behaviour Services.Cognito

  alias AWS.CognitoIdentityProvider, as: IdentityProvider

  @doc """
  Registers the user in the specified user pool and creates a user name, password, and user attributes.
  """
  @impl true
  def sign_up(input \\ %{}) do
    IdentityProvider.sign_up(client(), input)
  end

  @doc """
  Confirms registration of a user.
  """
  @impl true
  def confirm_sign_up(input \\ %{}) do
    IdentityProvider.confirm_sign_up(client(), input)
  end

  @doc """
  Initiates the authentication flow, as an administrator. Requires developer credentials.
  """
  @impl true
  def admin_initiate_auth(input \\ %{}) do
    IdentityProvider.admin_initiate_auth(client(), input)
  end

  @doc """
  Gets the user attributes and metadata for a user.
  """
  @impl true
  def get_user(input \\ %{}) do
    IdentityProvider.get_user(client(), input)
  end

  @doc """
  Gets the specified user by user name in a user pool as an administrator. Works on any user. Requires developer credentials.
  """
  @impl true
  def admin_get_user(input \\ %{}) do
    IdentityProvider.admin_get_user(client(), input)
  end

  @doc """
  Changes the password for a specified user in a user pool.
  """
  @impl true
  def change_password(input \\ %{}) do
    IdentityProvider.change_password(client(), input)
  end

  @doc """
  Allows a user to update a specific attribute (one at a time).
  """
  @impl true
  def update_user_attributes(input \\ %{}) do
    IdentityProvider.update_user_attributes(client(), input)
  end

  @doc """
  Calling this API causes a message to be sent to the end user with a confirmation code that is required to change the user's password.
  """
  @impl true
  def forgot_password(input \\ %{}) do
    IdentityProvider.forgot_password(client(), input)
  end

  @doc """
  Allows a user to enter a confirmation code to reset a forgotten password.
  """
  @impl true
  def confirm_forgot_password(input \\ %{}) do
    IdentityProvider.confirm_forgot_password(client(), input)
  end

  defp client do
    %AWS.Client{
      access_key_id: Application.get_env(:aws, :key),
      secret_access_key: Application.get_env(:aws, :secret),
      region: Application.get_env(:aws, :region),
      endpoint: "amazonaws.com"
    }
  end
end
