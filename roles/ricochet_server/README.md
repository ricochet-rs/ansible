# Ricochet Role

Install and configure [ricochet-server](https://ricochet.rs) via OS packages (systemd) or Docker containers.

## Modes

### systemd

Installs ricochet-server from `.deb` or `.rpm` packages, templates the configuration file to `/var/lib/ricochet/ricochet-config.toml`, and manages the `ricochet-server.service` systemd unit.
Supported on Debian/Ubuntu (amd64) and RHEL/AlmaLinux (x86_64).

### docker

Runs one or more ricochet-server instances as Docker Compose projects.
Each instance gets its own directory under `ricochet_base_dir`, its own config file, and its own container.
This allows running multiple isolated environments (e.g. production and staging) on the same host.

## Usage

### Systemd (single instance)

```yaml
- hosts: ricochet_servers
  roles:
    - role: ricochet.ricochet.ricochet
      ricochet_mode: systemd
      ricochet_version: '0.1.0'
      ricochet_config:
        auth:
          oidc:
            issuer_url: 'https://idp.example.com/'
            client_id: 'ricochet'
            client_secret: '{{ vault_oidc_client_secret }}'
            redirect_url: 'https://ricochet.example.com/oauth/callback'
```

### Docker (multiple instances)

```yaml
- hosts: ricochet_servers
  roles:
    - role: ricochet.ricochet.ricochet
      ricochet_mode: docker
      ricochet_version: '0.1.0'
      ricochet_instances:
        - name: production
          port: 6188
          config:
            auth:
              oidc:
                issuer_url: 'https://idp.example.com/'
                client_id: 'ricochet-prod'
                client_secret: '{{ vault_oidc_secret_prod }}'
                redirect_url: 'https://ricochet.example.com/oauth/callback'
        - name: staging
          port: 6189
          config:
            auth:
              oidc:
                issuer_url: 'https://idp.example.com/'
                client_id: 'ricochet-staging'
                client_secret: '{{ vault_oidc_secret_staging }}'
                redirect_url: 'https://staging.ricochet.example.com/oauth/callback'
          extra_env:
            RUST_LOG: 'debug'
```

## Configuration

The `ricochet_config` dict (systemd mode) and `ricochet_instances[].config` dict (docker mode) are rendered as TOML.
At minimum, OIDC authentication must be configured:

```toml
[auth.oidc]
issuer_url = "https://your-idp.example.com/"
client_id = "your-client-id"
client_secret = "your-client-secret"
redirect_url = "https://your-ricochet-host.example.com/oauth/callback"
```

The server listens on port **6188** by default.

## Data Science System Libraries

Host (systemd) installations require system libraries for R, Python, and Julia to be installed manually.
Container and Kubernetes deployments include these out of the box.

Use the `devxy.data_science_core` collection to install the required interpreters and system libraries:

```yaml
- hosts: ricochet_servers
  roles:
    - role: devxy.data_science_core.syslibs
    - role: ricochet.ricochet.ricochet
      ricochet_mode: systemd
      ricochet_version: '0.1.0'
      ricochet_config:
        auth:
          oidc:
            issuer_url: 'https://idp.example.com/'
            client_id: 'ricochet'
            client_secret: '{{ vault_oidc_client_secret }}'
            redirect_url: 'https://ricochet.example.com/oauth/callback'
```

## Table of content

- [Requirements](#requirements)
- [Default Variables](#default-variables)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

| Variable                    | Default                                                 | Description                                                                                                                                                                                                                                    | Type     | Example                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| --------------------------- | ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ricochet_base_dir`         | `"/opt/ricochet"`                                       | Base directory on the host for docker instance data.<br />Each instance creates a subdirectory under this path.                                                                                                                                | `string` |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `ricochet_config`           |                                                         | Configuration dictionary rendered as TOML to `ricochet-config.toml`.<br />In systemd mode this is written to `/var/lib/ricochet/ricochet-config.toml`.<br />In docker mode, set per-instance config via `ricochet_instances[].config` instead. | `dict`   | ricochet_config:<br /> auth:<br /> oidc:<br /> issuer_url: "https://idp.example.com/"<br /> client_id: "ricochet"<br /> client_secret: "secret"<br /> redirect_url: "https://ricochet.example.com/oauth/callback"                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `ricochet_deploy`           | `true`                                                  | Whether to actually deploy (install packages and start services in systemd mode,<br />or run `docker compose up` in docker mode).<br />Set to `false` to only generate configuration files without deploying.                                  | `bool`   |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `ricochet_docker_image`     | `"ricochetrs/ricochet-server"`                          | Container image to use in docker mode.<br />Can be overridden per instance via `ricochet_instances[].image`.                                                                                                                                   | `string` |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `ricochet_instances`        |                                                         | List of ricochet-server instances to run in docker mode.<br />Each item defines one container with its own config, port, and optional overrides.<br />Multiple instances allow running separate ricochet-server environments on the same host. | `list`   | ricochet_instances:<br /> - name: production<br /> port: 6188<br /> config:<br /> auth:<br /> oidc:<br /> issuer_url: "https://idp.example.com/"<br /> client_id: "ricochet-prod"<br /> client_secret: "secret-prod"<br /> redirect_url: "https://ricochet.example.com/oauth/callback"<br /> - name: staging<br /> port: 6189<br /> config:<br /> auth:<br /> oidc:<br /> issuer_url: "https://idp.example.com/"<br /> client_id: "ricochet-staging"<br /> client_secret: "secret-staging"<br /> redirect_url: "https://staging.ricochet.example.com/oauth/callback"<br /> extra_volumes:<br /> - "/data/staging:/var/lib/ricochet/extra:rw"<br /> extra_env:<br /> RUST_LOG: "debug" |
| `ricochet_mode`             | `"systemd"`                                             | Installation mode.<br />`systemd` installs via OS packages and manages the service with systemd.<br />`docker` runs one or more container instances via Docker Compose.                                                                        | `string` | `"\"docker\""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `ricochet_package_url_base` | `"https://hel1.your-objectstorage.com/ricochet-server"` | Base URL for downloading ricochet-server OS packages.                                                                                                                                                                                          | `string` |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `ricochet_version`          | `"0.6.2"`                                               | Version of ricochet-server to install.<br />Used as the package version (systemd mode) or image tag (docker mode).                                                                                                                             | `string` | `"\"0.1.0\""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

## Dependencies

None.

## License

AGPL-3.0-or-later

## Author

Patrick Schratz
