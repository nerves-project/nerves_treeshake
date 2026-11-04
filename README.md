<!--
  SPDX-FileCopyrightText: 2026 Frank Hunleth
  SPDX-License-Identifier: Apache-2.0
-->
# Nerves Treeshake

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/nerves-project/nerves_treeshake/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/nerves-project/nerves_treeshake/tree/main)

Experimental BEAM tree-shaking for Nerves 2 firmware using
[Treeshake](https://github.com/software-mansion-labs/elixir-treeshake).

Tree-shaking removes unused modules and functions from your firmware to reduce
firmware size and boot time. This is done via a static analysis step towards the
end of the firmware creation process.

You're welcome to use this, but be aware that it can easily remove important
functions right now. Please consider contributing improvements back to this
project and the Treeshake library. The goal is that this library eventually
becomes part of the core Nerves tooling.

## Usage

Add a build-time dependency in your project's `mix.exs`:

```elixir
{:nerves_treeshake, github: "nerves-project/nerves_treeshake", runtime: false}
```

Tree-shaking is disabled by default. Enable it in `config/target.exs`, start
with these workarounds for known networking and TLS issues, then test on
hardware:

```elixir
config :nerves_treeshake,
  enabled: true,
  keep_applications: [
    :vintage_net,
    :vintage_net_wifi
  ],
  keep: [
    # Temporary workaround: treeshake cannot follow dynamic RecordCb calls.
    mfa: {:tls_record, :lowest_protocol_version, 1},
    mfa: {:tls_record, :highest_protocol_version, 1},
    # Temporary workaround: treeshake needs to preserve gen_statem's named StateName/3 callbacks.
    behaviour_impls: :gen_statem,
    # Temporary workaround: treeshake needs to follow shared TLS StateName/3 delegation.
    mod: :tls_dtls_client_connection,
    # Temporary workaround: treeshake needs to follow dynamic Connection:close/4 calls.
    mfa: {:tls_gen_connection, :close, 4},
    # Temporary workaround: treeshake needs to follow path_validation_cb/1 module selection.
    mfa: {:tls_handshake_1_3, :path_validation, 10},
    mfa: {:ssl_handshake, :path_validation, 10}
  ],
  debug: true
```

You'll want to add to `:keep_applications` or `:keep` anything that you use at
the IEx prompt but not in your main program.

Setting `:debug` to `true` prints out everything that was removed from the
firmware.
