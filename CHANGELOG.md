# Changelog

## v0.1.0

* Initial release
* Basic functionality:
  * `Cognitex.sign_up/3` - Registers the user in the specified user pool and creates a user name, password, and user attributes defined in AWS Cognito service.
  * `Cognitex.confirm_sign_up/2` - Confirms registration of a user.
  * `Cognitex.admin_initiate_auth/2` - Authenticates registered user with credentials.
  * `Cognitex.get_user/1` - Gets the user attributes and metadata for a user by access token.
  * `Cognitex.admin_get_user/1` - Gets the specified user by username in a user pool as an administrator. Works on any user.
  * `Cognitex.change_password/3` - Changes the password for a specified user in a user pool.
  * `Cognitex.update_user_attributes/2` - Allows a user to update a specific attribute.
  * `Cognitex.forgot_password/1` - Calling this API causes a message to be sent to the end user with a confirmation code that is required to change the user's password.
  * `Cognitex.confirm_forgot_password/3` - Allows a user to enter a confirmation code to reset a forgotten password.
