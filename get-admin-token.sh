#!/bin/bash
microk8s.kubectl -n kube-system get secret \
    $(microk8s.kubectl -n kube-system get secret | grep admin-user-token | awk '{print $1}') \
    -o json | jq -r '.data.token'
