#!/bin/bash
echo "LOG From - "`date`
sed -i 's/first-found/interface=ens*/g' /archeplay/package/microk8s/upgrade-scripts/000-switch-to-calico/resources/calico.yaml
echo "changed calico"
sed -i 's/hostPort: 443/hostPort: 9443/g' /archeplay/package/microk8s/actions/ingress.yaml
echo "chaged ingress host port 443"
sed -i 's/hostPort: 80/hostPort: 9000/g' /archeplay/package/microk8s/actions/ingress.yaml
echo "chaged ingress host port 80"
machineip=`curl -s ifconfig.me`
echo $machineip
grep -v 'advertise-address' /archeplay/package/microk8s/default-args/kube-apiserver >  /archeplay/package/microk8s/default-args/kube-apiserver.new
mv  /archeplay/package/microk8s/default-args/kube-apiserver.new /archeplay/package/microk8s/default-args/kube-apiserver
echo "--advertise-address=$machineip" >> /archeplay/package/microk8s/default-args/kube-apiserver
echo "updated kube-apiserver "
echo "microk8s start"
snap try /archeplay/package/microk8s --classic
echo "microk8s installation complete"
usermod -a -G microk8s ubuntu
snap start --enable microk8s
microk8s status --wait-ready
sleep 5
microk8s enable dns storage registry ingress
echo "microk8s enabling"
microk8s status --wait-ready
snap alias microk8s.kubectl kubectl
microk8s config > /home/ubuntu/.kube/config
chown -f -R ubuntu:ubuntu /home/ubuntu/.kube
microk8s status --wait-ready
sleep 10
echo "LOG till -  "`date`