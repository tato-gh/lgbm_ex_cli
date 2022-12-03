defmodule LGBMExCli.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/tato-gh/lgbm_ex_cli"

  def project do
    [
      app: :lgbm_ex_cli,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "LGBMExCli",
      description: "microsoft/LightGBM CLI simple wrapper",
      source_url: @source_url,
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      api_reference: false,
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      maintainers: ["ta.to."],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
