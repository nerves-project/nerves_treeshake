# SPDX-FileCopyrightText: None
#
# SPDX-License-Identifier: CC0-1.0
#
defmodule NervesTreeshake.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nerves-project/nerves_treeshake"

  def project do
    [
      app: :nerves_treeshake,
      version: @version,
      elixir: "~> 1.17",
      deps: deps(),
      nerves: [actions: [__MODULE__]],
      description: "BEAM tree-shaking for Nerves 2 firmware",
      package: package(),
      dialyzer: dialyzer(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:mix]
    ]
  end

  def cli do
    [
      preferred_envs: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs,
        credo: :test
      }
    ]
  end

  # Nerves 2 planning callbacks
  def pre_download(build_plan, _opts), do: build_plan
  def post_extract(build_plan, _opts), do: build_plan

  defdelegate pre_assemble_steps(build_plan, release, opts), to: NervesTreeshake
  defdelegate post_assemble_steps(build_plan, release, opts), to: NervesTreeshake
  defdelegate rootfs_creation_steps(build_plan, release, opts), to: NervesTreeshake
  defdelegate pre_image_creation(build_plan, opts), to: NervesTreeshake
  defdelegate image_creation(build_plan, opts), to: NervesTreeshake
  defdelegate post_image_creation(build_plan, opts), to: NervesTreeshake

  defp deps do
    [
      {:nerves, "~> 2.0.0-pre.5"},
      {:treeshake, github: "software-mansion-labs/elixir-treeshake"},
      {:credo, "~> 1.6", only: :test, runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.26", only: :docs, runtime: false}
    ]
  end

  defp package do
    [
      files: [
        "CHANGELOG.md",
        "lib",
        "LICENSES/*",
        "mix.exs",
        "NOTICE",
        "README.md",
        "REUSE.toml"
      ],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp dialyzer() do
    [
      flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling, :underspecs],
      list_unused_filters: true,
      plt_file: {:no_warn, "_build/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
