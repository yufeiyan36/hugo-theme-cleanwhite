---
showonlyimage: true
title:      "Welcome Yufei Yan to the lab!"
subtitle:   ""
excerpt: "We are happy to welcome Yufei Yan to the lab as a Ph.D. student."
description: "We are happy to welcome Yufei Yan to the lab as a Ph.D. student. Yufei’s research interests focus on root exudate–mineral interactions and the destabilization of mineral-associated organic matter."
date:       2025-08-01
author: "Sustainable Soil Biogeochemistry Lab"
image: "/img/2018-06-04-introducing-the-istio-v1alpha3-routing-api/background.jpg"
publishDate: 2025-08-01
tags:
    - News

categories: [ news ]
URL: "/2025/08/01/welcome-yufei-yan/"
---
We are happy to welcome Yufei Yan to the lab as a Ph.D. student. Yufei’s research interests focus on root exudate–mineral interactions and the destabilization of mineral-associated organic matter.

Posted by Sustainable Soil Biogeochemistry Lab, Aug 2025.

1. 每个服务版本都有一个名称（称为服务子集）。 属于某个子集的一组Pod/VM在`DestinationRule`定义，具体定义参见下节。

1. 通过使用带通配符前缀的DNS来指定`VirtualService`的host，可以创建单个规则以作用于所有匹配的服务。 例如，在Kubernetes中，在'VirtualService'中使用*.foo.svc.cluster.local作为host,可以对`foo`命名空间中的所有服务应用相同的重写规则。

### DestinationRule

[DestinationRule](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#DestinationRule)配置将流量转发到服务时应用的策略集。 这些策略应由由服务提供者撰写，用于描述断路器，负载均衡设置，TLS设置等。
除了下述改变外，`DestinationRule`与其前身`DestinationPolicy`大致相同。

1. [DestinationRule](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#DestinationRule)的`host`可以包含通配符前缀，以允许单个规则应用于多个服务。
1. `DestinationRule`定义了目的host的子集`subsets` （例如：命名版本）。 这些subset用于｀VirtualService｀的路由规则设置中，可以将流量导向服务的某些特定版本。 通过这种方式为版本命名后，可以在不同的virtual service中明确地引用这些命名版本的ubset，简化Istio代理发出的统计数据，并可以将subsets编码到SNI头中。
为reviews服务配置策略和subsets的`DestinationRule`可能如下所示：

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
  subsets:
  - name: v1
  name: foo-ext
spec:
  hosts:
  - foo.com
  ports:
  - number: 80
    name: http
    protocol: HTTP
```
也就是说，`ServiceEntry`比它的前身具有更多的功能。首先，`ServiceEntry`不限于外部服务配置，它可以有两种类型：网格内部或网格外部。网格内部条目只是用于向网格显式添加服务，添加的服务与其他内部服务一样。采用网格内部条目，可以把原本未被网格管理的基础设施也纳入到网格中（例如，把虚机中的服务添加到基于Kubernetes的服务网格中）。网格外部条目则代表了网格外部的服务。对于这些外部服务来说，mTLS身份验证是禁用的，并且策略是在客户端执行的，而不是在像内部服务请求一样在服务器端执行策略。

由于`ServiceEntry`配置只是将服务添加到网格内部的服务注册表中，因此它可以像注册表中的任何其他服务一样,与`VirtualService`和/或`DestinationRule`一起使用。例如，以下`DestinationRule`可用于启动外部服务的mTLS连接：
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: foo-ext
spec:
  name: foo.com
  trafficPolicy:
    tls:
      mode: MUTUAL
      clientCertificate: /etc/certs/myclientcert.pem
      privateKey: /etc/certs/client_private_key.pem
      caCertificates: /etc/certs/rootcacerts.pem
```
除了扩展通用性以外，`ServiceEntry`还提供了其他一些有关`EgressRule`改进，其中包括：

1. 一个`ServiceEntry`可以配置多个服务端点，这在之前需要采用多个`EgressRules`来实现。
1. 现在可以配置服务端点的解析模式（`NONE`，`STATIC`或`DNS`）。
1. 此外，我们正在努力解决另一个难题：目前需要通过纯文本端口访问安全的外部服务（例如`http://google.com:443`）。该问题将会在未来几周内得到解决，届时将允许从应用程序直接访问`https://google.com`。请继续关注解决此限制的Istio补丁版本（0.8.x）。

## 创建和删除v1alpha3路由规则
由于一个特定目的地的所有路由规则现在都存储在单个`VirtualService`资源的一个有序列表中，因此为该目的地添加新的规则不需要再创建新的`RouteRule`，而是通过更新该目的地的`VirtualService`资源来实现。

旧的路由规则：
```command
$ istioctl create -f my-second-rule-for-destination-abc.yaml
```
`v1alpha3`路由规则：
```command
$ istioctl replace -f my-updated-rules-for-destination-abc.yaml
```

删除路由规则也使用istioctl replace完成，当然删除最后一个路由规则除外（删除最后一个路由规则需要删除`VirtualService`）。

在添加或删除引用服务版本的路由时，需要在该服务相应的`DestinationRule`更新subsets 。 正如你可能猜到的，这也是使用`istioctl replace`完成的。

## 总结
Istio `v1alpha3`路由API具有比其前身更多的功能，但不幸的是新的API并不向后兼容，旧的模型升级需要一次手动转换。 Istio 0.9以后将不再支持`RouteRule`，`DesintationPolicy`和`EgressRule`这些以前的配置资源 。Kubernetes用户可以继续使用`Ingress`配置边缘负载均衡器来实现基本的路由。 但是，高级路由功能（例如，跨两个版本的流量分割）则需要使`用Gateway` ，这是一种功能更强大，Istio推荐的`Ingress`替代品。

## 致谢
感谢以下人员为新版本的路由模型重构和实现工作做出的贡献（按字母顺序）

* Frank Budinsky (IBM)
* Zack Butcher (Google)
* Greg Hanson (IBM)
* Costin Manolache (Google)
* Martin Ostrowski (Google)
* Shriram Rajagopalan (VMware)
* Louis Ryan (Google)
* Isaiah Snell-Feikema (IBM)
* Kuat Yessenov (Google)

## 原文 

* [Introducing the Istio v1alpha3 routing API](https://kubernetes.io/blog/2018/01/extensible-admission-is-beta)
