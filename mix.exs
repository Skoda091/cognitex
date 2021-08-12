defmodule Cognitex.MixProject do
  use Mix.Project

  def project do
    [
      app: :cognitex,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Library for managing user acounts through AWS Cognito service.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Adam Skołuda"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Skoda091/cognitex"}
    ]
  end

  defp deps do
    [
      {:aws, "~> 0.8.0"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: :dev},
      {:credo, "~> 0.10.0", only: :dev, runtime: false},
      {:mox, "~> 0.4", only: :test}
    ]
  end
end
