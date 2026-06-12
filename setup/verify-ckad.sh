#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "===================================================="
echo "          CKAD PRACTICE VERIFICATION SCRIPT         "
echo "===================================================="

# --- Q1 Verification ---
echo -n "Question 1 (Secret Integration): "
SECRET_USER=$(kubectl get secret db-credentials -n q1 -o jsonpath='{.data.DB_USER}' 2>/dev/null | base64 --decode)
DEPLOY_ENV=$(kubectl get deploy api-server -n q1 -o jsonpath='{.spec.template.spec.containers[0].env[0].valueFrom.secretKeyRef.name}' 2>/dev/null)
if [ "$SECRET_USER" == "admin" ] && [ "$DEPLOY_ENV" == "db-credentials" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (Secret missing or Deployment not utilizing secretKeyRef)"
fi

# --- Q2 Verification ---
echo -n "Question 2 (CronJob Setup): "
CJ_SCHED=$(kubectl get cronjob backup-job -n q2 -o jsonpath='{.spec.schedule}' 2>/dev/null)
CJ_SUCC=$(kubectl get cronjob backup-job -n q2 -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
if [ "$CJ_SCHED" == "*/30 * * * *" ] && [ "$CJ_SUCC" == "3" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (CronJob missing, schedule configuration, or history limits incorrect)"
fi

# --- Q3 Verification ---
echo -n "Question 3 (RBAC Authorization): "
SA_CHECK=$(kubectl get sa log-sa -n q3 2>/dev/null)
POD_SA=$(kubectl get pod log-collector -n q3 -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
AUTH_CHECK=$(kubectl auth can-i list pods --as=system:serviceaccount:q3:log-sa -n q3 2>/dev/null)
if [ -n "$SA_CHECK" ] && [ "$POD_SA" == "log-sa" ] && [ "$AUTH_CHECK" == "yes" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (ServiceAccount permissions or Pod assignment incorrect)"
fi

# --- Q4 Verification ---
echo -n "Question 4 (Fix Pod ServiceAccount): "
MONITOR_SA_POD=$(kubectl get pod metrics-pod -n q4 -o jsonpath='{.spec.serviceAccountName}' 2>/dev/null)
if [ "$MONITOR_SA_POD" == "monitor-sa" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (metrics-pod is not switched to monitor-sa)"
fi

# --- Q5 Verification ---
echo -n "Question 5 (Local Image Tarball): "
if [ -f "/root/my-app.tar" ] || [ -f "./my-app.tar" ]; then
    echo -e "${GREEN}[PASS]${NC} (Tarball exists locally)"
else
    echo -e "${RED}[SKIPPED/FAIL]${NC} (Check manual host execution for /root/my-app.tar)"
fi

# --- Q6 Verification ---
echo -n "Question 6 (Canary Deployment Split): "
V1_REPLICAS=$(kubectl get deploy web-app -n q6 -o jsonpath='{.spec.replicas}' 2>/dev/null)
CANARY_EXIST=$(kubectl get deploy web-app-canary -n q6 2>/dev/null)
SVC_SELECTOR=$(kubectl get svc web-service -n q6 -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$V1_REPLICAS" == "8" ] && [ -n "$CANARY_EXIST" ] && [ "$SVC_SELECTOR" == "webapp" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (Deployment scaling or canary target mismatches)"
fi

# --- Q7 Verification (UPDATED) ---
echo -n "Question 7 (NetworkPolicy Targets): "
FRONTEND_LBL=$(kubectl get pod frontend -n q7 -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
BACKEND_LBL=$(kubectl get pod backend -n q7 -o jsonpath='{.metadata.labels.role}' 2>/dev/null)
DATABASE_LBL=$(kubectl get pod database -n q7 -o jsonpath='{.metadata.labels.role}' 2>/dev/null)

if [ "$FRONTEND_LBL" == "frontend" ] && [ "$BACKEND_LBL" == "backend" ] && [ "$DATABASE_LBL" == "db" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (One or more pod labels in namespace q7 are incorrect)"
fi

# --- Q8 Verification ---
echo -n "Question 8 (Fix Deployment YAML): "
DEPL_STATUS=$(kubectl get deploy broken-deploy -n q8 -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "$DEPL_STATUS" == "2" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (Broken deployment replicas are not ready/aligned)"
fi

# --- Q9 Verification ---
echo -n "Question 9 (Rolling Updates): "
CURRENT_IMG=$(kubectl get deploy nginx-deploy -n q9 -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
# Validates whether the environment cycle has been triggered to latest or toggled safely
if [ -n "$CURRENT_IMG" ]; then
    echo -e "${GREEN}[PASS]${NC} (Current active image deployment target: $CURRENT_IMG)"
else
    echo -e "${RED}[FAIL]${NC} (Deployment 'nginx-deploy' missing)"
fi

# --- Q10 Verification ---
echo -n "Question 10 (Readiness Probe): "
HAS_PROBE=$(kubectl get deploy web-server -n q10 -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' 2>/dev/null)
if [ -n "$HAS_PROBE" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (Readiness Probe missing from Deployment container specification)"
fi

# --- Q11 Verification ---
echo -n "Question 11 (Security Contexts): "
RUN_USER=$(kubectl get pod secure-pod -n q11 -o jsonpath='{.spec.securityContext.runAsUser}' 2>/dev/null)
CONT_PRIV=$(kubectl get pod secure-pod -n q11 -o jsonpath='{.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null)
if [ -n "$RUN_USER" ] || [ "$CONT_PRIV" == "false" ]; then
    echo -e "${GREEN}[PASS]${NC} (Security configurations verified)"
else
    echo -e "${RED}[FAIL]${NC} (Security boundaries/contexts not found on the targeted resource)"
fi

# --- Q12 Verification ---
echo -n "Question 12 (Service Selector Fix): "
SVC_SEL_CORRECT=$(kubectl get svc web-svc -n q12 -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [ "$SVC_SEL_CORRECT" == "webapp" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (Service selector still mapped to '$SVC_SEL_CORRECT' instead of 'webapp')"
fi

# --- Q13 Verification ---
echo -n "Question 13 (NodePort Deployment): "
SVC_TYPE=$(kubectl get svc api-nodeport -n q13 -o jsonpath='{.spec.type}' 2>/dev/null)
SVC_PORT=$(kubectl get svc api-nodeport -n q13 -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
if [ "$SVC_TYPE" == "NodePort" ] && [ "$SVC_PORT" == "9090" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (Service is not NodePort type or targeting port 9090)"
fi

# --- Q14 Verification ---
echo -n "Question 14 (Ingress Creation): "
ING_HOST=$(kubectl get ingress web-ingress -n q14 -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)
ING_SVC=$(kubectl get ingress web-ingress -n q14 -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' 2>/dev/null)
if [ "$ING_HOST" == "web.example.com" ] && [ "$ING_SVC" == "web-svc" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (Ingress rule configuration misaligned or resource missing)"
fi

# --- Q15 Verification ---
echo -n "Question 15 (Ingress PathType Validation): "
ING_PTYPE=$(kubectl get ingress api-ingress -n q15 -o jsonpath='{.spec.rules[0].http.paths[0].pathType}' 2>/dev/null)
if [ "$ING_PTYPE" == "Prefix" ] || [ "$ING_PTYPE" == "Exact" ]; then
    echo -e "${GREEN}[PASS]${NC} (Valid dynamic path structural entry discovered: $ING_PTYPE)"
else
    echo -e "${RED}[FAIL]${NC} (Ingress PathType initialization issues exist)"
fi

# --- Q16 Verification (UPDATED EXACT CHECK) ---
echo -n "Question 16 (Resource Boundaries): "
REQ_CPU=$(kubectl get pod resource-pod -n q16 -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
REQ_MEM=$(kubectl get pod resource-pod -n q16 -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
LIM_CPU=$(kubectl get pod resource-pod -n q16 -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
LIM_MEM=$(kubectl get pod resource-pod -n q16 -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
POD_IMG=$(kubectl get pod resource-pod -n q16 -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)

# Strict validations for precise criteria matching
if [ "$POD_IMG" == "nginx:latest" ] && \
   [ "$REQ_CPU" == "100m" ] && \
   [ "$REQ_MEM" == "128Mi" ] && \
   [ "$LIM_CPU" == "250m" ] && \
   [ "$LIM_MEM" == "256Mi" ]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC} (Image, limits, or requests do not exactly match the quota constraints)"
fi

echo "===================================================="