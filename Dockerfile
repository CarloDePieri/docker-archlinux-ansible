FROM carlodepieri/docker-archlinux-systemd
LABEL maintainer="depieri.carlo@gmail.com"

# Update the system, install python and pip; clean cache
RUN pacman -Syu --noconfirm \
python \
python-pip \
sudo; \
yes | pacman -Scc

# Install ansible
RUN pip install ansible

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible; \
echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
ENV ANSIBLE_USER=ansible
ENV SUDO_GROUP=wheel
RUN set -xe \
  && groupadd -r ${ANSIBLE_USER} \
  && useradd -m -g ${ANSIBLE_USER} ${ANSIBLE_USER} \
  && usermod -aG ${SUDO_GROUP} ${ANSIBLE_USER} \
  && sed -i "/^%${SUDO_GROUP}/s/ALL\$/NOPASSWD:ALL/g" /etc/sudoers \
  && sed -i "/^# %wheel.*NOPASSWD/s/^# //" /etc/sudoers

WORKDIR /home/${ANSIBLE_USER}
