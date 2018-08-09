Mox.defmock(Services.CognitoMock, for: Services.Cognito)
Application.put_env(:cognitex, :cognito, Services.CognitoMock)

ExUnit.start(exclude: [:skip])
