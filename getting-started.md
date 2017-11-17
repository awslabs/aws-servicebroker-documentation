# Getting Started Guide - Early Access


## Introduction

The below defines terms and abbreviations which are used throughout this document.



*   **Service Catalog** is the component which finds and presents the users the list of services which the user has access to. It also gives the user the ability to provision new instances of those services and provide a way to to bind the provisioned services to existing applications.
*   **Service Brokers** are the components that manages a set of capabilities in the cloud infrastructure, and provides the service catalog with the list of services, via implementing the Open Service Broker API
*   **AWS Broker** is the Red Hat's OpenShift Org's implementation of the service broker for Amazon Services.
*   **Ansible Playbook Bundle (APB)** is a application definition (meta-container) used to define and deploy applications. 

The following Amazon Services are available as APBs.  



*   Simple Queue Service (SQS)
*   Simple Notification Service (SNS)
*   Route 53
*   Relational Database Service (RDS)
*   Elastic MapReduce (EMR)
*   Simple Cloud Storage Service (S3)
*   ElastiCache
*   Redshift
*   Dynamodb


## Prerequisites

The following must be satisfied before beginning.



*   OpenShift Container Platform (OCP) or Origin v3.7
*   Docker
*   Service Catalog Enabled
*   AWS Service Broker configured with a registry (e.g. docker.io/awsservicebroker)
*   APB Prerequisites (if applicable)


## Environment Setup

