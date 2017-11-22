# Troubleshooting

## Service provisioning fails
There are a variety of ways this can manifest:
* provision fails with error
* provision succeeds but the cloudformation stack either is non-existant, or in CREATE_FAILED state
* provision succeeds, but bind secrets are empty

### Checking logs for Ansible playbook errors
Check whether the underlying ansible playbook experienced any errors:
```bash
journalctl --no-pager --since "-1 day" _SYSTEMD_UNIT=docker.service _COMM=dockerd-current | grep FAILED
```

### Checking for CloudFormation stack errors
To investigate a CloudFormation stack failure and it's causes, refer to the [Troubleshooting Guide](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/troubleshooting.html) in the CloudFormation Documentation.

## Troubleshooting AWS Service Broker issues

### AWS Service broker logs
The AWS Service Broker logs can be viewed by running the following openshift command, note that these commands require "oc login" to already be completed.

```bash
oc logs po/$(oc get pods -n aws-service-broker --no-headers | awk '{print $1}') -c aws-asb -n aws-service-broker | less
```

### Kubernetes Service Catalog logs
The Kubernetes Service Catalog invokes the AWS Service Broker and monitors for rpovisioning status's and available AWS services.

```bash
oc logs $(oc get pods -n kube-service-catalog | grep controller-manager | awk '{print $1}') -n kube-service-catalog | less
```
