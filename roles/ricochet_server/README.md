# ricochet

Install and configure ricochet-server via systemd or Docker

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [ricochet_base_dir](#ricochet_base_dir)
  - [ricochet_config](#ricochet_config)
  - [ricochet_docker_image](#ricochet_docker_image)
  - [ricochet_instances](#ricochet_instances)
  - [ricochet_mode](#ricochet_mode)
  - [ricochet_package_url_base](#ricochet_package_url_base)
  - [ricochet_version](#ricochet_version)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

- Minimum Ansible version: `2.15`

## Default Variables

### ricochet_base_dir

Base directory on the host for docker instance data.
Each instance creates a subdirectory under this path.

**_Type:_** string<br />

#### Default value

```YAML
ricochet_base_dir: /opt/ricochet
```

### ricochet_config

Configuration dictionary rendered as TOML to `ricochet-config.toml`.
In systemd mode this is written to `/var/lib/ricochet/ricochet-config.toml`.
In docker mode, set per-instance config via `ricochet_instances[].config` instead.

**_Type:_** dict<br />

#### Default value

```YAML
ricochet_config: {}
```

#### Example usage

```YAML
ricochet_config:
  auth:
    oidc:
      issuer_url: "https://idp.example.com/"
      client_id: "ricochet"
      client_secret: "secret"
      redirect_url: "https://ricochet.example.com/oauth/callback"
```

### ricochet_docker_image

Container image to use in docker mode.
Can be overridden per instance via `ricochet_instances[].image`.

**_Type:_** string<br />

#### Default value

```YAML
ricochet_docker_image: ricochetrs/ricochet-server
```

### ricochet_instances

List of ricochet-server instances to run in docker mode.
Each item defines one container with its own config, port, and optional overrides.
Multiple instances allow running separate ricochet-server environments on the same host.

**_Type:_** list<br />

#### Default value

```YAML
ricochet_instances: []
```

#### Example usage

```YAML
ricochet_instances:
  - name: production
    port: 6188
    config:
      auth:
        oidc:
          issuer_url: "https://idp.example.com/"
          client_id: "ricochet-prod"
          client_secret: "secret-prod"
          redirect_url: "https://ricochet.example.com/oauth/callback"
  - name: staging
    port: 6189
    config:
      auth:
        oidc:
          issuer_url: "https://idp.example.com/"
          client_id: "ricochet-staging"
          client_secret: "secret-staging"
          redirect_url: "https://staging.ricochet.example.com/oauth/callback"
    extra_volumes:
      - "/data/staging:/var/lib/ricochet/extra:rw"
    extra_env:
      RUST_LOG: "debug"
```

### ricochet_mode

Installation mode.
`systemd` installs via OS packages and manages the service with systemd.
`docker` runs one or more container instances via Docker Compose.

**_Type:_** string<br />

#### Default value

```YAML
ricochet_mode: systemd
```

#### Example usage

```YAML
"docker"
```

### ricochet_package_url_base

Base URL for downloading ricochet-server OS packages.

**_Type:_** string<br />

#### Default value

```YAML
ricochet_package_url_base: https://hel1.your-objectstorage.com/ricochet-server
```

### ricochet_version

Version of ricochet-server to install.
Used as the package version (systemd mode) or image tag (docker mode).

**_Type:_** string<br />

#### Default value

```YAML
ricochet_version: 0.1.2
```

#### Example usage

```YAML
"0.1.0"
```

## Dependencies

None.

## License

AGPL-3.0-or-later

## Author

Patrick Schratz