The following describe the steps to setup the various OpenShift environment with a [Service Catalog](https://github.com/kubernetes-incubator/service-catalog) & [AWS Service Broker](https://github.com/openshift/ansible-service-broker) 


### Deployment Template

The simplest way to create the minimal environment is to run a deployment template on your local machine or on an EC-2 instance (t2.medium or higher is recommended).

Get the deployment config file and the `run_latest_build.sh` script file


```bash
mkdir -p ~/awsservicebroker
cd ~/awsservicebroker
wget https://s3.amazonaws.com/awsservicebrokerbroker/scripts/deploy-awsservicebroker-broker.template.yaml
wget https://s3.amazonaws.com/awsservicebrokerbroker/scripts/run_latest_build.sh
chmod a+x run_latest_build.sh
```


If you're running this from an EC-2 Instance, edit the  `run_latest_build.sh` script and set the `HOSTNAME` to the EC-2 instance's public DNS hostname 


```bash
vi run_latest_build.sh
```



e.g.


```bash
HOSTNAME=my-aws-ose-test.ec2.mydomain.com
```


Visit [https://$HOSTNAME:8443](https://$HOSTNAME:8443) to login (default username: `admin`, default password: `admin`)


### CatASB (for development and testing)

[CatASB](https://github.com/fusor/catasb) is a collection of ansible playbooks, which will automate the creation of your OpenShift environment with greater ability to customize your setup. In short, you will edit and customize a configuration YAML file, and run an ansible playbook with a script.

First, clone the `catasb` git repository


```bash
git clone https://github.com/fusor/catasb.git
cd catasb
```


Copy the '`my_vars.yml.example`' to '`my_vars.yml`', and edit the file.  '`my_vars.yml`' is your custom configuration file.  Any variable defined in this file will overwrite its definition anywhere else. 


```bash
cd config
cp my_vars.yml.example my_vars.yml
```


**Review**, **uncomment**, and **modify** variables that you wish to customize.


```bash
vi my_vars.yml
```


Below are some of the variables that you may wish to override:


```yaml
dockerhub_user_name: changeme
dockerhub_user_password: changeme    #>>> WARNING password is not encrypted!
dockerhub_org: awsservicebroker

origin_image_tag: latest
openshift_client_version: latest

deploy_asb: False
deploy_awsservicebroker: True

```


**dockerhub_user_name/dockerhub_user_password** - used to authenticate Dockerhub Org

**origin_image_tag** - version of the origin to be used ([click here for the list of valid tags](https://hub.docker.com/r/openshift/origin/tags/))

**openshift_client_version** -  (default is v3.7, i.e. <code>"latest"</code>)

**awsservicebroker_broker_template_dir** - location of AWS Broker Config file

**deploy_asb** - Deploy Ansible Service Broker

**deploy_awsservicebroker** - Deploy AWS Broker


### CatASB - Deploying to the local machine

This will do an '`oc cluster up`', and install/configure the service catalog with the AWS broker.

Navigate into the `catasb/local/<OS>` folder


```bash
cd catasb/local/linux  # for Linux OS

or

cd catasb/local/mac    # for MacOS
```


If you are running in the MacOS environment, review/edit `catasbconfig/mac_vars.yml`


To create secrets for the AWS Access and AWS Secret Key parameters for all your APBs, do the following.  


```bash
export AWS_ACCESS_KEY_ID=<your access key value>
export AWS_SECRET_ACCESS_KEY=<your secret key value>
```


For more information on creating secrets for your APB parameters [Click Here]

Run the `setup` script


```bash
./run_setup_local.sh  # for Linux OS

or

./run_mac_local.sh    # for MacOS
```


The script will output the details of the OpenShift Cluster


##### Troubleshooting


When visiting the cluster URL (e.g. [https://172.17.0.1:8443/console/](https://172.17.0.1:8443/console/)), you may get an issue with _not_ being able connect.  Check your firewall rules to make sure all of the OpenShift Ports are permitted. [Click here to see the list of ports](https://docs.openshift.com/container-platform/latest/install_config/install/prerequisites.html#required-ports)


Try disabling your firewall, reset your environment, and see if you can reach the cluster URL


```bash
sudo iptables -F
./reset_environment.sh
```



### CatASB - Single Node EC-2

This environment uses "`oc cluster up`" in a single EC-2 instance, and will install the openshift components from RPMs.

Navigate into the `catasb/ec2 `folder


```bash
cd catasb/ec2
```


Define the following environment variable for your AWS Account


<table>
  <tr>
   <td><strong>Environment Variable</strong>
   </td>
   <td><strong>Default Values</strong>
   </td>
  </tr>
  <tr>
   <td>AWS_SSH_KEY_NAME
   </td>
   <td>splice
   </td>
  </tr>
  <tr>
   <td>TARGET_DNS_ZONE
   </td>
   <td>ec2.dog8code.com
   </td>
  </tr>
  <tr>
   <td>OWNERS_NAME
   </td>
   <td>whoami
   </td>
  </tr>
  <tr>
   <td>TARGET_SUBDOMAIN
   </td>
   <td>${OWNERS_NAME}
   </td>
  </tr>
  <tr>
   <td>AWS_PRIV_KEY_PATH
   </td>
   <td>No Default
   </td>
  </tr>
</table>


Setup the AWS network, and the EC-2 instance:


```bash
./run_create_infrastructure.sh
```


The script will output the details of the AWS environment

Next, install and configure OpenShift, service catalog, and the broker


```bash
./run_setup_environment.sh
```


To terminate the EC-2 instance and to remove/clean-up the AWS network, run the following


```bash
./terminate_instances.sh
```



All of the scripts above will output the details of the OpenShift Cluster.  However, if you wish to review those details at any time, you can run the following:


```bash
./display_information.sh
```



### Console Login

When you visit the cluster URL  (e.g. [https://172.17.0.1:8443/console/](https://172.17.0.1:8443/console/)) you should see a login screen as shown below.  The default login is `admin` username with `admin` password.

![OpenShift Login](images/openshift-login.png)

After login, you will be greeted with the following main screen.

![OpenShift Service Catalog](images/service-catalog.png)



### Creating CloudFormation Role ARN

All APB's require a valid CloudFormation Role ARN (Amazon Resource Name) as a parameter.  To Create it, follow the steps below



1.  Logon to the AWS Management Console WebUI 
1.  Click "Services → IAM"
1.  Click "Roles" in the Left column
1.  Click "Create Role"
1.  Click on "CloudFormation" in the "Select type of trust entity"
1.  Then click "Next: Permissions" to continue
1.  Select "AdministratorAccess", and click "Next: Review" to continue
1.  Enter the desired Role Name, and click "Create Role"

Once you have completed creating the CloudFormation Role, you can get its ARN by going back to the "Services → IAM" and clicking on "Roles", then selecting your newly created Role. 

The ARN will have the following format:


```
arn:aws:iam::375558675309:role/my-role-name
```



### Creating Secrets for APBs

Many of the APB's will require at least two required parameters in common (e.g. `AWS Access Key` and `AWS Secret Key`), and perhaps more.  You may wish to configure and to set up a secret for all your APB's to share, so that the provisioner of the individual APBs will not need to manually enter those parameter values during provisioning of the APB.  Setting up a secret in this manner, may also provide a level of security, since it will prevent the provisioner of the APBs not to know the actual secret values for the parameters. 

To achieve this goal, the secrets will be created in the 'aws-service-broker' namespace.  Once the secrets for the predetermined parameter are created and configured for an APB, those parameters will NOT appear during the normal APB's launching process.  This means that the user will not even "see" that parameter option to enter the value for, since they have already been set and created as a secret.  Those parameter values will automatically receive the values created in the secret. Follow the step below to create and configure secrets for your APBs.


#### Creating the AWS Access and Secret key pair for all APBs

If you wish to use only one set of AWS Access and Secret key pair for for all your APBs, you can simply set a few environment variables **_BEFORE_** running the CatASB run scripts, and the secrets will be **_automatically_** created for the APBs to consume.

In the terminal export the values for the AWS Access and Secret keys as shown below


```bash
$ export AWS_ACCESS_KEY_ID="<my_aws_access_key_value>"
$ export AWS_SECRET_ACCESS_KEY="<my_aws_secret_key_value>"

$ catasb/local/linux/run_setup_local.sh
```


After this step, the APBs will no longer require the user to input the Access and Secret key parameters during the APB's provisioning step, since those parameter fields will not be visible.

If you wish to remove the secrete later on, logon to the WebUI Console, and visit the` aws-service-broker→ resources → secrets` → `aws-custom-access-key-pair` secret and select `Actions → Delete` to remove the secret from the `aws-service-broker` namespace.

**Note**: After deleting the secret, the AWS access and secret key parameters will once again be required to be inputted during the APB's provisioning step.


#### Customizing Secrets for each APBs

If you wish to specify different AWS keys, or region, or any other parameter values for specific APBs, you may do so by creating a custom secrets file.

Let's consider that you have not set the `AWS_ACCESS_KEY_ID` or the `AWS_SECRET_ACCESS_KEY` from the previous example, and that you wish to do so now manually.

Start by creating your secrets file. You may create as many secret files as you like.  

(e.g. the following  are the contents of  `my-secrets.yml` file)


```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: my-secrets
stringData:
  aws_access_key: "changeme"
  aws_secret_key: "changeme"
```


**Note**:  The `key` names in `stringData` section **MUST** be equal to the parameter name specified in the APB that it's configured to be used.  If the names do not match (e.g. `aws_access_key` vs `aws-access-key`) the parameter values will NOT receive the secret.

Next, create the secret in the "`aws-service-broker`" namespace


```bash
oc create -f my-secrets.yml -n aws-service-broker
```


Run the command above for each of the secret files that you've created.

You can verify that the secrets were created in the WebUI by visiting `resource → secrets` section of the `aws-service-broker` namespace.

Now, we want to configure our broker to _use_ the secret that we just created in "`my-secrets`" and configure them to be consumed by our APBs.  

To do so, edit the broker's `configmap` by issuing the following command


```bash
oc edit configmap -n aws-service-broker
```


Search for the following section of the `configmap`


```yaml
   broker:
      dev_broker: True
      bootstrap_on_startup: true
      refresh_interval: "24h"
      launch_apb_on_bind: False
      output_request: False
      recovery: True
      ssl_cert_key: /etc/tls/private/tls.key
      ssl_cert: /etc/tls/private/tls.crt
      auto_escalate: True
      auth:
        - type: basic
          enabled: False
```


And …

Add in a "**<code>secrets</code></strong>" section which follows the following syntax.


```yaml
    secrets:
      - {apb_name: dh-myORG-myAPB-tag, secret: mysecrets, title: mysecrets}
```


The `"apb_name"` will follow the above pattern 



*   "`dh`" for dockerhub 
*   "`myORG`" for the organization (i.e. `awsservicebroker`)
*   "`tag`" is the APB image tag (i.e. `latest`)
*   `"secret/title"` is the name of your secret.

For our `awsservicebroker` APB's, the modified configmap will look as follows:


```yaml
    broker:
      dev_broker: True
      bootstrap_on_startup: true
      refresh_interval: "24h"
      launch_apb_on_bind: False
      output_request: False
      recovery: True
      ssl_cert_key: /etc/tls/private/tls.key
      ssl_cert: /etc/tls/private/tls.crt
      auto_escalate: True
      auth:
        - type: basic
          enabled: False
    secrets:
      - {apb_name: dh-awsservicebroker-sqs-apb-latest, secret: mysecrets, title: mysecrets}
      - {apb_name: dh-awsservicebroker-sns-apb-latest, secret: mysecrets, title: mysecrets}
      - {apb_name: dh-awsservicebroker-rds-apb-latest, secret: mysecrets, title: mysecrets}
      - {apb_name: dh-awsservicebroker-s3-apb-latest, secret: mysecrets, title: mysecrets}
      - {apb_name: dh-awsservicebroker-emr-apb-latest, secret: mysecrets, title: mysecrets}
      - {apb_name: dh-awsservicebroker-redshift-apb-latest, secret: mysecrets, title: mysecrets}
      - {apb_name: dh-awsservicebroker-elasticache-apb-latest, secret: mysecrets, title: mysecrets}
```


To make our edits take effect, **restart** the broker's `asb` pod 


```bash
oc rollout latest aws-asb -n aws-service-broker
```


Change the default `broker-relist-interval` value of the service catalog's `controller-manager` pod by editing its deployment


```bash
oc edit deployment controller-manager -n kube-service-catalog
```


Search for the following section


```yaml
    spec:
      containers:
      - args:
        - -v
        - "5"
        - --leader-election-namespace
        - kube-service-catalog
        - --broker-relist-interval
        - 5m
```


And …

Edit the `broker-relist-interval` value to <code>1m<strong> </strong></code>as shown below


```yaml
    spec:
      containers:
      - args:
        - -v
        - "5"
        - --leader-election-namespace
        - kube-service-catalog
        - --broker-relist-interval
        - 1m
```


The controller-manager pod will _automatically_ restart once you_ save and exit_ the deployment edit screen.**<code> </code></strong>

Review the `asb` pod's _logs_ in the `aws-service-broker` namespace. The logs should show  "`filtering secrets`" for the APB's that you have configured the secrets for.


```bash
[DEBUG] Filtering secrets from spec dh-awsservicebroker-sqs-apb-latest
```


### General APB Tips

Create a new project (namespace) to provision each of the APBs, unless it make sense to do otherwise.

All AWS APBs require the `aws_access_key` and the `aws_secret_key` parameters.  Therefore, these two parameters would be a great candidates for the creating of the secrets and configure the APB's to use them via defining the  the `AWS_ACCESS_KEY_ID` and the `AWS_SECRET_ACCESS_KEY` environment variable as described earlier.

Most APB parameters have default values and are descriptive enough to make an educated guess on what the values should be. Many parameters are selectable from a set of valid choices.  However, if any of the parameters do not make sense, do not provision.  Click the "view documentation" and review the AWS service documentation when you're not certain what the parameters should be.


### Binding


#### Provision first, Bind Later

If you simply want to provision the APB and wish to bind it to an application at a later time, do the following



*   Provision the APB, but select "do not create a binding"
*   Provision other apps or APBs, but again, select "do not create binding"
*   Once all of the APB's/Apps are provisioned in your namespace, select an app, and create the binding from the App to the APB and ...
*   Redeploy your app if it does not automatically redeploy after binding. Some `source-to-image` apps may need to be manually redeployed


#### Bind During the Provisioning Step

To bind applications to APB during the provisioning step, you must already have an App or an APB that was successfully provisioned. Once you have an APB to bind to, do the following



*   Provision the APB, but select "create a binding to be used later"
*   Provision apps, but do not bind the apps to the APB
*   Go to the the "resources → secrets" and find and click on the `binding secret`
*   Click on the "`Add to application`" at the top right, and select your application
*   Redeploy your app if it does not automatically redeploy


## Troubleshooting

#### Debugging connectivity issues from external traffic to VPC

We've run into some cases with RDS where the connection to the RDS instance was not accessible.  When this happens look at the VPC of the RDS instance and trace to the associated routing table.  Verify that the routing table has a reference to the internet gateway, if you don't see a reference to the igw like below then add it so external traffic is allowed.

![AWS VPC Dashboard](images/vpc-dashboard.png)