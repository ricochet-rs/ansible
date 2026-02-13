# Variables
venv := "~/venv/ansible-ricochet"
venv_env := "VIRTUAL_ENV=" + venv + " PATH=" + venv + "/bin:$PATH"

lint:
  ansible-lint

ansible-doctor:
    {{ venv_env }} ansible-doctor --version && \
    {{ venv_env }} ansible-doctor roles -vvv -r -f && \
    find roles -name README.md -exec sed -i '' '/<generator object/d' {} \; && \
    prettier -w .

galaxy-publish:
    ansible-galaxy collection build && \
    tarball=$(ls | grep devxy-) && \
    ansible-galaxy collection install $tarball -p /Users/pjs/.ansible/collections && \
    ansible-galaxy collection publish $tarball && \
    rm $tarball

galaxy-build:
    {{ venv_env }} ansible-galaxy collection build -f -vvv

init-venv:
    uv venv --python 3.12 {{ venv }} && \
    uv pip install --python {{ venv }}/bin/python \
        ansible-doctor[ansible-core] \
        molecule-plugins[docker] \
        cryptography \
        distlib

# Molecule testing
molecule-test role distro="alma9":
    cd roles/{{ role }} && \
    {{ venv_env }} MOLECULE_DISTRO={{ distro }} molecule test

molecule-converge role distro="alma9":
    cd roles/{{ role }} && \
    {{ venv_env }} MOLECULE_DISTRO={{ distro }} molecule converge

molecule-verify role:
    cd roles/{{ role }} && \
    {{ venv_env }} molecule verify

molecule-destroy role:
    cd roles/{{ role }} && \
    {{ venv_env }} molecule destroy

molecule-login role:
    cd roles/{{ role }} && \
    {{ venv_env }} molecule login

# Role-specific test shortcuts
test-rhel:
    just molecule-test configure_rhel

test-docker:
    just molecule-test docker

test-certbot:
    just molecule-test certbot

test-node-exporter:
    just molecule-test node_exporter

test-restic:
    just molecule-test restic

test-ricochet:
    just molecule-test ricochet

test-all:
    just test-rhel
    just test-docker
    just test-certbot
    just test-node-exporter
    just test-restic
    just test-ricochet
