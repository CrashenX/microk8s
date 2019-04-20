# homelab

## Setup

### Install Kubernetes

Tested with (on Ubuntu Server 18.04):

- [microk8s](https://microk8s.io/)
    - Can be installed during Ubuntu Server 18.04 installation or with `snap`
    - Add `alias kubectl='microk8s.kubectl'` to bashrc
    - NB: All DNS requests will show from 10.1.1.1 (docker bridge)

### Set up Helm / Tiller (with TLS)

    sudo snap install helm --classic
    pushd helm/
    SUBJ="/C=US/ST=State/L=City/O=A Corp/OU=Security/CN=example.com" ./setup.sh
    popd

Add this function to your bashrc (it saves typing and is used later on):

    shelm () {
            ( helm --tiller-namespace=tiller "$@" --tls )
    }

NB: You might want to logout and back in to reload bashrc

    shelm ls  # Verify working

### Setup MetalLB

    # NB: Your Start and End IPs must be in same subnet as your
    #     clients and outside the DHCP lease range.
    STARTIP=<192.168.x.n>
    ENDIP=<192.168.x.n+m>
    echo "Your IP range is: $STARTIP-$ENDIP"
    shelm install stable/metallb \
        --name metallb \
        --set rbac.create=true \
        --set configInline.address-pools[0].name="my-ip-space" \
        --set configInline.address-pools[0].protocol="layer2" \
        --set configInline.address-pools[0].addresses="{$STARTIP-$ENDIP}"

### Setup nginx ingress controller

    shelm install stable/nginx-ingress --name nginx --set rbac.create=true

## Setting up Pi-hole

    PHIPV4=$(kubectl get service nginx-nginx-ingress-controller -o json | jq -r '.status.loadBalancer.ingress[0].ip')
    echo "PHIPV4=$PHIPV4"  # verify correct IPs
    pushd helm/charts/pihole
    curl https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt > files/whitelist.txt
    curl https://v.firebog.net/hosts/lists.php?type=nocross > files/adlists.list
    shelm install . --name pihole --namespace=pihole --set host.ipv4=$PHIPV4
    popd

## Gotchas

  - I had to change the forwarding policy (`iptables -P FORWARD ACCEPT`), per
  [this bug](https://github.com/ubuntu/microk8s/issues/75).
