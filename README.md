# Liferay 7 社区版 GA5 集群

[English](https://github.com/Lucas-Gao/liferay-7-ce-ga5-cluster/blob/master/README_en.md)

### 项目介绍
该项目用于快速构建拥有两个节点的Liferay Portal集群。

根据[Liferay 官方文档](https://dev.liferay.com/de/discover/deployment/-/knowledge_base/7-0/liferay-clustering) , 配置Liferay集群需要做出一些修改：
> 1. 所有节点需要指向同一个数据库或数据库集群。
> 2. 集群中的所有节点需要配置相同并且都能访问到的文档媒体库。<sup>①</sup>
> 3. 集群中的所有节点需要配置到相同的弹性搜索服务器或者弹性搜索集群。
> 4. Cluster Link 必须启用以便集群所有节点之间进行缓存复制。

因此，Docker Compose中配置了以下服务：
 
 1. **nginx**: 负载均衡器
 2. **liferay-portal-node-1**: Liferay 7 Community Edition GA5 版本的Portal 节点1
 3. **liferay-portal-node-2**: Liferay 7 Community Edition GA5 版本的Portal 节点2
 4. **mysql**: 集群共用的数据库
 5. **redis**: 用于解决tomcat session共享的redis <sup>②</sup>
 6. **elasticsearch**: 集群共用的elasticsearch
 
 ### 目录结构:
 ```
  .
  ├── docker-compose.yml （docker-compose配置文件）
  ├── Dockerfile-liferay (liferay的Dockerfile)
  ├── Dockerfile-nginx (nginx的Dockerflie)
  ├── LICENSE
  ├── liferay_conf (Dockerfile-liferay中使用到的liferay配置)
  │   ├── osgi
  │   │   ├── configs (集群配置文件)
  │   │   │   ├── com.liferay.portal.bundle.blacklist.internal.BundleBlacklistConfiguration.config (原有功能屏蔽配置文件)
  │   │   │   ├── com.liferay.portal.search.elasticsearch.configuration.ElasticsearchConfiguration.config (弹性搜索配置文件)
  │   │   │   └── com.liferay.portal.store.file.system.configuration.AdvancedFileSystemStoreConfiguration.cfg (共享目录配置文件)
  │   │   └── modules (集群所需的jar)
  │   │       ├── com.liferay.portal.cache.ehcache.multiple.jar (缓存)
  │   │       ├── com.liferay.portal.cluster.multiple.jar (集群)
  │   │       └── com.liferay.portal.scheduler.multiple.jar (任务调度)
  │   ├── portal-ext.properties (liferay配置文件)
  │   └── tomcat (Dockerfile-liferay中使用到的tomcat配置)
  │       ├── bin
  │       │   └── setenv.sh (JVM参数)
  │       ├── conf
  │       │   └── context.xml (session共享配置)
  │       └── lib
  │           └── ext (session共享所需jar)
  │               ├── commons-pool2-2.3.jar
  │               ├── jedis-2.7.3.jar
  │               └── tomcat-redis-session-manager-master-2.0.0.jar
  ├── nginx_conf (Dockerfile-nginx中使用到的nginx配置)
  │   └── nginx
  │       └── nginx.conf (负载均衡配置)
  └── README.md
 ```

 # 如何使用
 
 启动liferay-portal-node-1服务
 
 ```shell
  docker-compose up -d liferay-portal-node-1
 ```
 
 待liferay-portal-node-1可访问后 <sup>③</sup>，启动liferay-portal-node-2服务，构成两个节点的集群

 ```shell
  docker-compose up -d liferay-portal-node-2
 ```
 
 待liferay-portal-node-2可访问后，启动nginx
 
 ```shell
  docker-compose up -d nginx
 ```
 
 通过负载均衡访问: http://localhost
 
 访问 liferay-portal-node-1: http://localhost:6080
  
 访问 liferay-portal-node-2: http://localhost:7080
 
 
 # 参考文档
 * https://dev.liferay.com/de/discover/deployment/-/knowledge_base/7-0/liferay-clustering
 * https://dev.liferay.com/de/discover/deployment/-/knowledge_base/7-0/document-repository-configuration
 * https://dev.liferay.com/de/discover/deployment/-/knowledge_base/7-0/configuring-elasticsearch-for-liferay-0
 * http://www.cnblogs.com/sss-justdDoIt/p/9082918.html
 
 
 ---
 ① *采用了Docker部署集群，给不同容器配置Docker Volume指向宿主机上的同一个目录即可实现共享文档媒体库。*

 ② *采用了nginx轮询的负载均衡策略，所以需要配置tomcat session共享机制, 如果配置了会话保持机制，可以不启用redis服务，并对 `context.xml` 做相应修改。* 

 ③ *`portal-ext.properties`中`setup.wizard.enabled=false`时，Liferay Portal会在启动时会检查数据库中是否存在初始化数据，不存在时会先进行初始化，若多个节点同时初始化数据会出错，所以新库只能等带初始化好了之后再启动第二个节点*
