defmodule CognitexTest do
  use ExUnit.Case
  import Mox
  alias Services.CognitoMock

  setup do
    Application.put_env(:aws, :client_id, "client_id")
    Application.put_env(:aws, :user_pool_id, "user_pool_id")
    :ok
  end

  describe "sign_up/3" do
    setup :verify_on_exit!

    setup do
      {:ok,
       %{
         username: "john.smith@example.com",
         password: "test123",
         attrs: [name: "John", family_name: "Smith"]
       }}
    end

    test "should register user with correct data", %{
      username: username,
      password: password,
      attrs: [name: name, family_name: family_name] = attrs
    } do
      cognito_input = %{
        ClientId: "client_id",
        Password: password,
        UserAttributes: [
          %{Name: "name", Value: name},
          %{Name: "family_name", Value: family_name}
        ],
        UserPoolId: "user_pool_id",
        Username: username
      }

      cognito_output = %{
        "CodeDeliveryDetails_duap" => %{
          "AttributeName" => "email",
          "DeliveryMedium" => "EMAIL",
          "Destination" => "j***@e***.co"
        },
        "UserConfirmed" => false,
        "UserSub" => "uuid"
      }

      expect(CognitoMock, :sign_up, fn cognito_input ->
        send(self(), {:sign_up, cognito_input})
        {:ok, cognito_output, %{}}
      end)

      assert {:ok, ^cognito_output} = Cognitex.sign_up(username, password, attrs)

      assert_received {:sign_up, ^cognito_input}
    end

    test "should fail when user already exists for provided username and return error", %{
      username: username,
      password: password,
      attrs: [name: name, family_name: family_name] = attrs
    } do
      cognito_input = %{
        ClientId: "client_id",
        Password: password,
        UserAttributes: [
          %{Name: "name", Value: name},
          %{Name: "family_name", Value: family_name}
        ],
        UserPoolId: "user_pool_id",
        Username: username
      }

      cognito_status = "UsernameExistsException"
      cognito_message = "An account with the given email already exists."

      expect(CognitoMock, :sign_up, fn cognito_input ->
        send(self(), {:sign_up, cognito_input})
        {:error, {cognito_status, cognito_message}}
      end)

      assert {:error, %{message: ^cognito_message, status: ^cognito_status}} =
               Cognitex.sign_up(username, password, attrs)

      assert_received {:sign_up, ^cognito_input}
    end
  end

  describe "confirm/2" do
    setup :verify_on_exit!

    setup do
      {:ok, %{username: "john.smith@example.com", confirmation_code: "065045"}}
    end

    test "should confirm user registration with a valid confirmation code", %{
      username: username,
      confirmation_code: confirmation_code
    } do
      cognito_input = %{
        ClientId: "client_id",
        Username: username,
        ConfirmationCode: confirmation_code
      }

      expect(CognitoMock, :confirm_sign_up, fn cognito_input ->
        send(self(), {:confirm_sign_up, cognito_input})
        {:ok, %{}, ""}
      end)

      assert {:ok, %{}} = Cognitex.confirm(username, confirmation_code)

      assert_received {:confirm_sign_up, ^cognito_input}
    end

    test "should fail when user is already confirmed and return error", %{
      username: username,
      confirmation_code: confirmation_code
    } do
      cognito_input = %{
        ClientId: "client_id",
        Username: username,
        ConfirmationCode: confirmation_code
      }

      cognito_status = "NotAuthorizedException"
      cognito_message = "User cannot be confirm. Current status is CONFIRMED"

      expect(CognitoMock, :confirm_sign_up, fn cognito_input ->
        send(self(), {:confirm_sign_up, cognito_input})
        {:error, {cognito_status, cognito_message}}
      end)

      assert {:error, %{message: ^cognito_message, status: ^cognito_status}} =
               Cognitex.confirm(username, confirmation_code)

      assert_received {:confirm_sign_up, ^cognito_input}
    end
  end

  describe "authenticate/2" do
    setup :verify_on_exit!

    setup do
      {:ok, %{username: "john.smith@example.com", password: "test123"}}
    end

    test "should authenticate user with a valid credentioals", %{
      username: username,
      password: password
    } do
      cognito_input = %{
        AuthFlow: "ADMIN_NO_SRP_AUTH",
        AuthParameters: %{PASSWORD: password, USERNAME: username},
        ClientId: "client_id",
        UserPoolId: "user_pool_id"
      }

      cognito_output = %{
        "AuthenticationResult" => %{
          "AccessToken" => "access_token",
          "ExpiresIn" => 3600,
          "IdToken" => "id_token",
          "RefreshToken" => "refresh_token",
          "TokenType" => "Bearer"
        },
        "ChallengeParameters" => %{}
      }

      expect(CognitoMock, :admin_initiate_auth, fn cognito_input ->
        send(self(), {:admin_initiate_auth, cognito_input})
        {:ok, cognito_output, ""}
      end)

      assert {:ok, ^cognito_output} = Cognitex.authenticate(username, password)

      assert_received {:admin_initiate_auth, ^cognito_input}
    end

    test "should fail when incorrect credentials are provided and return error", %{
      username: username,
      password: password
    } do
      cognito_input = %{
        AuthFlow: "ADMIN_NO_SRP_AUTH",
        AuthParameters: %{PASSWORD: password, USERNAME: username},
        ClientId: "client_id",
        UserPoolId: "user_pool_id"
      }

      cognito_status = "NotAuthorizedException"
      cognito_message = "Incorrect username or password."

      expect(CognitoMock, :admin_initiate_auth, fn cognito_input ->
        send(self(), {:admin_initiate_auth, cognito_input})
        {:error, {cognito_status, cognito_message}}
      end)

      assert {:error, %{message: ^cognito_message, status: ^cognito_status}} =
               Cognitex.authenticate(username, password)

      assert_received {:admin_initiate_auth, ^cognito_input}
    end
  end

  describe "get_user/1" do
    setup :verify_on_exit!

    setup do
      {:ok,
       %{
         token: "token",
         email: "john.smith@example.com",
         name: "John",
         family_name: "Smith",
         sub: "sub_id"
       }}
    end

    test "should return user data with provided token", %{
      token: token,
      email: email,
      name: name,
      family_name: family_name,
      sub: sub
    } do
      cognito_input = %{
        AccessToken: token
      }

      cognito_output = %{
        "UserAttributes" => [
          %{"Name" => "sub", "Value" => sub},
          %{"Name" => "email_verified", "Value" => "true"},
          %{"Name" => "name", "Value" => name},
          %{"Name" => "family_name", "Value" => family_name},
          %{"Name" => "email", "Value" => email}
        ],
        "Username" => sub
      }

      expect(CognitoMock, :get_user, fn cognito_input ->
        send(self(), {:get_user, cognito_input})
        {:ok, cognito_output, ""}
      end)

      assert {:ok, user_attributes} = Cognitex.get_user(token)

      assert %{
               user_attributes: %{
                 email: ^email,
                 email_verified: "true",
                 family_name: ^family_name,
                 name: ^name,
                 sub: ^sub
               }
             } = user_attributes

      assert_received {:get_user, ^cognito_input}
    end

    test "should fail when incorrect token provided and return error", %{token: token} do
      cognito_input = %{
        AccessToken: token
      }

      cognito_status = "NotAuthorizedException"
      cognito_message = "Could not verify signature for Access Token"

      expect(CognitoMock, :get_user, fn cognito_input ->
        send(self(), {:get_user, cognito_input})
        {:error, {cognito_status, cognito_message}}
      end)

      assert {:error, %{message: ^cognito_message, status: ^cognito_status}} =
               Cognitex.get_user(token)

      assert_received {:get_user, ^cognito_input}
    end
  end

  describe "admin_get_user/1" do
    setup :verify_on_exit!

    setup do
      {:ok,
       %{username: "john.smith@example.com", name: "John", family_name: "Smith", sub: "sub_id"}}
    end

    test "should return user data with provided username", %{
      username: username,
      name: name,
      family_name: family_name,
      sub: sub
    } do
      cognito_input = %{
        UserPoolId: "user_pool_id",
        Username: username
      }

      cognito_output = %{
        "UserAttributes" => [
          %{"Name" => "sub", "Value" => sub},
          %{"Name" => "email_verified", "Value" => "true"},
          %{"Name" => "name", "Value" => name},
          %{"Name" => "family_name", "Value" => family_name},
          %{"Name" => "email", "Value" => username}
        ],
        "Username" => sub
      }

      expect(CognitoMock, :admin_get_user, fn cognito_input ->
        send(self(), {:admin_get_user, cognito_input})
        {:ok, cognito_output, ""}
      end)

      assert {:ok, user_attributes} = Cognitex.admin_get_user(username)

      assert %{
               user_attributes: %{
                 email: ^username,
                 email_verified: "true",
                 family_name: ^family_name,
                 name: ^name,
                 sub: ^sub
               }
             } = user_attributes

      assert_received {:admin_get_user, ^cognito_input}
    end

    test "should fail when incorrect username provided and return error", %{username: username} do
      cognito_input = %{
        UserPoolId: "user_pool_id",
        Username: username
      }

      cognito_status = "UserNotFoundException"
      cognito_message = "User does not exist."

      expect(CognitoMock, :admin_get_user, fn cognito_input ->
        send(self(), {:admin_get_user, cognito_input})
        {:error, {cognito_status, cognito_message}}
      end)

      assert {:error, %{message: ^cognito_message, status: ^cognito_status}} =
               Cognitex.admin_get_user(username)

      assert_received {:admin_get_user, ^cognito_input}
    end
  end

  describe "change_password/3" do
    setup :verify_on_exit!

    setup do
      {:ok, %{token: "token", previous_password: "Test123", proposed_password: "Test321"}}
    end

    test "should change user password with provided previous and new password", %{
      token: token,
      previous_password: previous_password,
      proposed_password: proposed_password
    } do
      cognito_input = %{
        AccessToken: token,
        PreviousPassword: previous_password,
        ProposedPassword: proposed_password
      }

      expect(CognitoMock, :change_password, fn cognito_input ->
        send(self(), {:change_password, cognito_input})
        {:ok, %{}, ""}
      end)

      assert {:ok, %{}} = Cognitex.change_password(token, previous_password, proposed_password)

      assert_received {:change_password, ^cognito_input}
    end

    test "should fail when incorrect username provided and return error", %{
      token: token,
      previous_password: previous_password,
      proposed_password: proposed_password
    } do
      cognito_input = %{
        AccessToken: token,
        PreviousPassword: previous_password,
        ProposedPassword: proposed_password
      }

      cognito_status = "NotAuthorizedException"
      cognito_message = "Incorrect username or password."

      expect(CognitoMock, :change_password, fn cognito_input ->
        send(self(), {:change_password, cognito_input})
        {:error, {cognito_status, cognito_message}}
      end)

      assert {:error, %{message: ^cognito_message, status: ^cognito_status}} =
               Cognitex.change_password(token, previous_password, proposed_password)

      assert_received {:change_password, ^cognito_input}
    end
  end

  describe "update_user_attributes/2" do
    setup :verify_on_exit!

    setup do
      {:ok, %{token: "token", attrs: [name: "John", family_name: "Smith"]}}
    end

    test "should update user attributes with provided data", %{
      token: token,
      attrs: [name: name, family_name: family_name] = attrs
    } do
      cognito_input = %{
        AccessToken: token,
        UserAttributes: [
          %{Name: "name", Value: name},
          %{Name: "family_name", Value: family_name}
        ]
      }

      expect(CognitoMock, :update_user_attributes, fn cognito_input ->
        send(self(), {:update_user_attributes, cognito_input})
        {:ok, %{}, ""}
      end)

      assert {:ok, %{}} = Cognitex.update_user_attributes(token, attrs)

      assert_received {:update_user_attributes, ^cognito_input}
    end

    test "should fail when incorrect token provided and return error", %{
      token: token,
      attrs: [name: name, family_name: family_name] = attrs
    } do
      cognito_input = %{
        AccessToken: token,
        UserAttributes: [
          %{Name: "name", Value: name},
          %{Name: "family_name", Value: family_name}
        ]
      }

      cognito_status = "NotAuthorizedException"
      cognito_message = "Invalid Access Token"

      expect(CognitoMock, :update_user_attributes, fn cognito_input ->
        send(self(), {:update_user_attributes, cognito_input})
        {:error, {cognito_status, cognito_message}}
      end)

      assert {:error, %{message: ^cognito_message, status: ^cognito_status}} =
               Cognitex.update_user_attributes(token, attrs)

      assert_received {:update_user_attributes, ^cognito_input}
    end
  end

  describe "forgot_password/1" do
    setup :verify_on_exit!

    setup do
      {:ok, %{username: "john.smith@example.com"}}
    end

    test "should request forgot password with provided username", %{username: username} do
      cognito_input = %{
        ClientId: "client_id",
        Username: username
      }

      cognito_output = %{
        "CodeDeliveryDetails" => %{
          "AttributeName" => "email",
          "DeliveryMedium" => "EMAIL",
          "Destination" => "j***@e***.co"
        }
      }

      expect(CognitoMock, :forgot_password, fn cognito_input ->
        send(self(), {:forgot_password, cognito_input})
        {:ok, cognito_output, ""}
      end)

      assert {:ok, ^cognito_output} = Cognitex.forgot_password(username)

      assert_received {:forgot_password, ^cognito_input}
    end

    test "should fail when provided username does not exist and return error", %{
      username: username
    } do
      cognito_input = %{
        ClientId: "client_id",
        Username: username
      }

      cognito_status = "UserNotFoundException"
      cognito_message = "Username/client id combination not found."

      expect(CognitoMock, :forgot_password, fn cognito_input ->
        send(self(), {:forgot_password, cognito_input})
        {:error, {cognito_status, cognito_message}}
      end)

      assert {:error, %{message: ^cognito_message, status: ^cognito_status}} =
               Cognitex.forgot_password(username)

      assert_received {:forgot_password, ^cognito_input}
    end
  end

  describe "confirm_forgot_password/3" do
    setup :verify_on_exit!

    setup do
      {:ok,
       %{username: "john.smith@example.com", confirmation_code: "123456", password: "Test456"}}
    end

    test "should request forgot password with provided username", %{
      username: username,
      confirmation_code: confirmation_code,
      password: password
    } do
      cognito_input = %{
        ClientId: "client_id",
        ConfirmationCode: confirmation_code,
        Password: password,
        Username: username
      }

      cognito_output = %{
        "CodeDeliveryDetails" => %{
          "AttributeName" => "email",
          "DeliveryMedium" => "EMAIL",
          "Destination" => "j***@e***.co"
        }
      }

      expect(CognitoMock, :confirm_forgot_password, fn cognito_input ->
        send(self(), {:confirm_forgot_password, cognito_input})
        {:ok, cognito_output, ""}
      end)

      assert {:ok, ^cognito_output} =
               Cognitex.confirm_forgot_password(confirmation_code, username, password)

      assert_received {:confirm_forgot_password, ^cognito_input}
    end

    test "should fail when provided confirmation code is invalid and return error", %{
      username: username,
      confirmation_code: confirmation_code,
      password: password
    } do
      cognito_input = %{
        ClientId: "client_id",
        ConfirmationCode: confirmation_code,
        Password: password,
        Username: username
      }

      cognito_status = "ExpiredCodeException"
      cognito_message = "Invalid code provided, please request a code again."

      expect(CognitoMock, :confirm_forgot_password, fn cognito_input ->
        send(self(), {:confirm_forgot_password, cognito_input})
        {:error, {cognito_status, cognito_message}}
      end)

      assert {:error, %{message: ^cognito_message, status: ^cognito_status}} =
               Cognitex.confirm_forgot_password(confirmation_code, username, password)

      assert_received {:confirm_forgot_password, ^cognito_input}
    end
  end
end
