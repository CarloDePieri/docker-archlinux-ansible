# Docker Archlinux for testing Ansible playbooks

An updated, systemd-enabled Archlinux docker image (based on my [docker-archlinux-systemd](https://hub.docker.com/r/carlodepieri/docker-archlinux-systemd))
useful for testing ansible playbook.

## Usage: testing with Molecule

A [working Docker installation](https://docs.docker.com/engine/install/) is needed.
Images on Docker Hub gets automatically built at least once a month by GitHub Actions.

A [working molecule installation](https://molecule.readthedocs.io/en/latest/installation.html) is also needed.

Running `molecule init` will quick-start a project.
Now edit the `'platforms'` section inside the file `molecule/default/molecule.yml`.

```yml
platforms:
  - name: cdp-arch-ansible
    image: carlodepieri/docker-archlinux-ansible
    command: ${MOLECULE_DOCKER_COMMAND:-""}
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:ro
    privileged: true
    pre_build_image: true
```

This will make molecule pull the image from Dockerhub and start the container in a way that
supports systemd and ansible (mounting cgroup and running with privileged).

> **Important**: these steps are necessary to make systemd behave,
> but make sure to understand [the security concerns involved](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).

Remember that, after the container has been created (for example by `molecule converge`),
a shell to inspect the container can be obtained with:

```bash
docker exec -it cdp-arch-ansible env TERM=xterm bash
```

## Devs: building the image from GitHub

Clone the repo first with:

```bash
git clone git@github.com:CarloDePieri/docker-archlinux-ansible.git
```

### Building the image

A [working Docker installation](https://docs.docker.com/engine/install/) is needed.
Then run:

```bash
docker build -t carlodepieri/docker-archlinux-ansible .
```

or, for convenience:

```bash
make
```

This will build the image. The command `docker images` can then be used to verify a
successful build.

### Creating a new container

Run:

```bash
docker run --name=cdp-arch-ansible --detach --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro --volume=`pwd`:/etc/ansible/roles/role_under_test:ro carlodepieri/docker-archlinux-ansible
```

or, for convenience:

```bash
make run-container
```

This should start the container, which can should be then visible in `docker ps`.
It will also bind the current working directory inside the container, which can be handy to quickly test a playbook (like the included `test.yml`).

### Testing the container

Run:

```bash
docker exec -i cdp-arch-ansible env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/test.yml --syntax-check
```

or, for convenience:

```bash
make test
```

### Connecting to the container

Run:

```bash
docker exec -it cdp-arch-ansible env TERM=xterm bash
```

or, for convenience:

```bash
make shell
```

### Testing the CI loop

[Act](https://github.com/nektos/act) can be used to simulate locally the GitHub Actions loop. Keep in mind that this will use its [full image](https://hub.docker.com/r/nektos/act-environments-ubuntu/tags), which is really heavy (>18GB).

To simulate a push event, run:

```bash
act
```

To simulate a cron job trigger instead, run:

```bash
act schedule
```

Do note that the included CI loop will clear the containers used but NOT the image (to save from repetitive builds). This can be forced by running:

```bash
make clean-image
```
