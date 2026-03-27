# Clash 配置文件完全指南

本文档基于 `config.yaml` 整理，为你提供一份直观的参数速查表。Clash 配置主要分为五大核心模块：基础设置、自定义 Hosts、代理节点、代理组、路由规则。

---

## 1. 基础设置 (General)

控制 Clash 核心行为的全局开关。

| 参数名 | 示例值 | 作用说明 |
| :--- | :--- | :--- |
| `mixed-port` | `7890` | **混合代理端口**。同时支持 HTTP(S) 和 SOCKS5，日常推荐配置系统或浏览器代理时填这个端口。 |
| `port` | `7891` | **HTTP(S) 代理端口**。纯 HTTP 协议端口。 |
| `socks-port` | `7892` | **SOCKS5 代理端口**。供 Telegram 等原生支持 SOCKS5 的应用使用。 |
| `allow-lan` | `false` | **局域网共享**。设为 `true` 时，手机或平板可以通过填电脑的局域网 IP 来蹭电脑的翻墙网络。 |
| `mode` | `rule` | **运行模式**。`rule`(按规则分流，最常用)、`global`(全局代理)、`direct`(全局直连不翻墙)。 |
| `log-level` | `info` | **日志级别**。可选 `info` / `warning` / `error` / `debug` / `silent`。 |
| `ipv6` | `false` | **IPv6 支持**。是否开启对 IPv6 网络请求的代理支持。 |
| `external-controller` | `127.0.0.1:9090` | **外部控制 API**。供图形化界面客户端（如 Clash Verge, Clash for Windows）和内核通信控制使用。 |
| `unified-delay` | `true` | **统一延迟**。Premium/Meta 内核专属，合并 TCP/TLS 握手时间与 HTTP 测速，让测速结果更接近真实体感。 |

---

## 2. 自定义 Hosts (Hosts)

相当于 Clash 专属的系统 hosts 文件。直接将域名映射到指定 IP，跳过 DNS 查询。常用于防 DNS 污染或内网穿透。

```yaml
hosts:
  time.facebook.com: 17.253.84.125
  time.android.com: 17.253.84.125
```

---

## 3. 代理节点 (Proxies)

定义你购买或搭建的具体服务器节点。不同的协议有不同的必填字段。

| 节点类型 (`type`) | 必填关键参数 | 选填进阶参数 | 适用场景 / 备注 |
| :--- | :--- | :--- | :--- |
| **ss** <br>(Shadowsocks) | `name`, `server`, `port`, `cipher`, `password` | `udp: true` (开启UDP) | 最经典、最轻量的协议。写起来最简单。 |
| **vmess** <br>(V2Ray) | `name`, `server`, `port`, `uuid`, `alterId`, `cipher` | `tls: true`, `network: ws`, `ws-opts` (伪装路径) | 目前最常见的机场协议，通常配合 TLS 和 WebSocket 伪装，防封锁能力强。 |
| **trojan** | `name`, `server`, `port`, `password` | `sni` (SNI域名), `skip-cert-verify: false`, `udp: true` | 将流量伪装成正常的 HTTPS 网页浏览。`server` 通常必须是真实域名。 |

*(注：配置文件中支持 YAML 的多行展开写法和单行内联写法 `{}`，两者功能完全等价。机场订阅通常使用单行写法以压缩体积。)*

---

## 4. 代理组 (Proxy Groups)

将节点打包组合起来，实现“手动选择”、“自动测速”、“故障转移”等高级玩法。

| 策略类型 (`type`) | 中文名 | 核心机制 | 必填/重要参数 |
| :--- | :--- | :--- | :--- |
| **select** | 手动选择 | 在图形界面上生成一个列表，由用户**手动点击**决定使用哪个节点。可以嵌套包含其他策略组。 | `proxies` (包含的节点列表) |
| **url-test** | 自动测速 | 自动对组内节点测速，**谁延迟最低就用谁**。适合想要极致响应速度的懒人。 | `url` (测速网址), `interval` (测速间隔), `tolerance` (容差，防频繁切换) |
| **fallback** | 故障转移 | **主备模式**。死守列表第一个节点，只有当第一个节点连不通时，才切到第二个。 | `url`, `interval`, `proxies` (越靠前优先级越高) |
| **load-balance** | 负载均衡 | 将并发请求分摊到组内所有节点上。**不叠加单线程网速，但能分散请求**。 | `strategy: consistent-hashing` (强烈建议用一致性哈希防止 IP 乱跳风控) |

---

## 5. 路由规则 (Rules)

Clash 的灵魂所在。决定哪些网站直连，哪些网站走哪个代理组。**注意：规则从上到下执行，匹配即停止。**

| 规则类型 | 作用与机制 | 示例写法 | 备注建议 |
| :--- | :--- | :--- | :--- |
| **DOMAIN-SUFFIX** | **域名后缀匹配**。只要网址以该内容结尾就匹配。 | `- DOMAIN-SUFFIX,google.com,🚀 节点选择` | **最推荐**。写一个主域名就能覆盖其所有的子域名（如 www, api）。 |
| **DOMAIN-KEYWORD** | **域名关键字匹配**。网址中只要包含该词汇就匹配。 | `- DOMAIN-KEYWORD,github,🚀 节点选择` | 杀伤力大，容易误杀，尽量少用。 |
| **DOMAIN** | **完整域名匹配**。必须一字不差完全相等才匹配。 | `- DOMAIN,www.apple.com,🚀 节点选择` | 最严格，用于极个别特定子域名的精确控制。 |
| **IP-CIDR** | **IP地址段匹配**。针对直接通过 IP 访问的请求。 | `- IP-CIDR,192.168.0.0/16,DIRECT,no-resolve` | **强烈建议加上 `no-resolve`**，防止遇到域名时强制解析 IP 拖慢速度。 |
| **DST-PORT** | **目标端口匹配**。根据请求要访问的端口号匹配。 | `- DST-PORT,25,DIRECT` | 常用于拦截 25 端口直连，防止使用代理发邮件导致节点被封。 |
| **GEOIP** | **国家地区匹配**。根据内置 IP 库判断归属地。 | `- GEOIP,CN,DIRECT` | 经典的“国内直连”玩法，不浪费代理流量。 |
| **PROCESS-NAME** | **进程名匹配**。根据发请求的软件进程名匹配。 | `- PROCESS-NAME,Thunder.exe,DIRECT` | 仅在 TUN (虚拟网卡) 模式或路由器上有效。防迅雷偷跑流量神器。 |
| **MATCH** | **兜底全匹配**。拦截所有上面没匹配到的流量。 | `- MATCH,🚀 节点选择` | **必须放在最后一行！** 决定了你是白名单还是黑名单模式。 |

## 6. 远程连接

ssh -N -L 9090:127.0.0.1:9090 root@l