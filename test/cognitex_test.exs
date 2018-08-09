defmodule CognitexTest do
  use ExUnit.Case
  import Mox
  alias Services.CognitoMock

  doctest Cognitex

  # describe "sign_up/3" do
  #   setup :verify_on_exit!

  #   test "should register user with provided data" do

  #     expect(CognitoMock, :sign_up, fn %{email: customer_email} ->
  #       send(self(), {:sign_up, customer_email})
  #       {:ok, %{email: customer_email, id: @customer_id}}
  #     end)

  #     assert {:ok, %{email: ^email, uuid: ^uuid, customer_id: @customer_id}} =
  #              Membership.create_customer(%{uuid: uuid})

  #     assert_received {:create_customer, ^email}
  #   end
  # end

  test "greets the world" do
    assert Cognitex.hello() == :world
  end
end
