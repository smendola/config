#!/bin/bash -ex

yum install -y iptables-services

systemctl stop firewalld
systemctl disable firewalld

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

service iptables save

