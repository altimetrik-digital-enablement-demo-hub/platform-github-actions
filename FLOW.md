# GitHub Actions CI/CD Flow Architecture

This document explains the complete flow of how the `go-sample-app` gets built, containerized, and deployed using the modular `platform-github-actions` repository, self-hosted runners, and local Kubernetes cluster.

## Overview

The architecture consists of four main components:
1. **go-sample-app** - The Go application with Helm charts
2. **platform-github-actions** - Reusable workflow templates and actions
3. **Self-hosted GitHub Actions Runner** - Executes the workflows locally
4. **Local Kubernetes Cluster** - Target deployment environment

## High-Level Architecture Flow

```mermaid
graph TB
    subgraph "Developer Workflow"
        DEV[Developer] --> COMMIT[Git Commit/Push]
        DEV --> MANUAL[Manual Workflow Dispatch]
    end
    
    subgraph "GitHub Repository: go-sample-app"
        COMMIT --> TRIGGER[".github/workflows/dev.yml<br/>Workflow Triggered"]
        MANUAL --> TRIGGER
        TRIGGER --> CALL["Calls platform-github-actions<br/>go-dev-build.yml"]
    end
    
    subgraph "GitHub Repository: platform-github-actions"
        CALL --> REUSABLE["Reusable Workflow<br/>go-dev-build.yml"]
        REUSABLE --> ACTIONS["Individual Actions:<br/>• lint<br/>• unit-test<br/>• build<br/>• package<br/>• security-scan<br/>• helm-deployment"]
    end
    
    subgraph "Self-Hosted Runner (macOS ARM64)"
        ACTIONS --> RUNNER["GitHub Actions Runner<br/>Executes Jobs"]
        RUNNER --> BUILD["Build ARM64 Binary"]
        RUNNER --> DOCKER["Build Docker Image"]
        RUNNER --> PUSH["Push to GHCR"]
        RUNNER --> DEPLOY["Deploy via Helm"]
    end
    
    subgraph "Local Kubernetes Cluster"
        DEPLOY --> HELM["Helm Chart Deployment"]
        HELM --> PODS["Running Pods<br/>(2 replicas)"]
        PODS --> SERVICE["NodePort Service<br/>Port 80→8080"]
    end
    
    subgraph "Access"
        SERVICE --> PORTFWD["kubectl port-forward<br/>localhost:8080"]
        PORTFWD --> WEBAPP["Calculator Web App<br/>http://localhost:8080"]
    end

    style DEV fill:#e1f5fe
    style RUNNER fill:#f3e5f5
    style PODS fill:#e8f5e8
    style WEBAPP fill:#fff3e0
```

## Detailed Component Breakdown

### 1. Application Repository Structure

```mermaid
graph LR
    subgraph "go-sample-app Repository"
        APP["cmd/main.go<br/>Go Application"]
        HELM["deploy/helm/<br/>Kubernetes Charts"]
        WORKFLOW[".github/workflows/dev.yml<br/>Workflow Definition"]
        DOCKER["Dockerfile<br/>Container Definition"]
    end
    
    APP --> DOCKER
    HELM --> WORKFLOW
    WORKFLOW --> EXTERNAL["Calls External<br/>platform-github-actions"]
```

### 2. Platform Actions Repository Structure

```mermaid
graph TB
    subgraph "platform-github-actions Repository"
        subgraph "Reusable Workflows"
            MAIN_WF["go-dev-build.yml<br/>Main Pipeline"]
        end
        
        subgraph "Go-Specific Actions"
            LINT["go-templates/lint"]
            TEST["go-templates/unit-test"]
            BUILD["go-templates/build"]
        end
        
        subgraph "Common Actions"
            PACKAGE["common/package"]
            SECURITY["common/security-scan"]
            HELM_DEPLOY["common/helm-deployment"]
            SETUP_TAG["common/setup-tag"]
        end
    end
    
    MAIN_WF --> LINT
    MAIN_WF --> TEST
    MAIN_WF --> BUILD
    MAIN_WF --> PACKAGE
    MAIN_WF --> SECURITY
    MAIN_WF --> HELM_DEPLOY
    MAIN_WF --> SETUP_TAG
```

