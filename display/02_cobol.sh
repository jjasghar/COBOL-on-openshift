#!/bin/bash

ibmcloud ks cluster config --cluster bnsii9ud01t8k33m0qk0

export KUBECONFIG=/home/jjasghar/.bluemix/plugins/container-service/clusters/k9s.asgharlabs.io/kube-config-dal10-k9s.asgharlabs.io.yml

WATCHER=$(kubectl get pods | grep 'cobol' | awk {'print $1'})

kubectl logs ${WATCHER} -f
