- [Summary](#summary)
- [references:](#references)
- [Step 1  Install Docker on all CentOS 7 VMs:](#step-1--install-docker-on-all-centos-7-vms)
- [Step 2 Set up the Kubernetes Repository:](#step-2-set-up-the-kubernetes-repository)
- [Step 3 centos7 and master node1 node2  initialization:](#step-3-centos7-and-master-node1-node2--initialization)
- [Step 4 Install Kubelet kubeadm kubectl on CentOS 7:](#step-4-install-kubelet-kubeadm-kubectl-on-centos-7)
- [Step 5 deploying a k8s cluster:](#step-5-deploying-a-k8s-cluster)
- [Step 6 Checking the status of the kubelet pod ..:](#step-6-checking-the-status-of-the-kubelet-pod-)
- [Step 7 issue:](#step-7-issue)
- [Step 8 istioctl install :](#step-8-istioctl-install-)

# Summary
The documentation for centos7 install k8s and install istio
# references:
- https://www.hostafrica.co.za/blog/new-technologies/install-kubernetes-delpoy-cluster-centos-7/
- https://zhuanlan.zhihu.com/p/163107995 有关于和网络coredns 启动失败需要安装kube-flannel的参考
- https://istio.io/latest/zh/docs/setup/getting-started/#download
- https://github.com/istio/istio

# Step 1  Install Docker on all CentOS 7 VMs:
 Install Docker on all CentOS 7 VMs

 1. parepae centos7 install
 更新源信息 Update the package database
 2.  sudo yum check-update
 安装必要软件 
 3.  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
 写入docker源信息
 4.  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
 5.  sudo yum install docker-ce
 6.  systemctl start docker
 7.  systemctl enable docker
 8.  systemctl status docker

# Step 2 Set up the Kubernetes Repository:
- Set up the Kubernetes Repository
- Since the Kubernetes packages aren’t present in the official CentOS 7 repositories, we will need to add a new repository file. Use the following command to create the file and open it for editing:
```bash
添加k8s阿里云YUM软件源
sudo vi /etc/yum.repos.d/kubernetes.repo
 [kubernetes]
 name=kubernetes
 baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
 enabled=1
 gpgcheck=1
 repo_gpgcheck=0
 gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg 
need edit 是因为repo 的 gpg 验证不通过导致的，可以修改repo_gpgcheck=0跳过验证
```
- command
    - [root@master ~]# yum install -y yum-utils device-mapper-persistent-data lvm2
    - [root@master ~]# yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# Step 3 centos7 and master node1 node2  initialization:
```bash
    for centos7 and master node1 node2 
    disable selinx:
    sudo setenforce 0
    sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    disable firewall:
    [root@master-node yum.repos.d]# systemctl stop firewalld.service
    [root@master-node yum.repos.d]# systemctl disable firewalld.service
    Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
    Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
    update hostname:
    sudo hostnamectl set-hostname master-node || 对于node1  hostnamectl set-hostname node1 || 对于node2 hostnamectl set-hostname node2
    sudo exec bash
    update iptables config:
        We need to update the net.bridge.bridge-nf-call-iptables parameter in our sysctl file to ensure proper processing of packets across all machines. Use the following commands:
    cat <<EOF > /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOF
    sudo sysctl --system
    [root@master-node ~]# cat /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
    Disable swap:
        For Kubelet to work, we also need to disable swap on all of our VMs:
    sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a
[root@master-node ~]# sed -i '/swap/d' /etc/fstab
[root@master-node ~]# swapoff -a
[root@master-node ~]#
    Edit hosts:
        [root@master-node ~]# cat /etc/hosts
        127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
        ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
        10.211.55.8 master-node
        10.211.55.9 node1 W-node1
        10.211.55.10 node2 W-node2 
    docker daemon.json:
        [root@master-node ~]# cat /etc/docker/daemon.json
{
  "registry-mirrors" : [
  "https://registry.docker-cn.com",
  "https://docker.mirrors.ustc.edu.cn",
  "http://hub-mirror.c.163.com",
  "https://cr.console.aliyun.com/"],
  "live-restore":true,
  "exec-opts":["native.cgroupdriver=systemd"]
}
```
- 再启动看看
```bash
[root@master-node ~]# cat /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd
[root@master-node ~]# systemctl start kubelet
# systemctl status kubelet
● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; vendor preset: disabled)
  Drop-In: /usr/lib/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: active (running) since Wed 2022-11-02 17:19:28 CST; 2min 23s ago
     Docs: https://kubernetes.io/docs/
 Main PID: 1636 (kubelet)
    Tasks: 15
   Memory: 115.5M
   CGroup: /system.slice/kubelet.service
           └─1636 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootst...
        kubeadm reset:
        node1 and node2 也许需要这个操作才能加入
```
# Step 4 Install Kubelet kubeadm kubectl on CentOS 7:
```bash
    Install Kubelet kubeadm kubectl on CentOS 7
    The first core module that we need to install on every node is Kubelet. Use the following command to do so:
        x sudo yum install -y kubelet
        + 需要注意我这里指定了特殊的版本:
        + yum install -y --nogpgcheck kubelet-1.23.5 kubeadm-1.23.5 kubectl-1.23.5
        k8s在1.24版本不支持docker容器 reference:
        https://cloud.tencent.com/developer/article/2093107
        在新版本Kubernetes环境（1.24以及以上版本）下官方不在支持docker作为容器运行时了，若要继续使用docker 需要对docker进行配置一番。需要安装cri-docker作为Kubernetes容器
        所有节点安装kubeadm，kubelet和kubectl,版本更新频繁，这里指定版本号部署. [实际测试中发现其实版本是有影响的,所以我后来重新使用过这个版本]
        x [ERROR CRI]: container runtime is not running: output: E1102 16:22:55.771144   13525 remote_runtime.go:948] 
        x "Status from runtime service failed" err="rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService"
    Verify the command:
        kubelet --version
        kubectl version
        kubeadm version
```
# Step 5 deploying a k8s cluster:
```bash
    This concludes our installation and configuration of Kubernetes on CentOS 7. We will now share the steps for deploying a k8s cluster
    Deploying a Kubernetes Cluster on CentOS 7
    ☐ 1 kubeadm init --pod-network-cidr 10.244.0.0/16
    ☐ 1 kubeadm init --pod-network-cidr 10.244.0.0/16 --image-repository registry.aliyuncs.com/google_containers
        命令说明:
            x 如果不指定--pod-network-cidr 10.244.0.0/16后面的kube-flannel会有问题找不到 Error registering network: failed to acquire lease: node "master-node" pod cidr not assigned
            # kubeadm init --help|grep pod
            --pod-network-cidr string              Specify range of IP addresses for the pod network. If set, the control plane will automatically allocate CIDRs for every node 
             初始化过程说明：
            [preflight] kubeadm 执行初始化前的检查。
            [kubelet-start] 生成kubelet的配置文件”/var/lib/kubelet/config.yaml”
            [certificates] 生成相关的各种token和证书
            [kubeconfig] 生成 KubeConfig 文件，kubelet 需要这个文件与 Master 通信
            [control-plane] 安装 Master 组件，会从指定的 Registry 下载组件的 Docker 镜像。
            [bootstraptoken] 生成token记录下来，后边使用kubeadm join往集群中添加节点时会用到
            [addons] 安装附加组件 kube-proxy 和 kube-dns。 Kubernetes Master 初始化成功，提示如何配置常规用户使用kubectl访问集群。 提示如何安装 Pod 网络。 提示如何注册其他节点到 Cluster。
        checking systemctl enable kubelet.service:
            1 systemctl enable kubelet.service
            2 systemctl start kubelet.service
            3 systemctl status kubelet
        kubeadm reset:
            如果遇到一些错误,这个命令会重新设置
        kubeadm init:
            这个过程会去调用需要拉取的镜像,由于默认拉取镜像地址http://k8s.gcr.io国内无法访问，这里指定阿里云镜像仓库地址
            kubeadm init --pod-network-cidr 10.244.0.0/16 --image-repository registry.aliyuncs.com/google_containers
            其他解决参考:
                    查看需要的镜像列表
                    # kubeadm config images list
                    I1102 16:43:55.557868   18580 version.go:255] remote version is much newer: v1.25.3; falling back to: stable-1.23
                    k8s.gcr.io/kube-apiserver:v1.23.13
                    k8s.gcr.io/kube-controller-manager:v1.23.13
                    k8s.gcr.io/kube-scheduler:v1.23.13
                    k8s.gcr.io/kube-proxy:v1.23.13
                    k8s.gcr.io/pause:3.6
                    k8s.gcr.io/etcd:3.5.1-0
                    k8s.gcr.io/coredns/coredns:v1.8.6
                    从国内下载
                    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.23.13
                    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.23.13
                    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.23.13
                    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.23.13
                    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6
                    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.5.1-0
                    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns/coredns:v1.8.6
                    最后这个有点问题
                    # docker pull coredns/coredns:1.8.6
                    1.8.6: Pulling from coredns/coredns
                    d92bdee79785: Pull complete
                    6e1b7c06e42d: Pull complete
                    Digest: sha256:5b6ec0d6de9baaf3e92d0f66cd96a25b9edbce8716f5f15dcd1a616b3abd590e
                    Status: Downloaded newer image for coredns/coredns:1.8.6
                    docker.io/coredns/coredns:1.8.6
                    对images重命名
                    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.23.13	k8s.gcr.io/kube-apiserver:v1.23.13
                    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.23.13	k8s.gcr.io/kube-controller-manager:v1.23.13
                    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.23.13	k8s.gcr.io/kube-scheduler:v1.23.13
                    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.23.13	k8s.gcr.io/kube-proxy:v1.23.13
                    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6	k8s.gcr.io/pause:3.6
                    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.5.1-0	k8s.gcr.io/etcd:3.5.1-0
                    docker tag coredns/coredns:1.8.6 k8s.gcr.io/coredns/coredns:v1.8.6 
    ☐ 2 kubeadmin init after output reference
    Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.211.55.8:6443 --token qe1qbs.5hwtoxptauhnplkt \
	--discovery-token-ca-cert-hash sha256:d1f1c1c6ef1df24c8b671c2e625c180bf3cded8550724485fda0f0d1046e3d7e
    ☐ 3 初始化之后的一些配置和说明
    [root@master-node ~]# mkdir -p $HOME/.kube
    [root@master-node ~]# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    cp: overwrite '/root/.kube/config'? y
    [root@master-node ~]# sudo chown $(id -u):$(id -g) $HOME/.kube/config
    [root@master-node ~]# export KUBECONFIG=/etc/kubernetes/admin.conf
    [root@master-node ~]# kubectl get node
    NAME          STATUS     ROLES                  AGE   VERSION
    master-node   NotReady   control-plane,master   63s   v1.23.5
    node1         NotReady   <none>                 16s   v1.23.5
    node2         NotReady   <none>                 11s   v1.23.5
        命令说明:
            加入Kubernetes Node:
                如果执行kubeadm init时没有记录下加入集群的命令，可以通过以下命令重新创建
            [root@master-node ~]# kubeadm token create --print-join-command

            查看集群状态：确认各个组件都处于healthy状态:
[root@master-node ~]# kubectl get cs
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
scheduler            Healthy   ok
etcd-0               Healthy   {"health":"true","reason":""}
controller-manager   Healthy   ok

[root@master-node ~]# kubectl get componentstatus
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health":"true","reason":""}
    ☐ need node1 and node 2 join
    [root@node1 ~]# kubeadm join 10.211.55.8:6443 --token qe1qbs.5hwtoxptauhnplkt \
> --discovery-token-ca-cert-hash sha256:d1f1c1c6ef1df24c8b671c2e625c180bf3cded8550724485fda0f0d1046e3d7e
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.


[root@node2 ~]# kubeadm join 10.211.55.8:6443 --token qe1qbs.5hwtoxptauhnplkt \
> --discovery-token-ca-cert-hash sha256:d1f1c1c6ef1df24c8b671c2e625c180bf3cded8550724485fda0f0d1046e3d7e
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
```


# Step 6 Checking the status of the kubelet pod ..:
```bash
    到这了基本的操作已经完成
    检查节点上各个系统 Pod 的状态:
        # kubectl get pod -n kube-system -o wide
        NAME                                  READY   STATUS              RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
        coredns-64897985d-5ksmj               0/1     Pending             0          37m   <none>         <none>        <none>           <none>
        coredns-64897985d-lj6zv               0/1     Pending             0          37m   <none>         <none>        <none>           <none>
        etcd-master-node                      1/1     Running             1          37m   10.211.55.8    master-node   <none>           <none>
        kube-apiserver-master-node            1/1     Running             1          37m   10.211.55.8    master-node   <none>           <none>
        kube-controller-manager-master-node   1/1     Running             1          37m   10.211.55.8    master-node   <none>           <none>
        kube-proxy-4wdf6                      1/1     Running             0          37m   10.211.55.8    master-node   <none>           <none>
        kube-proxy-mbg4n                      0/1     ContainerCreating   0          36m   10.211.55.10   node2         <none>           <none> 
        kube-proxy-rvz76                      0/1     ContainerCreating   0          36m   10.211.55.9    node1         <none>           <none>
        kube-scheduler-master-node            1/1     Running             1          37m   10.211.55.8    master-node   <none>           <none>
        说明可以看到node1 node2 资源创建有问题可以手动去docker pull aliyun 镜像或者参考上面step 5 其他解决参考 为node1 and node2
        部署完成后，我们可以通过 kubectl get 重新检查 Pod 的状态:
            [root@master-node ~]# kubectl get pod --all-namespaces -o wide
            NAMESPACE      NAME                                  READY   STATUS              RESTARTS      AGE     IP             NODE          NOMINATED NODE   READINESS GATES
            kube-flannel   kube-flannel-ds-78wfp                 0/1     CrashLoopBackOff    2 (23s ago)   43s     10.211.55.10   node2         <none>           <none>
            kube-flannel   kube-flannel-ds-g9hpf                 0/1     CrashLoopBackOff    2 (22s ago)   43s     10.211.55.8    master-node   <none>           <none>
            kube-flannel   kube-flannel-ds-rh7wh                 0/1     CrashLoopBackOff    2 (21s ago)   43s     10.211.55.9    node1         <none>           <none>
            kube-system    coredns-64897985d-4zgpp               0/1     ContainerCreating   0             4m25s   <none>         node1         <none>           <none>
            kube-system    coredns-64897985d-fk4q4               0/1     ContainerCreating   0             4m25s   <none>         node1         <none>           <none>
            kube-system    etcd-master-node                      1/1     Running             2             4m31s   10.211.55.8    master-node   <none>           <none>
            kube-system    kube-apiserver-master-node            1/1     Running             2             4m31s   10.211.55.8    master-node   <none>           <none>
            kube-system    kube-controller-manager-master-node   1/1     Running             2             4m31s   10.211.55.8    master-node   <none>           <none>
            kube-system    kube-proxy-52pv8                      1/1     Running             0             4m26s   10.211.55.8    master-node   <none>           <none>
            kube-system    kube-proxy-8s6xm                      1/1     Running             0             3m32s   10.211.55.10   node2         <none>           <none>
            kube-system    kube-proxy-zrfhc                      1/1     Running             0             3m37s   10.211.55.9    node1         <none>           <none>
            kube-system    kube-scheduler-master-node            1/1     Running             2             4m31s   10.211.55.8    master-node   <none>           <none>
```
# Step 7 issue:
```bash
    coredns Pending:
        要让 Kubernetes Cluster 能够工作，必须安装 Pod 网络，否则 Pod 之间无法通信。 Kubernetes 支持多种网络方案，这里我们使用 flannel 执行如下命令部署 flannel：
    安coredns装Pod网络插件（CNI）- master节点，node节点加入后自动下载
    可以看到，CoreDNS依赖于网络的 Pod 都处于 Pending 状态，即调度失败。这当然是符合预期的：因为这个 Master 节点的网络尚未就绪。 集群初始化如果遇到问题，可以使用kubeadm reset命令进行清理然后重新执行初始化。
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    
    namespace/kube-flannel created
    clusterrole.rbac.authorization.k8s.io/flannel created
    clusterrolebinding.rbac.authorization.k8s.io/flannel created
    serviceaccount/flannel created
    configmap/kube-flannel-cfg created
    daemonset.apps/kube-flannel-ds created
    
    [root@master-node ~]# cat kube-flannel.yml|grep image
           #image: flannelcni/flannel-cni-plugin:v1.1.0 for ppc64le and mips64le (dockerhub limitations may apply)
            image: docker.io/rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0
           #image: flannelcni/flannel:v0.20.0 for ppc64le and mips64le (dockerhub limitations may apply)
            image: docker.io/rancher/mirrored-flannelcni-flannel:v0.20.0
           #image: flannelcni/flannel:v0.20.0 for ppc64le and mips64le (dockerhub limitations may apply)
            image: docker.io/rancher/mirrored-flannelcni-flannel:v0.20.
    
    [root@master-node ~]# docker pull docker.io/rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0
    [root@master-node ~]# docker pull docker.io/rancher/mirrored-flannelcni-flannel:v0.20.0
    Checking pod logs:
        # kubectl logs kube-flannel-ds-rh7wh -n kube-flannel
    Checking kube-controller-manager.yaml.:
        /etc/kubernetes/manifests/kube-controller-manager.yaml 
        kube-flannel.yml 
    ip link:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 00:1c:42:b6:63:7b brd ff:ff:ff:ff:ff:ff
3: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:72:ee:db brd ff:ff:ff:ff:ff:ff
4: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast master virbr0 state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:72:ee:db brd ff:ff:ff:ff:ff:ff
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:dc:08:ca:04 brd ff:ff:ff:ff:ff:ff
6: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/ether 12:b3:b0:58:60:5a brd ff:ff:ff:ff:ff:ff
7: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether e2:f8:95:89:0b:49 brd ff:ff:ff:ff:ff:ff
8: veth42094fc8@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master cni0 state UP mode DEFAULT group default
    link/ether 36:4a:75:a2:cd:d5 brd ff:ff:ff:ff:ff:ff link-netnsid 0
9: veth5edfc32a@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master cni0 state UP mode DEFAULT group default
    link/ether 8e:76:6a:de:5f:27 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    Checking pod status again:
        [root@master-node ~]# kubectl get pod --all-namespaces -o wide
NAMESPACE      NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
kube-flannel   kube-flannel-ds-gx4xl                 1/1     Running   0          29s     10.211.55.10   node2         <none>           <none>
kube-flannel   kube-flannel-ds-s6n6l                 1/1     Running   0          29s     10.211.55.8    master-node   <none>           <none>
kube-flannel   kube-flannel-ds-tgh5q                 1/1     Running   0          29s     10.211.55.9    node1         <none>           <none>
kube-system    coredns-64897985d-d5zv4               1/1     Running   0          2m29s   10.244.0.2     master-node   <none>           <none>
kube-system    coredns-64897985d-d94bh               1/1     Running   0          2m29s   10.244.0.3     master-node   <none>           <none>
kube-system    etcd-master-node                      1/1     Running   4          2m42s   10.211.55.8    master-node   <none>           <none>
kube-system    kube-apiserver-master-node            1/1     Running   4          2m44s   10.211.55.8    master-node   <none>           <none>
kube-system    kube-controller-manager-master-node   1/1     Running   0          2m42s   10.211.55.8    master-node   <none>           <none>
kube-system    kube-proxy-59dqs                      1/1     Running   0          2m18s   10.211.55.10   node2         <none>           <none>
kube-system    kube-proxy-cjdc6                      1/1     Running   0          2m21s   10.211.55.9    node1         <none>           <none>
kube-system    kube-proxy-dtxft                      1/1     Running   0          2m29s   10.211.55.8    master-node   <none>           <none>
kube-system    kube-scheduler-master-node            1/1     Running   4          2m42s   10.211.55.8    master-node   <none>           <none>
    checking kube-flannel:
        [root@master-node ~]# kubectl get pod -n kube-flannel
NAME                    READY   STATUS    RESTARTS   AGE
kube-flannel-ds-gx4xl   1/1     Running   0          13h
kube-flannel-ds-s6n6l   1/1     Running   0          13h
kube-flannel-ds-tgh5q   1/1     Running   0          13h
```
# Step 8 istioctl install :
```bash
    istioctl install 
    reference:
        https://istio.io/latest/zh/docs/setup/getting-started/#download
    

        [root@master-node ~]# ls
        anaconda-ks.cfg  istioctl-1.15.3-linux-amd64.tar.gz  original-ks.cfg
        [root@master-node ~]# tar -zxvf istioctl-1.15.3-linux-amd64.tar.gz
        istioctl
        [root@master-node ~]# ls
        anaconda-ks.cfg  istioctl  istioctl-1.15.3-linux-amd64.tar.gz  original-ks.cfg
        [root@master-node ~]# kube get svc
        bash: kube: command not found...
        [root@master-node ~]# kubectl get svc
        NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
        kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   14m
        [root@master-node ~]# ./istioctl version
        no running Istio pods in "istio-system"
        1.15.3
        [root@master-node ~]# ./istioctl version
        no running Istio pods in "istio-system"
        1.15.3
        对于本次安装，我们采用 demo 配置组合。 选择它是因为它包含了一组专为测试准备的功能集合，另外还有用于生产或性能测试的配置组合。
        [root@master-node ~]# ./istioctl install --set profile=demo
        This will install the Istio 1.15.3 demo profile with ["Istio core" "Istiod" "Ingress gateways" "Egress gateways"] components into the cluster. Proceed? (y/N) y
        ✔ Istio core installed
        ✔ Istiod installed
        ✔ Ingress gateways installed
        ✔ Egress gateways installed
        ✔ Installation complete                                                                                                                                                  Making this installation the default for injection and validation.
        
        Thank you for installing Istio 1.15.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/SWHFBmwJspusK1hv6
        
        [root@master-node ~]# kubectl get pod --all-namespaces -o wide
        NAMESPACE      NAME                                    READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
        istio-system   istio-egressgateway-6df4fcb499-p2p9k    1/1     Running   0          114s    10.244.2.4     node2         <none>           <none>
        istio-system   istio-ingressgateway-57bcb89bf9-hfgnk   1/1     Running   0          114s    10.244.2.3     node2         <none>           <none>
        istio-system   istiod-75b7f5bbf6-pjp8h                 1/1     Running   0          2m24s   10.244.2.2     node2         <none>           <none>
        kube-flannel   kube-flannel-ds-gx4xl                   1/1     Running   0          4m48s   10.211.55.10   node2         <none>           <none>
        kube-flannel   kube-flannel-ds-s6n6l                   1/1     Running   0          4m48s   10.211.55.8    master-node   <none>           <none>
        kube-flannel   kube-flannel-ds-tgh5q                   1/1     Running   0          4m48s   10.211.55.9    node1         <none>           <none>
        kube-system    coredns-64897985d-d5zv4                 1/1     Running   0          6m48s   10.244.0.2     master-node   <none>           <none>
        kube-system    coredns-64897985d-d94bh                 1/1     Running   0          6m48s   10.244.0.3     master-node   <none>           <none>
        kube-system    etcd-master-node                        1/1     Running   4          7m1s    10.211.55.8    master-node   <none>           <none>
        kube-system    kube-apiserver-master-node              1/1     Running   4          7m3s    10.211.55.8    master-node   <none>           <none>
        kube-system    kube-controller-manager-master-node     1/1     Running   0          7m1s    10.211.55.8    master-node   <none>           <none>
        kube-system    kube-proxy-59dqs                        1/1     Running   0          6m37s   10.211.55.10   node2         <none>           <none>
        kube-system    kube-proxy-cjdc6                        1/1     Running   0          6m40s   10.211.55.9    node1         <none>           <none>
        kube-system    kube-proxy-dtxft                        1/1     Running   0          6m48s   10.211.55.8    master-node   <none>           <none>
        kube-system    kube-scheduler-master-node              1/1     Running   4          7m1s    10.211.55.8    master-node   <none>           <none>
        
        
        https://istio.io/latest/zh/docs/setup/getting-started/#download
        https://istio.io/latest/zh/docs/setup/getting-started/
        给命名空间添加标签，指示 Istio 在部署应用的时候，自动注入 Envoy 边车代理：
        $ kubectl label namespace default istio-injection=enabled
        namespace/default labeled
        wget https://raw.githubusercontent.com/istio/istio/release-1.15/samples/bookinfo/platform/kube/bookinfo.yaml
        部署 Bookinfo 示例应用:
        [root@master-node ~]# kubectl apply -f bookinfo.yaml
        service/details created
        serviceaccount/bookinfo-details created
        deployment.apps/details-v1 created
        service/ratings created
        serviceaccount/bookinfo-ratings created
        deployment.apps/ratings-v1 created
        service/reviews created
        serviceaccount/bookinfo-reviews created
        deployment.apps/reviews-v1 created
        deployment.apps/reviews-v2 created
        deployment.apps/reviews-v3 created
        service/productpage created
        serviceaccount/bookinfo-productpage created
        deployment.apps/productpage-v1 created
        应用很快会启动起来。当每个 Pod 准备就绪时，Istio 边车代理将伴随它们一起部署:
        [root@master-node ~]# kubectl get services
        NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
        details       ClusterIP   10.98.163.198    <none>        9080/TCP   32s
        kubernetes    ClusterIP   10.96.0.1        <none>        443/TCP    13m
        productpage   ClusterIP   10.102.204.13    <none>        9080/TCP   31s
        ratings       ClusterIP   10.110.203.228   <none>        9080/TCP   31s
        reviews       ClusterIP   10.109.166.169   <none>        9080/TCP   31s
        [root@master-node ~]# kubectl get pod
        NAME                             READY   STATUS            RESTARTS   AGE
        details-v1-698b5d8c98-mcglc      0/2     PodInitializing   0          41s
        productpage-v1-bf4b489d8-6b6rs   0/2     Init:0/1          0          41s
        ratings-v1-5967f59c58-vh8xv      2/2     Running           0          41s
        reviews-v1-9c6bb6658-xbbfl       0/2     PodInitializing   0          41s
        reviews-v2-8454bb78d8-2rcgt      0/2     PodInitializing   0          41s
        reviews-v3-6dc9897554-gsv6w      0/2     PodInitializing   0          41s
        
        waiting until the pod is running:
        [root@master-node ~]# kubectl get pod
        NAME                             READY   STATUS    RESTARTS   AGE
        details-v1-698b5d8c98-mcglc      2/2     Running   0          3m9s
        productpage-v1-bf4b489d8-6b6rs   2/2     Running   0          3m9s
        ratings-v1-5967f59c58-vh8xv      2/2     Running   0          3m9s
        reviews-v1-9c6bb6658-xbbfl       2/2     Running   0          3m9s
        reviews-v2-8454bb78d8-2rcgt      2/2     Running   0          3m9s
        reviews-v3-6dc9897554-gsv6w      2/2     Running   0          3m9s
        
        确认上面的操作都正确之后，运行下面命令，通过检查返回的页面标题，来验证应用是否已在集群中运行，并已提供网页服务
        kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -s productpage:9080/productpage | grep -o "<title>.*</title>"
        <title>Simple Bookstore App</title>
        
        对外开放应用程序
        
        此时，BookInfo 应用已经部署，但还不能被外界访问。 要开放访问，您需要创建 Istio 入站网关（Ingress Gateway）, 它会在网格边缘把一个路径映射到路由。
        
        把应用关联到 Istio 网关：
        https://raw.githubusercontent.com/istio/istio/release-1.15/samples/bookinfo/networking/bookinfo-gateway.yaml
        
        [root@master-node ~]# kubectl apply -f bookinfo-gateway.yaml
        gateway.networking.istio.io/bookinfo-gateway created
        virtualservice.networking.istio.io/bookinfo created
        确保配置文件没有问题：
        [root@master-node ~]# ./istioctl analyze
        
        ✔ No validation issues found when analyzing namespace: default.
        
        
        + 确定入站 IP 和端口
        
        按照说明，为访问网关设置两个变量：INGRESS_HOST 和 INGRESS_PORT。 使用标签页，切换到您选用平台的说明：
        执行下面命令以判断您的 Kubernetes 集群环境是否支持外部负载均衡：
        
        [root@master-node addons]# kubectl get svc istio-ingressgateway -n istio-system
        NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                      AGE
        istio-ingressgateway   LoadBalancer   10.105.71.125   <pending>     15021:31042/TCP,80:32464/TCP,443:30555/TCP,31400:31864/TCP,15443:32381/TCP   12h
        设置 EXTERNAL-IP 的值之后， 您的环境就有了一个外部的负载均衡，可以用它做入站网关。 但如果 EXTERNAL-IP 的值为 <none> (或者一直是 <pending> 状态)， 
        则您的环境则没有提供可作为入站流量网关的外部负载均衡。 在这个情况下，您还可以用服务（Service）的节点端口访问网关。
        
        按照下面说明：如果您的环境中没有外部负载均衡，那就选择一个节点端口来代替
        reference:
            https://kubernetes.io/zh-cn/docs/concepts/services-networking/service/#type-nodeport
        eg:
            apiVersion: v1
            kind: Service
            metadata:
              name: my-service
            spec:
              type: NodePort
              selector:
                app.kubernetes.io/name: MyApp
              ports:
                  # 默认情况下，为了方便起见，`targetPort` 被设置为与 `port` 字段相同的值。
                - port: 80
                  targetPort: 80
                  # 可选字段
                  # 默认情况下，为了方便起见，Kubernetes 控制平面会从某个范围内分配一个端口号（默认：30000-32767）
                  nodePort: 30007
        设置入站的端口：
        
        # kubectl get svc -n istio-system
        NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                      AGE
        istio-egressgateway    ClusterIP      10.102.44.107    <none>        80/TCP,443/TCP                                                               12h
        istio-ingressgateway   LoadBalancer   10.105.71.125    <pending>     15021:31042/TCP,80:32464/TCP,443:30555/TCP,31400:31864/TCP,15443:32381/TCP   12h
        istiod                 ClusterIP      10.98.188.17     <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP                                        12h
        kiali                  ClusterIP      10.102.130.158   <none>        20001/TCP,9090/TCP
        
        verfify:
            the port
            [root@master-node ~]# kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}'
            32464
            [root@master-node ~]# kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}'
            30555
        
        setting export:
        export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
        export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
        
        [root@master-node ~]# export|grep PORT
        declare -x INGRESS_PORT="32464"
        declare -x SECURE_INGRESS_PORT="30555"
        Other environments:
            # kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}'
        10.211.55.10
        export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
        
        [root@master-node ~]# export|egrep "PORT|HOST"
        declare -x HOSTNAME="master-node"
        declare -x INGRESS_HOST="10.211.55.10"
        declare -x INGRESS_PORT="32464"
        declare -x SECURE_INGRESS_PORT="30555"
        
        设置环境变量 GATEWAY_URL:
            [root@master-node ~]# export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
        确保 IP 地址和端口均成功的赋值给了环境变量:
            [root@master-node ~]# echo "$GATEWAY_URL"
        10.211.55.10:32464
        [root@master-node ~]# kubectl get pod
        NAME                             READY   STATUS    RESTARTS   AGE
        details-v1-698b5d8c98-mcglc      2/2     Running   0          12h
        productpage-v1-bf4b489d8-6b6rs   2/2     Running   0          12h
        ratings-v1-5967f59c58-vh8xv      2/2     Running   0          12h
        reviews-v1-9c6bb6658-xbbfl       2/2     Running   0          12h
        reviews-v2-8454bb78d8-2rcgt      2/2     Running   0          12h
        reviews-v3-6dc9897554-gsv6w      2/2     Running   0          12h
        
        
        验证外部访问
        
        用浏览器查看 Bookinfo 应用的产品页面，验证 Bookinfo 已经实现了外部访问。
        
        运行下面命令，获取 Bookinfo 应用的外部访问地址。
        [root@master-node ~]# echo "http://$GATEWAY_URL/productpage"
        http://10.211.55.10:32464/productpage
        
        把上面命令的输出地址复制粘贴到浏览器并访问，确认 Bookinfo 应用的产品页面是否可以打开:
        ➜  ~ curl -I http://10.211.55.10:32464/productpage
        HTTP/1.1 200 OK
        content-type: text/html; charset=utf-8
        content-length: 4293
        server: istio-envoy
        date: Thu, 03 Nov 2022 01:07:15 GMT
        x-envoy-upstream-service-time: 56
        
        
        Verify pod logs:
            [root@master-node ~]# kubectl logs -f productpage-v1-bf4b489d8-6b6rs
            reply: 'HTTP/1.1 200 OK\r\n'
            header: x-powered-by: Servlet/3.1
            header: content-type: application/json
            header: date: Thu, 03 Nov 2022 01:07:15 GMT
            header: content-language: en-US
            header: content-length: 357
            header: x-envoy-upstream-service-time: 26
            header: server: envoy
            DEBUG:urllib3.connectionpool:http://reviews:9080 "GET /reviews/0 HTTP/1.1" 200 357
            INFO:werkzeug:::ffff:127.0.0.6 - - [03/Nov/2022 01:07:15] "HEAD /productpage HTTP/1.1" 200 -
        
        查看仪表板:
        
            Istio 和几个遥测应用做了集成。 遥测能帮您了解服务网格的结构、展示网络的拓扑结构、分析网格的健康状态。
            
            使用下面说明部署 Kiali 仪表板、 以及 Prometheus、 Grafana、 还有 Jaeger
            
        
            安装 Kiali 和其他插件，等待部署完成
            [root@master-node addons]# pwd
            /root/istio-1.15.3/samples/addons
            [root@master-node addons]# tree
            .
            |-- extras
            |   |-- prometheus-operator.yaml
            |   |-- prometheus_vm_tls.yaml
            |   |-- prometheus_vm.yaml
            |   `-- zipkin.yaml
            |-- grafana.yaml
            |-- jaeger.yaml
            |-- kiali.yaml
            |-- prometheus.yaml
            `-- README.md
            
            1 directory, 9 files
            [root@master-node addons]# kubectl apply -f /root/istio-1.15.3/samples/addons
            serviceaccount/grafana created
            configmap/grafana created
            service/grafana created
            deployment.apps/grafana created
            configmap/istio-grafana-dashboards created
            configmap/istio-services-grafana-dashboards created
            deployment.apps/jaeger created
            service/tracing created
            service/zipkin created
            service/jaeger-collector created
            serviceaccount/kiali unchanged
            configmap/kiali unchanged
            clusterrole.rbac.authorization.k8s.io/kiali-viewer unchanged
            clusterrole.rbac.authorization.k8s.io/kiali unchanged
            clusterrolebinding.rbac.authorization.k8s.io/kiali unchanged
            role.rbac.authorization.k8s.io/kiali-controlplane unchanged
            rolebinding.rbac.authorization.k8s.io/kiali-controlplane unchanged
            service/kiali unchanged
            deployment.apps/kiali unchanged
            serviceaccount/prometheus created
            configmap/prometheus created
            clusterrole.rbac.authorization.k8s.io/prometheus created
            clusterrolebinding.rbac.authorization.k8s.io/prometheus created
            service/prometheus created
            deployment.apps/prometheus created
            [root@master-node addons]# kubectl get deploy -n istio-system
            NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
            grafana                0/1     1            0           33s
            istio-egressgateway    1/1     1            1           12h
            istio-ingressgateway   1/1     1            1           12h
            istiod                 1/1     1            1           12h
            jaeger                 0/1     1            0           33s
            kiali                  1/1     1            1           12h
            prometheus             0/1     1            0           32s
            [root@master-node addons]# kubectl rollout status deployment/kiali -n istio-system
            deployment "kiali" successfully rolled out
            [root@master-node addons]# kubectl get deploy -n istio-system
            NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
            grafana                0/1     1            0           49s
            istio-egressgateway    1/1     1            1           12h
            istio-ingressgateway   1/1     1            1           12h
            istiod                 1/1     1            1           12h
            jaeger                 0/1     1            0           49s
            kiali                  1/1     1            1           12h
            prometheus             0/1     1            0           48s
        
        
        verify deployment:
            [root@master-node addons]# kubectl get deploy -n istio-system
        NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
        grafana                1/1     1            1           5m23s
        istio-egressgateway    1/1     1            1           13h
        istio-ingressgateway   1/1     1            1           13h
        istiod                 1/1     1            1           13h
        jaeger                 1/1     1            1           5m23s
        kiali                  1/1     1            1           12h
        prometheus             1/1     1            1           5m22s
        
        访问 Kiali 仪表板。
        
        [root@master-node ~]# ./istioctl dashboard kiali --address 10.211.55.8
        http://10.211.55.8:20001/kiali
        
        [root@master-node ~]# ./istioctl dashboard kiali
        http://localhost:20001/kiali
        
        在左侧的导航菜单，选择 Graph ，然后在 Namespace 下拉列表中，选择 default 。
        Kiali 仪表板展示了网格的概览、以及 Bookinfo 示例应用的各个服务之间的关系。 它还提供过滤器来可视化流量的流动。
        
        add performance tests for url:
            ➜  ~ wrk -c 100 -d 300 http://10.211.55.10:32464/productpage
            Running 5m test @ http://10.211.55.10:32464/productpage
              2 threads and 100 connections
              Thread Stats   Avg      Stdev     Max   +/- Stdev
                Latency     1.19s   162.18ms   2.00s    78.86%
                Req/Sec    42.03     18.37   120.00     70.74%
              25065 requests in 5.00m, 122.40MB read
              Socket errors: connect 0, read 0, write 0, timeout 70
            Requests/sec:     83.53
            Transfer/sec:    417.69KB
        
        + install liali.yaml from tar.gz 
        [root@master-node addons]# pwd
        /root/istio-1.15.3/samples/addons
        [root@master-node addons]# kubectl apply -f kiali.yaml
        serviceaccount/kiali created
        configmap/kiali created
        clusterrole.rbac.authorization.k8s.io/kiali-viewer created
        clusterrole.rbac.authorization.k8s.io/kiali created
        clusterrolebinding.rbac.authorization.k8s.io/kiali created
        role.rbac.authorization.k8s.io/kiali-controlplane created
        rolebinding.rbac.authorization.k8s.io/kiali-controlplane created
        service/kiali created
        deployment.apps/kiali created
        
        waiting until deployment finished
        istio-system   kiali-689fbdb586-d6gxm                  0/1     Running   0          79s
        
        打开dashboard
        ➜  /root/istioctl dashboard kiali
        http://localhost:20001/kiali
        
        [root@master-node addons]# /root/istioctl dashboard kiali
        http://localhost:20001/kiali
        
        注入 Sidecar的时候会在生成pod的时候附加上两个容器：istio-init、istio-proxy。istio-init这个容器从名字上看也可以知道它属于k8s中的Init Containers，主要用于设置iptables规则，让出入流量都转由 Sidecar 进行处理。istio-proxy是基于Envoy实现的一个网络代理容器，是真正的Sidecar，应用的流量会被重定向进入或流出Sidecar。
        https://cloud.tencent.com/developer/article/1746921?from=15425
        我们在使用Sidecar自动注入的时候只需要给对应的应用部署的命名空间打个istio-injection=enabled标签，这个命名空间中新建的任何 Pod 都会被 Istio 注入 Sidecar。
        应用部署后我们可以通过kubectl describe查看pod内的容器
        # kubectl describe pod productpage-v1-bf4b489d8-6b6rs
        Name:         productpage-v1-bf4b489d8-6b6rs
        Namespace:    default
        Priority:     0
        Node:         node1/10.211.55.9
        Start Time:   Wed, 02 Nov 2022 20:38:30 +0800
        Labels:       app=productpage
                      pod-template-hash=bf4b489d8
                      security.istio.io/tlsMode=istio
                      service.istio.io/canonical-name=productpage
                      service.istio.io/canonical-revision=v1
                      version=v1
        Annotations:  kubectl.kubernetes.io/default-container: productpage
                      kubectl.kubernetes.io/default-logs-container: productpage
                      prometheus.io/path: /stats/prometheus
                      prometheus.io/port: 15020
                      prometheus.io/scrape: true
                      sidecar.istio.io/status:
                        {"initContainers":["istio-init"],"containers":["istio-proxy"],"volumes":["workload-socket","credential-socket","workload-certs","istio-env...
        Status:       Running
        IP:           10.244.1.3
        IPs:
          IP:           10.244.1.3
        Controlled By:  ReplicaSet/productpage-v1-bf4b489d8
        Init Containers:
          istio-init:
            Container ID:  docker://f58294a6556024c25364ce7fd9eca5655c81f30c76bf7f76ca786b5fb854bbd1
            Image:         docker.io/istio/proxyv2:1.15.3
            Image ID:      docker-pullable://istio/proxyv2@sha256:de42717d56b022c5f469a892cdff28ae045476c59ad818ca2732bac51d076b19
            Port:          <none>
            Host Port:     <none>
            Args:
              istio-iptables
              -p
              15001
              -z
              15006
              -u
              1337
              -m
              REDIRECT
              -i
              *
              -x
        
              -b
              *
              -d
              15090,15021,15020
              --log_output_level=default:info
            State:          Terminated
              Reason:       Completed
              Exit Code:    0
              Started:      Wed, 02 Nov 2022 20:39:19 +0800
              Finished:     Wed, 02 Nov 2022 20:39:19 +0800
            Ready:          True
            Restart Count:  0
            Limits:
              cpu:     2
              memory:  1Gi
            Requests:
              cpu:        10m
              memory:     40Mi
            Environment:  <none>
            Mounts:
              /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8lqq6 (ro)
        Containers:
          productpage:
            Container ID:   docker://293db163443b1ff53e2027bc360493c5733cb916b51f44b5dadf1789cb1d0df7
            Image:          docker.io/istio/examples-bookinfo-productpage-v1:1.17.0
            Image ID:       docker-pullable://istio/examples-bookinfo-productpage-v1@sha256:6668bcf42ef0afb89d0ccd378905c761eab0f06919e74e178852b58b4bbb29c5
            Port:           9080/TCP
            Host Port:      0/TCP
            State:          Running
              Started:      Wed, 02 Nov 2022 20:41:33 +0800
            Ready:          True
            Restart Count:  0
            Environment:    <none>
            Mounts:
              /tmp from tmp (rw)
              /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8lqq6 (ro)
          istio-proxy:
            Container ID:  docker://8c66ee03c6af7c972b2319219a73c24149c0bed9c28ac057307bc435b7668d56
            Image:         docker.io/istio/proxyv2:1.15.3
            Image ID:      docker-pullable://istio/proxyv2@sha256:de42717d56b022c5f469a892cdff28ae045476c59ad818ca2732bac51d076b19
            Port:          15090/TCP
            Host Port:     0/TCP
            Args:
              proxy
              sidecar
              --domain
              $(POD_NAMESPACE).svc.cluster.local
              --proxyLogLevel=warning
              --proxyComponentLogLevel=misc:error
              --log_output_level=default:info
              --concurrency
              2
            State:          Running
              Started:      Wed, 02 Nov 2022 20:41:33 +0800
            Ready:          True
            Restart Count:  0
            Limits:
              cpu:     2
              memory:  1Gi
            Requests:
              cpu:      10m
              memory:   40Mi
            Readiness:  http-get http://:15021/healthz/ready delay=1s timeout=3s period=2s #success=1 #failure=30
            Environment:
              JWT_POLICY:                    third-party-jwt
              PILOT_CERT_PROVIDER:           istiod
              CA_ADDR:                       istiod.istio-system.svc:15012
              POD_NAME:                      productpage-v1-bf4b489d8-6b6rs (v1:metadata.name)
              POD_NAMESPACE:                 default (v1:metadata.namespace)
              INSTANCE_IP:                    (v1:status.podIP)
              SERVICE_ACCOUNT:                (v1:spec.serviceAccountName)
              HOST_IP:                        (v1:status.hostIP)
              PROXY_CONFIG:                  {}
        
              ISTIO_META_POD_PORTS:          [
                                                 {"containerPort":9080,"protocol":"TCP"}
                                             ]
              ISTIO_META_APP_CONTAINERS:     productpage
              ISTIO_META_CLUSTER_ID:         Kubernetes
              ISTIO_META_INTERCEPTION_MODE:  REDIRECT
              ISTIO_META_WORKLOAD_NAME:      productpage-v1
              ISTIO_META_OWNER:              kubernetes://apis/apps/v1/namespaces/default/deployments/productpage-v1
              ISTIO_META_MESH_ID:            cluster.local
              TRUST_DOMAIN:                  cluster.local
            Mounts:
              /etc/istio/pod from istio-podinfo (rw)
              /etc/istio/proxy from istio-envoy (rw)
              /var/lib/istio/data from istio-data (rw)
              /var/run/secrets/credential-uds from credential-socket (rw)
              /var/run/secrets/istio from istiod-ca-cert (rw)
              /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-8lqq6 (ro)
              /var/run/secrets/tokens from istio-token (rw)
              /var/run/secrets/workload-spiffe-credentials from workload-certs (rw)
              /var/run/secrets/workload-spiffe-uds from workload-socket (rw)
        Conditions:
          Type              Status
          Initialized       True
          Ready             True
          ContainersReady   True
          PodScheduled      True
        Volumes:
          workload-socket:
            Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
            Medium:
            SizeLimit:  <unset>
          credential-socket:
            Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
            Medium:
            SizeLimit:  <unset>
          workload-certs:
            Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
            Medium:
            SizeLimit:  <unset>
          istio-envoy:
            Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
            Medium:     Memory
            SizeLimit:  <unset>
          istio-data:
            Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
            Medium:
            SizeLimit:  <unset>
          istio-podinfo:
            Type:  DownwardAPI (a volume populated by information about the pod)
            Items:
              metadata.labels -> labels
              metadata.annotations -> annotations
          istio-token:
            Type:                    Projected (a volume that contains injected data from multiple sources)
            TokenExpirationSeconds:  43200
          istiod-ca-cert:
            Type:      ConfigMap (a volume populated by a ConfigMap)
            Name:      istio-ca-root-cert
            Optional:  false
          tmp:
            Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
            Medium:
            SizeLimit:  <unset>
          kube-api-access-8lqq6:
            Type:                    Projected (a volume that contains injected data from multiple sources)
            TokenExpirationSeconds:  3607
            ConfigMapName:           kube-root-ca.crt
            ConfigMapOptional:       <nil>
            DownwardAPI:             true
        QoS Class:                   Burstable
        Node-Selectors:              <none>
        Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                                     node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
        Events:                      <none>
```                                      