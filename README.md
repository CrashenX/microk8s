# microk8s

## Enable addons

At a minimum you'll probably want:

- dns
- ingress
- storage

The list of addons and instructions on enabling can be found in the
[docs](https://github.com/ubuntu/microk8s#kubernetes-addons).

## Setting up Helm / Tiller

    sudo snap install helm --classic
    cd helm/; ./setup.sh  # Setup tiller with tls
    helm --tiller-namespace=tiller ls --tls  # Verify working

### Typing less

Add this to your bashrc:

    shelm () {
            ( helm --tiller-namespace=tiller "$@" --tls )
    }

NB: You might want to logout and back in to reload bashrc

Verify it works:

    shelm ls

## Setting up nginx ingress controller

    shelm install stable/nginx-ingress --name my-nginx --set rbac.create=true

## Setting up Pi-hole

    IFACE='eno1'  # set to server's inbound interface
    read -d "\n" PHIPV4 PHIPV6 <<<$(ip a show $IFACE | grep inet | awk '{ print $2 }' | sed -e 's/\/.*//')
    echo -e "$PHIPV4\n$PHIPV6"  # verify correct IPs
    cd helm/charts/pihole
    curl https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt > files/whitelist.txt
    curl https://v.firebog.net/hosts/lists.php?type=nocross > files/adlists.list
    shelm install . --namespace=pihole \
       --set host.ipv4=$PHIPV4 \
       # --set host.ipv6=$PHIPV6  # don't set if link-local address

## Gotchas

  - I had to change the forwarding policy (`iptables -P FORWARD ACCEPT`), per
  [this bug](https://github.com/ubuntu/microk8s/issues/75).
