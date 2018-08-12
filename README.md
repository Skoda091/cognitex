# Cognitex

A simple library to handle user management over [AWS Cognito service](https://aws.amazon.com/cognito/).

The following functionality is covered;

* User registration
* Confirm registration (with the confirmation code received from AWS, by email)
* User authenntication
* Fetch user data by access token
* Fetch user data by username
* Change user password
* Update user attributes
* Reset a forgotten password

Online documentation is available [here]().

## Installation

To use `cognitex` with your projects, edit your `mix.exs` file to add it as a dependency:

```elixir
def deps do
  [
    {:cognitex, "~> 0.1.0"}
  ]
end
```

## Configuration

An example config might look like this:

```elixir
config :aws,
  key: "<AWS_ACCESS_KEY_ID>",
  secret: "<AWS_SECRET_ACCESS_KEY>",
  region: "<AWS_REGION>",
  client_id: "<AWS_CLIENT_ID>",
  user_pool_id: "<AWS_USER_POOL_ID>"
```

## Set up AWS Cognito with the correct configuration
First we will set up a new AWS Cognito user pool with the correct configuration.

1. Visit your AWS console and go to the AWS Cognito service. Click on "Manage your User Pools" and click "Create a User Pool".
2. Specify a name for your pool and click "Review Defaults".
3. Optional: edit the password policy to remove some of the requirements. If you are just testing, using simple passwords will make it easier.
4. Click the "edit client" link. Specify a name for your app and be sure to *disable* the client secret and *enable* the `ADMIN_NO_SRP_AUTH` option.
5. Click "Create pool". Take note of the *Pool Id* at the top of the page and click on the apps page. Here, take note of the *App client id*.


### References

* Official Cognito [API reference](http://docs.aws.amazon.com/cognitoidentity/latest/APIReference/Welcome.html):

### Licensing, thanks

This workflow is released under the [MIT License](https://opensource.org/licenses/MIT).

It is based on:
* [cognito-phx](https://gitlab.com/azohra/cognito-phx/)
* [aws-elixir](https://github.com/aws-beam/aws-elixir)

