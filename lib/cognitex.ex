defmodule Cognitex do
  @moduledoc """
  Module for managing user acounts through AWS Cognito service.
  """
  import MapHelpers
  alias Services.CognitoWrapper

  @doc """
  Hello world.

  ## Examples

      iex> Cognitex.hello
      :world

  """
  def hello do
    :world
  end

  @spec sign_up(String.t(), String.t(), [{atom(), String.t()}]) :: {:ok, map()} | {:error, map()}
  def sign_up(email, password, attrs) do
    input =
      %{}
      |> inject_client_id()
      |> inject_user_pool_id()
      |> inject_params(username: email, password: password)
      |> inject_user_attributes(attrs)

    case cognito().sign_up(input) do
      {:ok, request_data, _} -> {:ok, request_data}
      {:error, {status, message}} -> {:error, %{status: status, message: message}}
    end
  end

  @spec confirm(String.t(), String.t()) :: {:ok, map()} | {:error, map()}
  def confirm(email, confirmation_code) do
    input =
      %{}
      |> inject_client_id()
      |> inject_params(username: email, confirmation_code: confirmation_code)

    case cognito().confirm_sign_up(input) do
      {:ok, request_data, _} -> {:ok, request_data}
      {:error, {status, message}} -> {:error, %{status: status, message: message}}
    end
  end

  @spec authenticate(String.t(), String.t()) :: {:ok, map()} | {:error, map()}
  def authenticate(email, password) do
    input =
      %{}
      |> inject_auth_flow()
      |> inject_client_id()
      |> inject_user_pool_id()
      |> inject_auth_parameters(email, password)

    case cognito().admin_initiate_auth(input) do
      {:ok, request_data, _} -> {:ok, request_data}
      {:error, {status, message}} -> {:error, %{status: status, message: message}}
    end
  end

  @spec get_user(String.t()) :: {:ok, map()} | {:error, map()}
  def get_user(token) do
    input =
      %{}
      |> inject_params(access_token: token)

    case cognito().get_user(input) do
      {:ok, request_data, _} -> {:ok, parse_user_attributes(request_data)}
      {:error, {status, message}} -> {:error, %{status: status, message: message}}
    end
  end

  @spec admin_get_user(String.t()) :: {:ok, map()} | {:error, map()}
  def admin_get_user(username) do
    input =
      %{}
      |> inject_user_pool_id()
      |> inject_params(username: username)

    case cognito().admin_get_user(input) do
      {:ok, request_data, _} -> {:ok, parse_user_attributes(request_data)}
      {:error, {status, message}} -> {:error, %{status: status, message: message}}
    end
  end

  @spec change_password(String.t(), String.t(), String.t()) :: {:ok, map()} | {:error, map()}
  def change_password(token, previous_password, proposed_password) do
    input =
      %{}
      |> inject_params(
        access_token: token,
        previous_password: previous_password,
        proposed_password: proposed_password
      )

    case cognito().change_password(input) do
      {:ok, request_data, _} -> {:ok, request_data}
      {:error, {status, message}} -> {:error, %{status: status, message: message}}
    end
  end

  @spec update_user_attributes(String.t(), [{atom(), String.t()}]) ::
          {:ok, map()} | {:error, map()}
  def update_user_attributes(token, attrs) do
    input =
      %{}
      |> inject_params(access_token: token)
      |> inject_user_attributes(attrs)

    case cognito().update_user_attributes(input) do
      {:ok, request_data, _} -> {:ok, request_data}
      {:error, {status, message}} -> {:error, %{status: status, message: message}}
    end
  end

  @spec forgot_password(String.t()) :: {:ok, map()} | {:error, map()}
  def forgot_password(username) do
    input =
      %{}
      |> inject_client_id()
      |> inject_params(username: username)

    case cognito().forgot_password(input) do
      {:ok, request_data, _} -> {:ok, request_data}
      {:error, {status, message}} -> {:error, %{status: status, message: message}}
    end
  end

  @spec confirm_forgot_password(String.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, map()}
  def confirm_forgot_password(code, username, password) do
    input =
      %{}
      |> inject_client_id()
      |> inject_params(confirmation_code: code, username: username, password: password)

    case cognito().confirm_forgot_password(input) do
      {:ok, request_data, _} -> {:ok, request_data}
      {:error, {status, message}} -> {:error, %{status: status, message: message}}
    end
  end

  defp inject_params(map, params) do
    {_, updated_map} =
      Enum.map_reduce(params, map, fn {key, value}, map ->
        {"", Map.put(map, atom_camelize(key), value)}
      end)

    updated_map
  end

  defp inject_user_attributes(map, attrs) do
    map = Map.put(map, :UserAttributes, [])

    {_, updated_map} =
      Enum.map_reduce(attrs, map, fn {key, value}, %{UserAttributes: user_attrs} = map ->
        {"", Map.put(map, :UserAttributes, user_attrs ++ [%{Name: to_string(key), Value: value}])}
      end)

    updated_map
  end

  defp inject_client_id(map) do
    Map.put(map, :ClientId, Application.get_env(:aws, :client_id))
  end

  defp inject_user_pool_id(map) do
    Map.put(map, :UserPoolId, Application.get_env(:aws, :user_pool_id))
  end

  defp inject_auth_flow(map) do
    Map.put(map, :AuthFlow, "ADMIN_NO_SRP_AUTH")
  end

  defp inject_auth_parameters(map, email, password) do
    Map.put(map, :AuthParameters, %{USERNAME: email, PASSWORD: password})
  end

  defp atom_camelize(atom) do
    atom |> Atom.to_string() |> Macro.camelize() |> String.to_atom()
  end

  defp parse_user_attributes(attrs) do
    parsed =
      attrs
      |> underscore_keys
      |> atomize_keys
      |> Map.get(:user_attributes)
      |> Enum.into(%{}, fn %{name: name, value: value} -> {String.to_atom(name), value} end)

    %{user_attributes: parsed}
  end

  defp cognito(), do: Application.get_env(:cognitex, :cognito, CognitoWrapper)
end
