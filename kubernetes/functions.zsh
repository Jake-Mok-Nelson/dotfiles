activate-terra ()
{
  gcloud auth activate-service-account terraform@${GCP_PROJECT}.iam.gserviceaccount.com --key-file ${GOOGLE_CREDENTIALS}
}

setns ()
{
	k config set-context $(k config current-context) --namespace $1
}

setCert ()
{
  sed -i .bak 's/certificate-authority-data.*/insecure-skip-tls-verify\: true/' ${KUBECONFIG}
  rm -f ${KUBECONFIG}.bak
}

setCluster()
{
	export CLUSTER=$(gcloud container clusters list --format=json | jq -r '.[0].name')
}

setcontext ()
{
  sed -i .bak "s/gke_.*-gke/${PROJECT}/g" ${KUBECONFIG}
  rm -f ${KUBECONFIG}.bak
}

get-public-creds ()
{
  rm -f ${KUBECONFIG}
  gcloud container clusters get-credentials ${CLUSTER} --region australia-southeast1 --project ${GCP_PROJECT}
}

get-private-creds ()
{
  rm -f ${KUBECONFIG}
  gcloud container clusters get-credentials ${CLUSTER} --region australia-southeast1 --project ${GCP_PROJECT} --internal-ip
}

setProxy ()
{
  TLSROUTER=$(kubectl get service -n kube-system tlsrouter-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}') || true
  if [ ! -z "$TLSROUTER" ]; then
      sed -i .bak "s/server.*/server\: https\:\/\/${TLSROUTER}/" ${KUBECONFIG}
  fi
  rm -f ${KUBECONFIG}.bak
}

getGClusterIP()
{
	gcloud container clusters list --format=json | jq -r '.[0].endpoint'
}

getGClusterIngress()
{
	k get svc -n ingress -ojson | jq '.items[0].status.loadBalancers.ingress[0].ip' | sed -e 's/^"//;s/"$//'
}
