# ricochet.ricochet

Ansible collection for deploying and managing [ricochet-server](https://ricochet.rs).

## Roles

| Role                        | Description                                                 |
| --------------------------- | ----------------------------------------------------------- |
| [ricochet](roles/ricochet/) | Install and configure ricochet-server via systemd or Docker |

## Installation

```bash
ansible-galaxy collection install ricochet.ricochet
```

## Dependencies

- `ansible.posix` >= 1.0.0
- `community.general` >= 1.0.0
- `community.docker` >= 3.0.0

## License

AGPL-3.0-or-later
