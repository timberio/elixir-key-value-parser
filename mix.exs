defmodule KeyValueParser.Mixfile do
  use Mix.Project

  @version "1.0.5"

  def project do
    [app: :key_value_parser,
     version: @version,
     elixir: ">= 1.2.0",
     deps: deps(),
     package: package(),
     description: "A simple key value parser",
     name: "Key Value Parser",
     docs: [extras: ["README.md"], main: "readme",
            source_ref: "v#{@version}",
            source_url: "https://github.com/timberio/key-value-parser-elixir"]]
  end

  # Configuration for the OTP application
  def application do
    [applications: []]
  end

  def deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    %{licenses: ["Unlicense"],
      maintainers: ["Timber.io development team"],
      links: %{"GitHub" => "https://github.com/timberio/key-value-parser-elixir",
               "Timber" => "https://timber.io"}}
  end
end