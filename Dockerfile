FROM carlodepieri/docker-archlinux-systemd
LABEL maintainer="depieri.carlo@gmail.com"

# Update the system, install python, pip and ansible; clean cache
RUN pacman -Syu --noconfirm \
python \
python-pip \
ansible \
sudo; \
yes | pacman -Scc

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible; \
echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
ENV ANSIBLE_USER=ansible
RUN set -xe \
  && useradd -m --user-group ${ANSIBLE_USER} \
  && echo "${ANSIBLE_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 

WORKDIR /home/${ANSIBLE_USER}
