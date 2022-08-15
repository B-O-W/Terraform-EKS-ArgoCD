    #!/usr/bin/env bash
    # Author: Mammadov Elbrus | 28.07.22 | Provision IaaC
    # Main Functions:
    function main() {
        provisionClusters
        loadKubeConfig
        deployArgoCD
    }

    function terraformProvision() { # Terraform commands
        terraform init -upgrade
        terraform plan
        terraform apply --auto-approve
    }

    function provisionClusters() { # Provision EKS Cluster
        terraformProvision
    }

    function loadKubeConfig() { # Load Kubernetes Config file
        aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
        kubectl apply -f ./manifest
    }

    function deployArgoCD() { # Deploy ArgoCd
        kubectl create namespace argocd
        kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
        kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
        kubectl apply -f argocd/
        kubectl get svc -n argocd | grep argocd-server | head -n 1 | awk '{print$4}'; echo "  Go to this link it's alb default user admin"
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; |echo "  It's password:"
    }
    main