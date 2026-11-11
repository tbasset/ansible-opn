# Préparation Openstack

```
cd /opt/openstack-ansible/playbooks
openstack-ansible haproxy-install.yml
openstack-ansible k8s-install.yml -vvv      # → openstack.osa.k8s
openstack-ansible os-magnum-install.yml
```

```
openstack coe service list
openstack coe cluster list
openstack coe cluster template list
```

```
# https://github.com/vexxhost/capo-image-elements/releases/download/2026.11-1/ubuntu-22.04-v1.35.10.qcow2
```
```
KUBE_TAG=v1.35.10
IMG=ubuntu-22.04-${KUBE_TAG}
curl -LO https://github.com/vexxhost/capo-image-elements/releases/download/2026.11-1/${IMG}.qcow2
sha256sum ${IMG}.qcow2                     # sha256:7c1c34949e8216af179ac5fe9962a4ff563c59fae1f2b82d4ed4b29751e0daa4 
qemu-img info ${IMG}.qcow2                 # format: qcow2
openstack image create ${IMG} --disk-format qcow2 --container-format bare \
  --property os_distro=ubuntu --file ${IMG}.qcow2
```

```
openstack coe cluster template create k8s-${KUBE_TAG}-ovn-lb \
  --coe kubernetes --image ${IMG} --external-network EXTERNE \
  --master-flavor k8s.small --flavor k8s.small \
  --network-driver calico --docker-storage-driver overlay2 \
  --dns-nameserver 192.168.133.251 --floating-ip-enabled --master-lb-enabled \
  --labels kube_tag=${KUBE_TAG},octavia_provider=ovn
```

```
openstack coe cluster create test1 --cluster-template k8s-${KUBE_TAG}-ovn-lb \
  --master-count 1 --node-count 1 --keypair ctrl-ansible --timeout 60
```

```
mkdir -p ~/test1 
openstack coe cluster config test1 --dir ~/test1
export KUBECONFIG=~/test1/config
```
```
kubectl get nodes -o wide
kubectl get pods -A
```

```
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

```
kubectl patch storageclass block-nfs-storage1 \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

```
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update
helm install headlamp headlamp/headlamp --namespace kube-system \
  --set service.type=LoadBalancer
kubectl -n kube-system get svc headlamp -w      # attendre l'EXTERNAL-IP
kubectl -n kube-system create token headlamp --duration=24h
```

<!-- MARK: DEMO -->
# Démo, app web, auto-repair, kube scaling, openstack scaling

```
export KUBECONFIG=~/test1/config
```

```
helm repo add podinfo https://stefanprodan.github.io/podinfo
helm upgrade --install --wait podinfo podinfo/podinfo -n demo --create-namespace \
  --set replicaCount=3 --set backend=http://backend-podinfo:9898/echo --set service.type=LoadBalancer
```

```
kubectl -n demo get svc podinfo -w
```

```
export SERVICE_IP=$(kubectl get svc --namespace demo podinfo -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo http://$SERVICE_IP:9898
```

## Scaling
```
kubectl -n demo scale deploy podinfo --replicas=6
```

## Rolling update
```
helm upgrade podinfo podinfo/podinfo -n demo --reuse-values --set ui.color=#34577c
```
## Auto repair
```
kubectl -n demo delete pod <un-pod>
```

## Cluster kube scaling
```
openstack coe cluster resize test1 3
```

## Spreading
```
cat > test1/podinfo-spread.yaml<<EOF
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: podinfo
EOF
```

```
helm upgrade podinfo podinfo/podinfo -n demo --reuse-values -f test1/podinfo-spread.yaml
kubectl -n demo get pods -o wide
```

```
cat > test1/podinfo-spread.yaml<<EOF
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: DoNotSchedule
    nodeTaintsPolicy: Honor
    matchLabelKeys: ["pod-template-hash"]
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: podinfo
EOF
```

```
helm upgrade podinfo podinfo/podinfo -n demo --reuse-values -f podinfo-spread.yaml
kubectl -n demo get pods -o wide
```

