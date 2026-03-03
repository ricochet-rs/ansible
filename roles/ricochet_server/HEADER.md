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
