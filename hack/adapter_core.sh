#!/bin/bash

patch_tinker_nginx() {
  local len=0
  len=$(kubectl -n maestro-boots-system  get service ingress-nginx-controller -ojsonpath='{.spec.ports}' | jq '. | length')
  if [ $len -eq 1 ];then
    kubectl -n maestro-boots-system  patch service ingress-nginx-controller -p '{"spec": {"ports": [{"appProtocol": "http", "name": "http", "port": 80, "protocol": "TCP", "targetPort": "http"}]}}'
  fi
}

patch_tinker_nginx
