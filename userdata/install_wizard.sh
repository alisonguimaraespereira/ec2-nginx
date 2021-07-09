#!/bin/bash
cat <<EOF > /opt/post-scripts/custom_scripts/files/script.sh

#########################################
################ Ansible ################

useradd ansible
mkdir /home/ansible/.ssh/
echo """ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/87ulOb5JqhFkc8dOsBfhEBmyXLDJqC+kkf7i16SucuOrcl4gDLtKbuFnET7QbbQH8McmOYnskxjIilvC762zomjBQ6jZXSeS67oxVVsvY6ttjXaFE5OFAB9+UAk4jKa+vEb7SEutPE19Ij8LN+Dody1ZpVECjrlXwvhJ4iEoGzXS2dcsMZ7Mz7uCuAEF+427OeZ0hCcBa0jIi/f0+o4qdFoAp/JAUSr0UcqMoQnNWXjKLNxAXczwkmcNAuM89SKHVUPCUGl80gFdHfZkxB432q61V3NQypOWi9r8jrzvc/teyM7gT14tsD7LRk391rM9Pt1FDwxtU0Wh9VWhNbhcm4mJHwp5f8+zpI4xRdp9QlK11b0zR4a4/oQojpGR3W96pB7AfIvzJfIZbHyT0g+qqt/UkgFCsHywrehq7p9SbVw+fHBf5wMV1XAbyQdCE7lzK3y1xet5Uynla1sp2R0VTsqoRdpcZPQybLv8AhhwZwwsl/c1sKE0si8xuJksrdU= alison@BRPC014511
""" >> /home/ansible/.ssh/authorized_keys
chown -R ansible.ansible /home/ansible/.ssh/
chmod 600 /home/ansible/.ssh/*

echo """
ansible  ALL=(ALL)  NOPASSWD: ALL
""" > /etc/sudoers.d/ansible

yum -y update



EOF