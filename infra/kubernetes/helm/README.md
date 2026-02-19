 helm upgrade challenge ./challenge  -n challenge-dev -f challenge/values-dev.yaml

 deployment will not  rollout if only image content change.



```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system --set args="{--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP}"
```



```


# hpa
averageUtilization: 30
is the percentage of request


# git  

rollbackable,auditable, access controllable

```
git log

git revert 8548af53a0696a5ce0ad548d94d9df2c1a7af467

git push
```