## Complete CI/CD Pipeline Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant App as go-sample-app
    participant Platform as platform-github-actions
    participant Runner as Self-Hosted Runner
    participant GHCR as GitHub Container Registry
    participant K8s as Kubernetes Cluster

    Dev->>GH: Git push to branch
    GH->>App: Trigger .github/workflows/dev.yml
    App->>Platform: Call go-dev-build.yml workflow
    
    Platform->>Runner: Execute lint job
    Runner->>Runner: Run lint
    
    Platform->>Runner: Execute test job
    Runner->>Runner: Run go test with coverage
    
    Platform->>Runner: Execute build job
    Runner->>Runner: Build binary (GOARCH=arm64)
    Runner->>Runner: Upload binary artifact
    
    Platform->>Runner: Execute package job
    Runner->>Runner: Download binary artifact
    Runner->>Runner: Build Docker image (ARM64)
    Runner->>GHCR: Push image with tag
    
    Platform->>Runner: Execute security job
    Runner->>Runner: Run CodeQL analysis
    Runner->>Runner: Scan container image
    
    Note over Dev,K8s: Manual Deployment (workflow_dispatch only)
    
    Platform->>Runner: Execute deploy-k8s job
    Runner->>Runner: Setup kubectl & helm
    Runner->>K8s: Check for stuck operations
    Runner->>K8s: helm upgrade --install
    K8s->>K8s: Pull image from GHCR
    K8s->>K8s: Create/update deployment
    K8s->>K8s: Start pods with health checks
    K8s->>Runner: Deployment status
    Runner->>GH: Update job summary
```

## Key Technical Details

### Image Tagging Strategy
- **Format**: `feature-summary-YYYYMMDD.{run_number}`
- **Example**: `feature-summary-20250616.89`
- **Registry**: `ghcr.io/osru-leu/go-sample-app/go-sample-app:tag`

### Architecture Compatibility
- **Build Target**: `GOOS=linux GOARCH=arm64`
- **Runner**: macOS ARM64 (Apple Silicon)
- **Container**: ARM64 compatible
- **Kubernetes**: Local cluster on ARM64

### Health Check Configuration
- **Endpoint**: `/health`
- **Response**: `{"service":"calculator","status":"healthy"}`
- **Probes**: Both liveness and readiness use `/health`

### Service Configuration
- **Type**: NodePort
- **Port Mapping**: 80 → 8080
- **Access**: `kubectl port-forward service/go-sample-app 8080:80`

## Workflow Triggers and Conditions

```mermaid
flowchart TD
    START[Workflow Trigger] --> PUSH_CHECK{Push to branch?}
    START --> DISPATCH_CHECK{Manual dispatch?}
    
    PUSH_CHECK -->|Yes| BUILD_ONLY["Build & Push Image<br/>No Deployment"]
    DISPATCH_CHECK -->|Yes + Deploy K8s checked| FULL_DEPLOY["Build, Push & Deploy"]
    DISPATCH_CHECK -->|Yes + Deploy K8s unchecked| BUILD_ONLY
    
    BUILD_ONLY --> STEPS1["• Lint<br/>• Test<br/>• Build<br/>• Package<br/>• Security Scan"]
    FULL_DEPLOY --> STEPS2["• Lint<br/>• Test<br/>• Build<br/>• Package<br/>• Security Scan<br/>• Deploy to K8s"]
    
    STEPS1 --> END1[Image in GHCR]
    STEPS2 --> END2[Running in K8s]
```

## Error Handling and Resilience

### Helm Conflict Resolution
```bash
# Automatic cleanup of stuck operations
if helm list -n default --pending --failed | grep -q go-sample-app; then
  echo "⚠️ Found stuck Helm operation, cleaning up..."
  helm uninstall go-sample-app -n default || true
  sleep 5
fi
```

### Authentication
- **GHCR**: Uses `${{ github.token }}` for authentication
- **Kubernetes**: Uses `ghcr-secret` for image pulls
- **Self-hosted**: Runner has direct cluster access

## Monitoring and Observability

### Pipeline Visibility
- **GitHub Actions UI**: Real-time job progress
- **Step Summaries**: Deployment details and status
- **Artifacts**: Test coverage, security reports
- **Container Registry**: Image versions and metadata

### Application Monitoring
- **Health Endpoint**: `/health` for status checks
- **Web Interface**: `http://localhost:8080` for testing
- **API Endpoints**: REST API for calculator operations
- **Kubernetes**: Pod status, service endpoints, logs

## Benefits of This Architecture

1. **Modularity**: Reusable actions across multiple projects
2. **Consistency**: Standardized build and deployment patterns
3. **Local Development**: Self-hosted runner with direct cluster access
4. **Security**: Automated scanning and secure image handling
5. **Flexibility**: Manual deployment control with automatic builds
6. **Observability**: Comprehensive logging and status reporting

This architecture provides a robust, scalable foundation for Go application development and deployment while maintaining developer productivity and operational reliability. 