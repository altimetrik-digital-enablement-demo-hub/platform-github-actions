# Deploy to AWS EKS

This GitHub Action deploys application docker images to AWS EKS clusters using Helm.

## Features

- **Simple LoadBalancer Service** - Uses Kubernetes LoadBalancer service type for direct external access
- **Direct GHCR Integration** - Pulls images directly from GitHub Container Registry
- **Automatic DNS Hostname** - Provides LoadBalancer DNS hostname for external access
- **Health Check URLs** - Includes health check endpoints

## Usage

```yaml
- name: Deploy to AWS EKS
  uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/deployment/aws-eks@main
  with:
    app-name: my-app
    tag: latest'
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
- AWS credentials must have permissions to create LoadBalancers
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
  port: 8080  annotations:
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
    ources:
  requests:
    cpu: 50
    memory: 128
  limits:
    cpu:100
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
  service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing"
  
  # Network Load Balancer type
  service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
  
  # Target pods directly by IP
  service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
```

## Deployment Summary

The action generates a deployment summary with:

- ✅ Deployment status
- 📦 Release information
- 🐳 Image details
- 🌍 AWS region
- 📊 Pod status
- 🌐 External URL (LoadBalancer hostname)
- 🌐 Health check URL
- ⏳ DNS propagation note

## Benefits of This Approach

1. **Simpler Architecture** - Direct LoadBalancer service
2. **Faster Deployment** - No additional controllers needed
3. **Better Performance** - Network Load Balancer with IP targets
4. **Easier Troubleshooting** - Fewer moving parts

## Notes

- DNS propagation may take two minutes after LoadBalancer creation
- The LoadBalancer hostname is immediately available for testing
- Health check endpoint should be configured in your application
- Ensure VPC subnets are properly tagged before deployment 