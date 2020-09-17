FROM carlodepieri/docker-archlinux-systemd
LABEL maintainer="depieri.carlo@gmail.com"

# Update the system, install python, pip and vim; clean cache
RUN pacman -Syu --noconfirm \
python \
python-pip \
vim; \
yes | pacman -Scc

# Install ansible
RUN pip install ansible

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible; \
echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
