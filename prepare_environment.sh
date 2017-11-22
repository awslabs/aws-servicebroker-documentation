# Enable Extras repo so that we can install docker
sudo yum-config-manager --enable "Red Hat Enterprise Linux Server 7 Extra(RPMs)"

# Install docker, git, wget, and vim
sudo yum -y install docker git wget vim

# Enable EPEL-release repo so that we can retrieve apb tool dependencies
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Enable APB Copr repo so that we can retrieve apb tool
sudo wget https://copr.fedorainfracloud.org/coprs/g/ansible-service-broker/ansible-service-broker/repo/epel-7/group_ansible-service-broker-ansible-service-broker-epel-7.repo -O /etc/yum.repos.d/ansible-service-broker.repo

# Install apb tool
sudo yum -y install apb

# Download OpenShift Origin client and move executable to /usr/bin/oc
wget -O /tmp/oc.tar.gz https://github.com/openshift/origin/releases/download/v3.6.0/openshift-origin-client-tools-v3.6.0-c4dd4cf-linux-64bit.tar.gz
tar -xf /tmp/oc.tar.gz --directory /tmp/
sudo mv /tmp/openshift-origin-client-tools-v3.6.0-c4dd4cf-linux-64bit/oc /usr/bin/oc

# Give ec2-user permission to interact with docker socket
sudo groupadd docker && sudo usermod -aG docker ec2-user
sudo chown root:docker /var/run/docker.sock

# Configure docker to connect to the local insecure image registry
sudo sed -i 's/#insecure_registries:/insecure_registries:\n\ \ - 172.30.0.0\/16/' /etc/containers/registries.conf

# Enable and start the docker service
sudo systemctl enable docker && sudo systemctl start docker

# Clone the ansible-service-broker repo
git clone https://github.com/openshift/ansible-service-broker

# Modify run_latest_build.sh to bind to 127.0.0.1 so that the cluster is only visible from localhost
sed -i 's/.*PUBLIC_IP=.*:/PUBLIC_IP=127.0.0.1/g' ansible-service-broker/scripts/run_latest_build.sh
sed -i 's/.*HOSTNAME=.*:/HOSTNAME=localhost/g' ansible-service-broker/scripts/run_latest_build.sh

# Clone the apb-examples repo
git clone https://github.com/fusor/apb-examples

echo
echo
echo "OpenShift / APB development dependency installation complete!"
echo
echo "Run ansible-service-broker/scripts/install_latest_build.sh to set up an"
echo "OpenShift cluster containing the Ansible Service Broker."
echo
echo "Run 'oc cluster down' to stop the running cluster."
echo

# Make docker group enrollment take effect without requiring logout
exec sudo su -l $USER
