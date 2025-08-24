
monitoring-delpoy:
touch docker-setup.sh
sudo chmod +x docker-setup.sh

ssh-copy-id ruslan@192.168.0.63
sudo mkdir /etc/ansible
touch /etc/ansible/hosts
cat ansible/hosts > /etc/ansible/hosts
ansible-playbook deploy-docker.yml --ask-become-pass