```
kubectl -n demo rollout restart deploy podinfo
```


l’auto-réparation, l’une des démonstrations les plus parlantes de cette architecture. 
Une précision sur qui fait quoi : ce n’est pas Magnum lui-même qui a réagi, mais Cluster API, dans le cluster de management. 
Magnum ne fait que refléter l’état du cluster.

Voici ce qui s’est passé :

Côté Openstack, la VM s’éteint. (simulant une panne d'hôte qui portait ce workder).
Le kubelet ne répond plus, et le nœud passe NotReady dans le cluster invité.
Une MachineHealthCheck (MHC) de CAPI le détecte. Elle surveille l’état des nœuds. 

Après un délai configuré, de quelques minutes, elle déclare la Machine en mauvais état et lance la remédiation.
Le MachineSet du groupe de workers constate qu’il manque une machine en bon état pour atteindre la cible de 3. 
CAPO crée une nouvelle VM, qui rejoint le cluster grâce à kubeadm.
L’ancienne Machine est supprimée. CAPO détruit la VM éteinte.

Côté Kubernetes, les pods de l’ancien nœud sont recréés. 
La contrainte de répartition les envoie sur le nouveau nœud, le seul qui n’avait aucun pod. 
Comme il s’agit de nouveaux pods, le scheduler les place correctement.

Ce scénario fait une bonne démonstration en trois temps :

1. openstack server stop <vm-worker>, simulant une panne matérielle ;
2. on regarde podinfo continuer de répondre, avec 2 pods sur 3 ;
3. quelques minutes plus tard, une nouvelle VM apparaît, rejoint le cluster, et le système revient à 3 workers et 3 pods répartis. 

Personne n’est intervenu.

<!-- MARK: DEMO2 -->
# Démo2, onlineboutique

```
export KUBECONFIG=~/test1/config
```
```
helm upgrade onlineboutique oci://us-docker.pkg.dev/online-boutique-ci/charts/onlineboutique \
  --install --create-namespace -n onlineboutique
kubectl -n onlineboutique get pods -o wide -w  
```

## Stockage persistant pour redis
```
kubectl -n onlineboutique apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-cart-data
spec:
  storageClassName: block-nfs-storage1
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 1Gi
EOF
```

```
kubectl -n onlineboutique patch deploy redis-cart --type=json -p='[
  {"op":"replace","path":"/spec/template/spec/volumes/0","value":{"name":"redis-data","persistentVolumeClaim":{"claimName":"redis-cart-data"}}},
  {"op":"add","path":"/spec/template/spec/containers/0/args","value":["--appendonly","yes"]},
  {"op":"replace","path":"/spec/strategy","value":{"type":"Recreate"}}
]'
```

```
helm uninstall onlineboutique -n onlineboutique
kubectl delete ns onlineboutique
```

<!-- MARK: la suite... -->
la suite .. ?



# Réseau et exposition HTTP
<!-- MARK: Traefik -->
## Traefik, un contrôleur d’Ingress et de Gateway API.

```
helm repo add traefik https://traefik.github.io/charts
helm install traefik traefik/traefik -n traefik --create-namespace
kubectl -n traefik get svc traefik -w          # EXTERNAL-IP = load-balancer Octavia OVN
```
```
export TRAEFIK_IP=<EXTERNAL-IP>
export DOMAIN=${TRAEFIK_IP}.nip.io             # ou k8s.lab
```
<!-- MARK: cert-manager -->
## cert-manager, à combiner avec Traefik, pour des certificats TLS automatiques.

```
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager -n cert-manager --create-namespace --set crds.enabled=true
```

```
kubectl apply -f - <<'EOF'
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata: {name: selfsigned}
spec: {selfSigned: {}}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata: {name: lab-ca, namespace: cert-manager}
spec:
  isCA: true
  commonName: homelab-k8s-ca
  secretName: lab-ca
  issuerRef: {name: selfsigned, kind: ClusterIssuer}
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata: {name: lab-ca}
spec: {ca: {secretName: lab-ca}}
EOF
```
```
kubectl get clusterissuer
kubectl -n cert-manager get secret lab-ca -o jsonpath='{.data.ca\.crt}' | base64 -d > homelab-k8s-ca.crt
```

# Observabilité

<!-- MARK: metrics-server -->
## metrics-server, tout petit, rend kubectl top fonctionnel et permet l’autoscaling. Combiné à podinfo (--set hpa.enabled=true) et à un générateur de charge.

```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm install metrics-server metrics-server/metrics-server -n kube-system \
  --set 'args={--kubelet-insecure-tls}'
```
```
kubectl top nodes                # fonctionne après ~1 min
```

```
helm upgrade podinfo podinfo/podinfo -n demo --reuse-values \
  --set resources.requests.cpu=50m \
  --set hpa.enabled=true --set hpa.maxReplicas=9 --set hpa.cpu=60 \
  --set service.type=ClusterIP \
  --set-json "ingress={\"enabled\":true,\"className\":\"traefik\",\"annotations\":{\"cert-manager.io/cluster-issuer\":\"lab-ca\"},\"hosts\":[{\"host\":\"podinfo.${DOMAIN}\",\"paths\":[{\"path\":\"/\",\"pathType\":\"ImplementationSpecific\"}]}],\"tls\":[{\"secretName\":\"podinfo-tls\",\"hosts\":[\"podinfo.${DOMAIN}\"]}]}"
```

```
kubectl -n demo run load --image=busybox --restart=Never -- \
  /bin/sh -c 'while true; do wget -q -O- http://podinfo:9898/ >/dev/null; done'
```

```
kubectl -n demo get hpa -w
```

```
kubectl -n demo delete pod load   # ils redescendent après environ 5 min
```
<!-- MARK: Uptime Kuma -->
## Uptime Kuma : un outil de supervision d’URL et de services avec une interface agréable, qui tient sur un seul petit volume.

```
helm repo add uptime-kuma https://helm.irsigler.cloud
helm show values uptime-kuma/uptime-kuma | grep -nE "^(volume|ingress):" -A6    # vérifier les clés
```

```
helm install uptime-kuma uptime-kuma/uptime-kuma -n monitoring --create-namespace \
  --set volume.enabled=true --set volume.size=2Gi \
  --set ingress.enabled=true --set ingress.className=traefik \
  --set-json "ingress.hosts=[{\"host\":\"status.${DOMAIN}\",\"paths\":[{\"path\":\"/\",\"pathType\":\"Prefix\"}]}]" \
  --set-json "ingress.tls=[{\"secretName\":\"kuma-tls\",\"hosts\":[\"status.${DOMAIN}\"]}]" \
  --set ingress.annotations."cert-manager\.io/cluster-issuer"=lab-ca
```

# Applications avec des données
<!-- MARK: Gitea -->
## Gitea : une forge Git légère avec sa base de données et ses dépôts sur volumes persistants.

```
helm repo add gitea-charts https://dl.gitea.com/charts/
helm show values gitea-charts/gitea | grep -nE "^(postgresql|postgresql-ha|valkey|valkey-cluster):" -A2   # vérifier les noms des clés
```

```
helm install gitea gitea-charts/gitea -n gitea --create-namespace \
  --set postgresql-ha.enabled=false --set postgresql.enabled=false \
  --set valkey-cluster.enabled=false --set valkey.enabled=false \
  --set gitea.config.database.DB_TYPE=sqlite3 \
  --set gitea.config.session.PROVIDER=memory --set gitea.config.cache.ADAPTER=memory \
  --set gitea.config.queue.TYPE=level \
  --set persistence.size=5Gi \
  --set gitea.admin.username=gitadmin --set gitea.admin.password='P4p1llon!!' \
  --set ingress.enabled=true --set ingress.className=traefik \
  --set-json "ingress.hosts=[{\"host\":\"git.${DOMAIN}\",\"paths\":[{\"path\":\"/\",\"pathType\":\"Prefix\"}]}]" \
  --set-json "ingress.tls=[{\"secretName\":\"gitea-tls\",\"hosts\":[\"git.${DOMAIN}\"]}]" \
  --set ingress.annotations."cert-manager\.io/cluster-issuer"=lab-ca
```

```
kubectl -n gitea get pvc         # volume Cinder Bound
```

# GitOps
<!-- MARK: Argo CD -->
## Argo CD : un manifeste ou un values.yaml dans un dépôt GitHub, et le cluster se met à jour tout seul.

```
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace \
  --set 'configs.params.server\.insecure=true' \
  --set server.ingress.enabled=true --set server.ingress.ingressClassName=traefik \
  --set server.ingress.hostname=argocd.${DOMAIN} --set server.ingress.tls=true \
  --set server.ingress.annotations."cert-manager\.io/cluster-issuer"=lab-ca
```

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
```

# Sécurité et Résilience

<!-- MARK: Trivy -->
## Trivy Operator analyse en continu les images déployées et publie leurs vulnérabilités sous forme de ressources Kubernetes, visibles dans Headlamp.

```
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm install trivy-operator aqua/trivy-operator -n trivy-system --create-namespace \
  --set trivy.ignoreUnfixed=true \
  --set operator.scanJobsConcurrentLimit=1 \
  --set nodeCollector.excludeNodes='node-role.kubernetes.io/control-plane='
```

```
kubectl get vulnerabilityreports -A -o wide      # remplissage progressif en quelques minutes
kubectl get configauditreports -A -o wide
```

```
kubectl get vulnerabilityreports -A -o json | jq -r '
  .items[] | [.metadata.namespace,
              .report.artifact.repository + ":" + (.report.artifact.tag // ""),
              .report.summary.criticalCount, .report.summary.highCount] | @tsv' \
  | sort -t$'\t' -k3,3nr -k4,4nr | column -t | head -20
```

```
kubectl -n demo get vulnerabilityreports                         # nom du rapport, ex : replicaset-podinfo-xxxx-podinfo
kubectl -n demo get vulnerabilityreport <nom> -o json | jq -r '
  .report.vulnerabilities[] | select(.severity=="CRITICAL" or .severity=="HIGH")
  | [.severity, .vulnerabilityID, .resource, .installedVersion, .fixedVersion, .title] | @tsv' | column -t -s$'\t'
```

<!-- MARK: Renovate -->
## Renovate

```
GITEA_TOKEN=3600668f6c753a72e078fb42c7e1a274e1468b90
```

```
kubectl create ns renovate
kubectl -n renovate create secret generic renovate-env \
  --from-literal=RENOVATE_TOKEN="$GITEA_TOKEN"
```

```
cd ~/demo-gitops
cat > renovate-config.json <<EOF
{
  "platform": "gitea",
  "endpoint": "http://gitea-http.gitea.svc.cluster.local:3000/api/v1",
  "gitUrl": "endpoint",
  "gitAuthor": "Renovate Bot <renovate@homelab.local>",
  "autodiscover": false,
  "repositories": ["gitadmin/demo-gitops"],
  "onboarding": false,
  "requireConfig": "optional"
}
EOF
```

```
git add renovate-config.json && git commit -m "Config Renovate" && git push
```

```
helm install renovate oci://ghcr.io/renovatebot/charts/renovate -n renovate \
  --set-file renovate.config=renovate-config.json \
  --set existingSecret=renovate-env \
  --set cronjob.schedule='0 * * * *'
```

```
kubectl apply -f - <<'EOF'
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: demo-apps
  namespace: argocd
spec:
  goTemplate: true
  generators:
    - git:
        repoURL: http://gitea-http.gitea.svc.cluster.local:3000/gitadmin/demo-gitops.git
        revision: main
        directories:
          - path: apps/*
  template:
    metadata:
      name: '{{.path.basename}}'
    spec:
      project: default
      source:
        repoURL: http://gitea-http.gitea.svc.cluster.local:3000/gitadmin/demo-gitops.git
        targetRevision: main
        path: '{{.path.path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{.path.basename}}'
      syncPolicy:
        automated: {prune: true, selfHeal: true}
        syncOptions: [CreateNamespace=true]
EOF
```

<!-- MARK: Sealed secrets -->
# Sealed secrets

```
cd ~/demo-gitops && git pull
mkdir -p apps/sealed-secrets
```

```
cat > apps/sealed-secrets/Chart.yaml <<EOF
apiVersion: v2
name: sealed-secrets
version: 0.1.0
dependencies:
  - name: sealed-secrets
    version: "2.22.0"
    repository: https://bitnami-labs.github.io/sealed-secrets
EOF
```

```
cat > apps/sealed-secrets/values.yaml <<EOF
sealed-secrets:
  fullnameOverride: sealed-secrets-controller   # nom attendu par défaut par kubeseal
EOF
```

```
git add apps/sealed-secrets && git commit -m "Ajout de Sealed Secrets" && git push
```

```
cd ~
V=0.41.2
curl -LO https://github.com/bitnami-labs/sealed-secrets/releases/download/v${V}/kubeseal-${V}-linux-amd64.tar.gz
tar xzf kubeseal-${V}-linux-amd64.tar.gz kubeseal && install -m 0755 kubeseal /usr/local/bin/ && rm kubeseal*
kubeseal --version
```

```
echo 'export SEALED_SECRETS_CONTROLLER_NAMESPACE=sealed-secrets' >> ~/.bashrc && source ~/.bashrc
kubectl -n sealed-secrets get secret -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > ~/sealed-secrets-key-BACKUP.yaml
chmod 600 ~/sealed-secrets-key-BACKUP.yaml
```

# secret pour podinfo

```
cd ~/demo-gitops
```
```
mkdir -p apps/podinfo/templates
```
```
kubectl create secret generic podinfo-demo -n podinfo \
  --from-literal=message='Ce texte vient d un secret chiffré dans Git' \
  --dry-run=client -o yaml \
| kubeseal --format yaml > apps/podinfo/templates/podinfo-demo-sealed.yaml
```
```
cat apps/podinfo/templates/podinfo-demo-sealed.yaml       # le contenu est illisible : c'est le but
```

# secret pour Renovate

```
cd ~/demo-gitops && mkdir -p apps/renovate/templates
```
```
TOKEN=$(kubectl -n renovate get secret renovate-env -o jsonpath='{.data.RENOVATE_TOKEN}' | base64 -d)
```
```
kubectl create secret generic renovate-env -n renovate \
  --from-literal=RENOVATE_TOKEN="$TOKEN" --dry-run=client -o yaml \
| kubeseal --format yaml > apps/renovate/templates/renovate-env-sealed.yaml
```
```
unset TOKEN
```

```
cat > apps/renovate/Chart.yaml <<EOF
apiVersion: v2
name: renovate
version: 0.1.0
dependencies:
  - name: renovate
    version: "46.424.0"
    repository: oci://ghcr.io/renovatebot/charts
EOF
```

```
cat > apps/renovate/values.yaml <<EOF
renovate:
  cronjob:
    schedule: "0 * * * *"
  existingSecret: renovate-env
  renovate:
    config: |
      {
        "platform": "gitea",
        "endpoint": "http://gitea-http.gitea.svc.cluster.local:3000/api/v1",
        "gitUrl": "endpoint",
        "gitAuthor": "Renovate Bot <renovate@homelab.local>",
        "autodiscover": false,
        "repositories": ["gitadmin/demo-gitops"],
        "onboarding": false,
        "requireConfig": "optional"
      }
EOF
```

```
helm uninstall renovate -n renovate
kubectl -n renovate delete secret renovate-env
```

```
git add apps/renovate && git commit -m "Renovate géré par Argo CD, jeton chiffré" && git push
```

<!-- MARK: Argo rollouts -->
# Argo rollouts

```
cd ~/demo-gitops
mkdir -p apps/argo-rollouts
```

```
cat > apps/argo-rollouts/Charts.yaml <<EOF
apiVersion: v2
name: argo-rollouts
version: 0.1.0
dependencies:
  - name: argo-rollouts
    version: "2.43.12"
    repository: https://argoproj.github.io/argo-helm
EOF
```

```
cat > apps/argo-rollouts/value.yaml <<EOF
argo-rollouts:
  dashboard:
    enabled: true
    ingress:
      enabled: true
      ingressClassName: traefik
      annotations:
        cert-manager.io/cluster-issuer: lab-ca
      hosts:
        - rollouts.k8s.lab
      tls:
        - secretName: rollouts-dashboard-tls
          hosts:
            - rollouts.k8s.lab
EOF
```

```
cd ~
curl -LO https://github.com/argoproj/argo-rollouts/releases/download/v1.10.2/kubectl-argo-rollouts-linux-amd64
install -m 0755 kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts && rm kubectl-argo-rollouts-linux-amd64
kubectl argo rollouts version
```

```
cd ~/demo-gitops 
git add apps/argo-rollouts && git commit -m "Argo rollouts controller" && git push
```

```
cd ~/demo-gitops 
mkdir -p apps/podinfo-canary
```

```
cat > apps/podinfo-canary/rollout.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: podinfo-canary
spec:
  replicas: 5
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: podinfo-canary
  template:
    metadata:
      labels:
        app: podinfo-canary
    spec:
      containers:
        - name: podinfo
          image: ghcr.io/stefanprodan/podinfo:6.9.0
          ports:
            - name: http
              containerPort: 9898
          env:
            - name: PODINFO_UI_COLOR
              value: "#34577c"
            - name: PODINFO_UI_MESSAGE
              value: "Version 1 - bleu"
          readinessProbe:
            httpGet: {path: /readyz, port: http}
          resources:
            requests: {cpu: 10m, memory: 32Mi}
  strategy:
    canary:
      steps:
        - setWeight: 20          # 1 pod sur 5 en nouvelle version
        - pause: {}              # attend une validation manuelle
        - setWeight: 60
        - pause: {duration: 30s}
        # puis passage automatique à 100 %
EOF
```

```
cat > apps/podinfo-canary/service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: podinfo-canary
spec:
  selector:
    app: podinfo-canary
  ports:
    - port: 80
      targetPort: http
EOF
```

```
cat > apps/podinfo-canary/ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: podinfo-canary
  annotations:
    cert-manager.io/cluster-issuer: lab-ca
spec:
  ingressClassName: traefik
  rules:
    - host: canary.k8s.lab
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service: {name: podinfo-canary, port: {number: 80}}
  tls:
    - secretName: podinfo-canary-tls
      hosts: [canary.k8s.lab]
EOF
```

```
cd ~/demo-gitops
git add apps/argo-rollouts apps/podinfo-canary
git commit -m "Argo Rollouts et démonstration canary" && git push
```

<!-- MARK: Kyverno -->
# Kyverno pour imposer des règles, par exemple refuser les images :latest ou exiger des limites de ressources.

```
helm repo add kyverno https://kyverno.github.io/kyverno/ && helm repo update
helm search repo kyverno/kyverno --versions | head -3
helm search repo kyverno/kyverno-policies --versions | head -3
```

```
cd ~/demo-gitops
mkdir -p apps/kyverno
```

```
cat > apps/kyverno/Chart.yaml <<EOF
apiVersion: v2
name: kyverno
version: 0.1.0
dependencies:
  - name: kyverno
    version: "3.10.0"
    repository: https://kyverno.github.io/kyverno/
  - name: kyverno-policies
    version: "3.10.0"
    repository: https://kyverno.github.io/kyverno/
EOF
```

```
cat > apps/kyverno/values.yaml <<EOF
kyverno-policies:
  podSecurityStandard: baseline
  validationFailureAction: Audit
  failurePolicy: Ignore              # si Kyverno est en panne, on laisse passer au lieu de bloquer
  vpolExclude:
    excludeNamespaces:               # ces namespaces ne sont ni contrôlés ni rapportés
      - kube-system
      - kyverno
EOF
```

```
mkdir -p apps/kyverno/templates
```

```
cat > apps/kyverno/templates/disallow-latest-tag.yaml <<EOF
apiVersion: policies.kyverno.io/v1          # adapter selon api-resources
kind: ValidatingPolicy
metadata:
  name: disallow-latest-tag
  annotations:
    policies.kyverno.io/title: Interdire le tag latest
    policies.kyverno.io/severity: medium
spec:
 spec:
  validationActions: [Audit]
  failurePolicy: Ignore
  matchConstraints:
    namespaceSelector:
      matchExpressions:
        - key: kubernetes.io/metadata.name
          operator: NotIn
          values: [kube-system, kyverno]
    resourceRules:
      - apiGroups: [""]
        apiVersions: [v1]
        operations: [CREATE, UPDATE]
        resources: [pods]
  validations:
    - expression: >-
        object.spec.containers.all(c,
          c.image.substring(c.image.lastIndexOf('/') + 1).contains(':') &&
          !c.image.endsWith(':latest'))
      message: "Un tag d'image explicite est obligatoire, et ':latest' est interdit."
EOF
```

```
cd ~/demo-gitops && git add apps/kyverno
```

<!-- MARK: Policy reporter -->
## Policy Reporter

```
mkdir -p apps/policy-reporter
```

```
cat > apps/policy-reporter/Chart.yaml <<EOF
apiVersion: v2
name: policy-reporter
version: 0.1.0
dependencies:
  - name: policy-reporter
    version: "3.11.2"
    repository: https://kyverno.github.io/policy-reporter
EOF
```

```
cat > apps/policy-reporter/values.yaml <<EOF
policy-reporter:
  plugin:
    kyverno:
      enabled: true      # détails des politiques Kyverno dans l'interface
    trivy:
      enabled: true      # affiche aussi les rapports de Trivy Operator
  ui:
    enabled: true
    ingress:
      enabled: true
      className: traefik
      annotations:
        cert-manager.io/cluster-issuer: lab-ca
      hosts:
        - host: policies.k8s.lab
          paths:
            - path: /
              pathType: Prefix
      tls:
        - secretName: policy-reporter-tls
          hosts:
            - policies.k8s.lab
EOF
```

```
cd ~/demo-gitops && git add apps/policy-reporter
```

```
cd ~/demo-gitops && mkdir -p bootstrap
```

```
cat > bootstrap/applicationset.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: demo-apps
  namespace: argocd
spec:
  goTemplate: true
  generators:
    - git:
        repoURL: http://gitea-http.gitea.svc.cluster.local:3000/gitadmin/demo-gitops.git
        revision: main
        directories:
          - path: apps/*
  template:
    metadata:
      name: '{{.path.basename}}'
    spec:
      project: default
      source:
        repoURL: http://gitea-http.gitea.svc.cluster.local:3000/gitadmin/demo-gitops.git
        targetRevision: main
        path: '{{.path.path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{.path.basename}}'
      syncPolicy:
        automated: {prune: true, selfHeal: true}
        syncOptions:
          - CreateNamespace=true
          - ServerSideApply=true
EOF
```
```
kubectl apply -f bootstrap/applicationset.yaml      # identique à l'état actuel : aucun changement
```

```
git add bootstrap && git commit -m "ApplicationSet versionné, avec ServerSideApply" && git push
```

```
kubectl apply -f - <<'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bootstrap
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc.cluster.local:3000/gitadmin/demo-gitops.git
    targetRevision: main
    path: bootstrap
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated: {prune: false, selfHeal: true}
EOF
```

```
git commit -m "Kyverno, politiques baseline et Policy Reporter" && git push
```

<!-- MARK: Falco -->
## Falco

<!-- MARK: Chaos Mesh -->
## Chaos Mesh ou LitmusChaos pour injecter des pannes.

<!-- MARK: Homepage -->
## Homepage

```
cd ~/demo-gitops
mkdir -p apps/homepage
```

```
cat > apps/homepage/Chart.yaml <<EOF
apiVersion: v2
name: homepage
version: 0.1.0
dependencies:
  - name: homepage
    version: "2.1.0"
    repository: https://jameswynn.github.io/helm-charts
EOF
```

```
cat > apps/homepage/values.yaml <<EOF
homepage:
  enableRbac: true              # nécessaire pour les widgets Kubernetes
  serviceAccount:
    create: true

  env:
    - name: HOMEPAGE_ALLOWED_HOSTS
      value: "home.k8s.lab"    # obligatoire depuis la v1 de Homepage

  ingress:
    main:
      enabled: true
      ingressClassName: traefik
      annotations:
        cert-manager.io/cluster-issuer: lab-ca
      hosts:
        - host: home.k8s.lab
          paths:
            - path: /
              pathType: Prefix
      tls:
        - secretName: homepage-tls
          hosts:
            - home.k8s.lab

  config:
    kubernetes:
      mode: cluster

    widgets:
      - kubernetes:
          cluster: {show: true, cpu: true, memory: true, showLabel: true, label: "test1"}
          nodes:   {show: true, cpu: true, memory: true, showLabel: true}
      - search:
          provider: duckduckgo
          target: _blank

    services:
      - OpenStack:
          - Horizon:
              href: https://192.168.133.3/
              description: Tableau de bord OpenStack
              icon: openstack.png
          - Uptime Kuma:
              href: https://status.k8s.lab
              description: Disponibilité des services
              icon: uptime-kuma.png
              siteMonitor: http://uptime-kuma.monitoring.svc.cluster.local:3001
          - Infra LAB (statut):
              href: https://status.k8s.lab/status/lab
              description: Disponibilité de l'infra du LAB
              icon: openstack.png
              widget:
                type: uptimekuma
                url: http://uptime-kuma.monitoring.svc.cluster.local:3001
                slug: lab
      - Kubernetes:
          - Headlamp:
              href: http://<IP_HEADLAMP>
              description: Interface du cluster test1
              icon: headlamp.png
          - Argo CD:
              href: https://argocd.k8s.lab
              description: Déploiement GitOps
              icon: argo-cd.png
              siteMonitor: http://argocd-server.argocd.svc.cluster.local
          - Argo Rollouts:
              href: https://rollouts.k8s.lab
              description: Déploiements canary
              icon: argo-cd.png
      - Développement:
          - Gitea:
              href: https://git.k8s.lab
              description: Dépôts Git et registre d'images
              icon: gitea.png
              siteMonitor: http://gitea-http.gitea.svc.cluster.local:3000
      - Démos:
          - podinfo:
              href: https://gitops.k8s.lab
              description: Application GitOps
              icon: mdi-rocket-launch
          - podinfo canary:
              href: https://canary.k8s.lab
              description: Démonstration Argo Rollouts
              icon: mdi-bird

    settingsString: |
      title: Homelab OpenStack
      theme: dark
      color: slate
      headerStyle: boxed
      layout:
        OpenStack:
          style: row
          columns: 2
        Kubernetes:
          style: row
          columns: 3
        Développement:
        Démos:
          style: row
          columns: 2
EOF
```

```
cd ~/demo-gitops
git add apps/homepage && git commit -m "Homepage, page d'accueil du homelab" && git push
```

NAME: headlamp
LAST DEPLOYED: Wed Nov 11 21:51:56 2026
NAMESPACE: kube-system
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  https://headlamp.k8s.lab/
2. Get the token using
  kubectl create token headlamp --namespace kube-system
