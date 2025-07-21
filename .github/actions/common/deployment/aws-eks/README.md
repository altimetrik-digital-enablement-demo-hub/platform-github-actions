# Deploy to AWS EKS

This GitHub Action deploys application docker images to AWS EKS clusters using Helm with support for both GHCR and ECR registries.

## Features

- **Multi-Registry Support** - Deploy from GHCR or ECR registries
- **ECR Image Mirroring** - Optionally push images from GHCR to ECR
- **Simple LoadBalancer Service** - Uses Kubernetes LoadBalancer service type for direct external access
- **Automatic DNS Hostname** - Provides LoadBalancer DNS hostname for external access
- **Health Check URLs** - Includes health check endpoints

## Usage

### Basic GHCR Deployment
```yaml
- name: Deploy to AWS EKS
  uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/deployment/aws-eks@main
  with:
    app-name: my-app
    tag: latest
    chart-path: './deploy/charts/my-app'
    repository: ghcr.io/my-org/my-app
    namespace: 'my-namespace'
    region: 'us-east-1'
    cluster-name: 'my-eks-cluster'
    service-type: 'LoadBalancer'
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    ghcr-username: ${{ secrets.GHCR_USERNAME }}
    ghcr-pat: ${{ secrets.GHCR_PAT }}
```

### Push to ECR and Deploy from GHCR
```yaml
- name: Deploy to AWS EKS
  uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/deployment/aws-eks@main
  with:
    app-name: my-app
    tag: latest
    chart-path: './deploy/charts/my-app'
    repository: ghcr.io/my-org/my-app
    namespace: 'my-namespace'
    region: 'us-east-1'
    cluster-name: 'my-eks-cluster'
    push-to-ecr: true
    ecr-repository-name: 'my-app'
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    ghcr-username: ${{ secrets.GHCR_USERNAME }}
    ghcr-pat: ${{ secrets.GHCR_PAT }}
```

### Deploy from ECR
```yaml
- name: Deploy to AWS EKS
  uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/deployment/aws-eks@main
  with:
    app-name: my-app
    tag: latest
    chart-path: './deploy/charts/my-app'
    repository: ghcr.io/my-org/my-app
    namespace: 'my-namespace'
    region: 'us-east-1'
    cluster-name: 'my-eks-cluster'
    push-to-ecr: true
    deploy-from-ecr: true
    ecr-repository-name: 'my-app'
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    ghcr-username: ${{ secrets.GHCR_USERNAME }}
    ghcr-pat: ${{ secrets.GHCR_PAT }}
```

## Inputs

| Input Name | Description | Required | Default |
|------------|-------------|----------|---------|
| `app-name` | Name of the application to deploy | ✅ Yes | - |
| `tag` | Docker image tag | ✅ Yes | - |
| `chart-path` | Path to the Helm chart | ✅ Yes | - |
| `repository` | Docker image repository | ✅ Yes | - |
| `namespace` | Kubernetes namespace | ❌ No | `default` |
| `region` | AWS region | ✅ Yes | - |
| `cluster-name` | EKS cluster name | ✅ Yes | - |
| `service-type` | Kubernetes service type | ❌ No | `LoadBalancer` |
| `aws-access-key-id` | AWS Access Key ID | ❌ No | - |
| `aws-secret-access-key` | AWS Secret Access Key | ❌ No | - |
| `aws-session-token` | AWS Session Token | ❌ No | - |
| `ghcr-username` | GitHub Container Registry username | ❌ No | - |
| `ghcr-pat` | GitHub Container Registry PAT | ❌ No | - |
| `push-to-ecr` | Push image to ECR in addition to GHCR | ❌ No | `false` |
| `deploy-from-ecr` | Deploy from ECR instead of GHCR | ❌ No | `false` |
| `ecr-repository-name` | ECR repository name (required if push-to-ecr or deploy-from-ecr is true) | ❌ No | - |

## ECR Support

### Push to ECR
When `push-to-ecr: true`, the action will:
1. Pull the image from GHCR
2. Tag it for ECR
3. Push it to ECR
4. Deploy from the original registry (GHCR by default)

### Deploy from ECR
When `deploy-from-ecr: true`, the action will:
1. Create ECR authentication secrets
2. Deploy using the ECR image instead of GHCR

### Prerequisites for ECR
- AWS credentials with ECR permissions
- GHCR credentials (for pulling source image)
- ECR repository name

## Prerequisites

### VPC Subnet Tagging

For LoadBalancer services to work properly, your EKS cluster's VPC subnets must be tagged correctly:

```bash
# Tag public subnets for internet-facing load balancers
aws ec2 create-tags --resources subnet-xxxxxxxxx --tags Key=kubernetes.io/role/elb,Value=1

# Tag private subnets for internal load balancers (if needed)
aws ec2 create-tags --resources subnet-xxxxxxxxx --tags Key=kubernetes.io/role/internal-elb,Value=1
```

**Required tags:**
- `kubernetes.io/role/elb=1` - For public subnets (internet-facing load balancers)
- `kubernetes.io/role/internal-elb=1` - For private subnets (internal load balancers)

### EKS Cluster Requirements

- EKS cluster must be running and accessible
- AWS credentials must have permissions to create LoadBalancers and ECR repositories
- Subnets must have proper routing and internet connectivity

## Helm Chart Requirements

Your Helm chart should support:
1. **Load Balancer Service Type** - Set `service.type: LoadBalancer` in values.yaml
2. **Image Configuration** - Support `image.repository` and `image.tag` values
3. **Service Annotations** - Include AWS LoadBalancer annotations

### Example values.yaml

```yaml
# Default values for your app
replicaCount: 2

image:
  repository: ghcr.io/your-org/your-app
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 8080
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip

resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 100m
    memory: 256Mi
  ```
  
  ## LoadBalancer Configuration
  
  ### Why Network Load Balancer (NLB)?
  
  The action uses Network Load Balancer (NLB) by default because:
  
  - **Better Performance** - Lower latency for TCP traffic
  - **IP Target Type** - Direct pod IP routing (no kube-proxy overhead)
  - **Simpler Health Checks** - TCP health checks work with any application
  - **Cost Effective** - Lower cost for high-traffic applications
  
  ### Service Annotations Explained
  
  ```yaml
  annotations:
    # Internet-facing load balancer
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    
    # Network Load Balancer type
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    
    # Target pods directly by IP
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
  ```
  
  ## Benefits of This Approach
  
  1. **Simpler Architecture** - Direct LoadBalancer service
  2. **Faster Deployment** - No additional controllers needed
  3. **Better Performance** - Network Load Balancer with IP targets
  4. **Easier Troubleshooting** - Fewer moving parts
  
  ## Deployment Summary

The action generates a deployment summary with:

- ✅ Deployment status
- 📦 Release information
- 🐳 Image details
- 📦 Deploy Registry (GHCR or ECR)
- 📤 ECR push status (if applicable)
- 🌍 AWS region
- 📊 Pod status
- 🌐 External URL (LoadBalancer hostname)
- 🌐 Health check URL
- ⏳ DNS propagation note

## Notes

- DNS propagation may take two minutes after LoadBalancer creation
- The LoadBalancer hostname is immediately available for testing
- Health check endpoint should be configured in your application
- Ensure VPC subnets are properly tagged before deployment
- ECR repositories are created automatically if they don't exist 