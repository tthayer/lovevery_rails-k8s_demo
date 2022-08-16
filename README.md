# Lovevery Hello World! Demo

This project contains the components of a containerized Ruby on Rails "Hello World!" project 
and the associated Kubernetes manifests needed to deploy it into a cluster with two concurrently
running pods. 

## Building the project

To build this project without modification:

1. `docker build . -t myrepo/lovevery_rails-k8s-demo:latest`
2. `docker push myrepo/lovever_rails-k8s-demo:latest`

If you have made changes to the required Gems or updated something involving the Rails installation:

1. `bundle`
2. Verify the Gemfile.lock file contains your changes
3. Follow steps 1 and 2 from the section above to rebuild the image

## Deploying the container in Kubernetes

### Requirements

* A local k8s cluster up and running and your local KUBECONFIG environment variable pointing to that configuration
* helm

### Deployment

1. `helm install k8s-hello-world ./k8s-hello-world`

### Testing

I added an additional healthcheck controller that provides a json payload beyond just the 200 OK response.
Beyond just testing liveness with this controller, additional controllers could be added to evaluate readiness by measuring
DB latency or blocking requests (for instance). This feedback could be used to provide specific metrics or feedback that could
be used to determine loadbalancer behavior to help better spread out request load.

## Notes

I developed this locally using Rancher Desktop which uses k3s. As such, I had to use port forwarding from the
Rancher Desktop application to connect to the service.

### Steps to test locally with Rancher Desktop after deploying the application with helm

1. Open the Rancher Desktop App
2. Click on Port forwarding
3. The application is deployed in the default namespace with the name 'k8s-hello-world'. 
Click on the 'Forward' button and then click the checkmark to accept the randomly-selected port.
4. Point your browser to "http://127.0.0.1:randomportfromstep3"
5. Enjoy the majesty of the h1 tags

# Terraform Q&A

## How would you manage terraform state for multiple environments?

I would start with writing terraform modules in an environment-agnostic fashion so that they can be deployed the same way in every environment.
Then I would wrap the module calls in a script or tool like Terragrunt that breaks out state by directory. The deployment code would live in a structured repository broken out by environment where each environment should share core configuration but state would be distinctly separated by virtue of module calls being made from separate folders. For instance:

```
Deployment_repo
-> modules
  -> profiles (wraps component code for re-use)
    -> eks 
  -> components (defines a single item to be configured)
    -> vpc 
    -> monitoring
    -> s3
    -> iam
-> environments (calls profiles with environment-specific input)
  -> dev
    -> eks
  -> stage
    -> eks
  -> prod
    -> eks
  -> demo
    -> eks
```

## How would you approach managing terraform variables and secrets?

Variables could be stored and shared in the repo as described by the deployment repo mentioned above. Terragrunt provides dependency patterns that allow you to dynamically pull output variables from upstream state, provided the upstream dependency has been applied previously. 

Ideally, secrets wouldn't live in the repo but instead would be retrieved programmatically from Vault or AWS Secrets Manager using least-privileged access either from the pipeline or ad-hoc from the cluster or application code. If secrets must be stored in the repo, they can be KMS-encrypted on-disk and then decrypted as-needed when Terraform runs are performed.
