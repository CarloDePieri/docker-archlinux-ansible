# Docker Archlinux for testing Ansible playbooks

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/carlodepieri/docker-archlinux-ansible/prod?logo=github)](https://github.com/CarloDePieri/docker-archlinux-ansible/actions/workflows/prod.yml) [![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/carlodepieri/docker-archlinux-ansible?logo=docker)](https://hub.docker.com/r/carlodepieri/docker-archlinux-ansible)

An updated, systemd-enabled Archlinux docker image (based on my [docker-archlinux-systemd](https://hub.docker.com/r/carlodepieri/docker-archlinux-systemd))
useful for testing ansible playbook.

Images are built by GitHub CI and pushed to DockerHub at least once a month.

## Usage: testing with Molecule

A [working Docker installation](https://docs.docker.com/engine/install/) is needed.
Images on Docker Hub gets automatically built at least once a month by GitHub Actions.

A [working molecule installation](https://molecule.readthedocs.io/en/latest/installation.html) is also needed.

Running `molecule init scenario --driver-name docker` will quick-start a project.
Now edit the `'platforms'` section inside the file `molecule/default/molecule.yml`.

```yml
platforms:
  - name: cdp-arch-ansible
    image: carlodepieri/docker-archlinux-ansible:latest
    command: ${MOLECULE_DOCKER_COMMAND:-""}
    privileged: true
    pre_build_image: true
```

This will make molecule pull the image from Dockerhub and start the container in a way that
supports systemd and ansible.

> **Important**: the privileged flag is necessary to make systemd behave,
> but make sure to understand [the security concerns involved](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).

After the container has been created (for example by `molecule converge`),
a shell to inspect the container can be obtained with:

```bash
docker exec -it cdp-arch-ansible env TERM=xterm bash
```

## Devs: building the image from GitHub

Clone the repo first with:

```bash
git clone git@github.com:CarloDePieri/docker-archlinux-ansible.git
```

### Building the image from source

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
docker run --name=cdp-arch-ansible --detach --privileged --volume=`pwd`:/etc/ansible/roles/role_under_test:ro carlodepieri/docker-archlinux-ansible
```

or, for convenience:

```bash
make run-container
```

This should start the container, which can should be then visible in `docker ps`.
It will also bind the current working directory inside the container, which can
be handy to quickly test a playbook (like the included `test.yml`).

### Support for manual cgroup binding

If manual cgroup volume mounting is needed and the docker-archlinux-systemd
image has been built as explained [here](https://github.com/CarloDePieri/docker-archlinux-systemd#compatibility-with-systems-that-need-cgroups-volumes),
this image must be build as described above but then, for running the
container, launch:

```bash
docker run --name=cdp-arch-ansible --detach --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro --volume=`pwd`:/etc/ansible/roles/role_under_test:ro carlodepieri/docker-archlinux-ansible
```

or, for convenience:

```bash
make run-container-volume
```

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

[Act](https://github.com/nektos/act) can be used to execute locally the GitHub
Actions loop. Keep in mind that this will use Act's
[full image](https://hub.docker.com/r/nektos/act-environments-ubuntu/tags),
which is really heavy (>18GB).

To execute a 'push on a testing branch' event (which also triggers when pulling
into master), run:

```bash
make act-dev
```

To execute a 'push on master' event (which triggers also on scheduled cronjobs),
with the relative DockerHub deploy:

```bash
make act-prod
```

To access the act containers:

```bash
make act-dev-shell
# or
make act-prod-shell-ci
# or
make act-prod-shell-deploy
```

To quickly delete them the act containers:

```bash
make act-dev-clean
# or
make act-prod-clean
```

Do note that the included CI loop will clear the containers used but NOT the
image (to save from repetitive builds). This can be forced by running:

```bash
make clean-image
```
