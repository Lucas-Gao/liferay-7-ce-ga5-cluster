# Liferay 7 Community Edition GA5 Cluster

[中文文档](https://github.com/Lucas-Gao/liferay-7-ce-ga5-cluster/blob/master/README.md)

### Introduction
This repository is a Docker Compose project that allows you to run a Liferay portal cluster composed of two working nodes.

According to [Liferay Documentation](https://dev.liferay.com/de/discover/deployment/-/knowledge_base/7-0/liferay-clustering) , Liferay should be configured in the following way for a clustered environment：

> 1. All nodes should be pointing to the same Liferay Portal database or database cluster.
> 2. Documents and Media repositories must have the same configuration and be accessible to all nodes of the cluster.<sup>①</sup>
> 3. Search should be on a separate search server that is optionally clustered.
> 4. Cluster Link must be enabled so the cache replicates across all nodes of the cluster.

This Docker Compose contains this services:

 1. **nginx**: Load Balancer
 2. **liferay-portal-node-1**: Liferay Portal 7 GA5 node 1
 3. **liferay-portal-node-2**: Liferay Portal 7 GA5 node 2
 4. **mysql**: database of two Liferay Portal nodes
 5. **redis**: redis for store tomcat session <sup>②</sup>
 6. **elasticsearch**: elasticsearch in remote operation mode
 
 ### Structure:
 ```
  .
  ├── docker-compose.yml (docker-compose configuration)
  ├── Dockerfile-liferay (Dockerfile for liferay)
  ├── Dockerfile-nginx (Dockerflie for nginx)
  ├── LICENSE
  ├── liferay_conf (liferay configuration used in Dockerfile-liferay)
  │   ├── osgi
  │   │   ├── configs (cluster configuration file)
  │   │   │   ├── com.liferay.portal.bundle.blacklist.internal.BundleBlacklistConfiguration.config (block original function)
  │   │   │   ├── com.liferay.portal.search.elasticsearch.configuration.ElasticsearchConfiguration.config (configure elasticsearch)
  │   │   │   └── com.liferay.portal.store.file.system.configuration.AdvancedFileSystemStoreConfiguration.cfg (configure file store)
  │   │   └── modules (required jar for liferay cluster)
  │   │       ├── com.liferay.portal.cache.ehcache.multiple.jar (ehcache)
  │   │       ├── com.liferay.portal.cluster.multiple.jar (cluster)
  │   │       └── com.liferay.portal.scheduler.multiple.jar (scheduler)
  │   ├── portal-ext.properties (liferay configuration file)
  │   └── tomcat (tomcat configuration used in Dockerfile-liferay)
  │       ├── bin
  │       │   └── setenv.sh (JVM arguments)
  │       ├── conf
  │       │   └── context.xml (session sharing configuration)
  │       └── lib
  │           └── ext (required jar for session sharing)
  │               ├── commons-pool2-2.3.jar
  │               ├── jedis-2.7.3.jar
  │               └── tomcat-redis-session-manager-master-2.0.0.jar
  ├── nginx_conf (nginx configuration used in Dockerfile-nginx)
  │   └── nginx
  │       └── nginx.conf (load balancing configuration)
  └── README.md
 ```

 # Usage
 
 Start liferay-portal-node-1
 
 ```shell
  docker-compose up -d liferay-portal-node-1
 ```
 
 After liferay-portal-node-1 is accessable <sup>③</sup>, start liferay-portal-node-2

 ```shell
  docker-compose up -d liferay-portal-node-2
 ```
 
 After liferay-portal-node-2  is accessable, start nginx
 
 ```shell
  docker-compose up -d nginx
 ```
 
 Access liferay cluster by Load Balancer: http://localhost
 
 Access liferay-portal-node-1: http://localhost:6080
  
 Access liferay-portal-node-2: http://localhost:7080
 
 
 # Reference
 * https://dev.liferay.com/de/discover/deployment/-/knowledge_base/7-0/liferay-clustering
 * https://dev.liferay.com/de/discover/deployment/-/knowledge_base/7-0/document-repository-configuration
 * https://dev.liferay.com/de/discover/deployment/-/knowledge_base/7-0/configuring-elasticsearch-for-liferay-0
 * http://www.cnblogs.com/sss-justdDoIt/p/9082918.html
 
 
 ---
 ① *The Docker deployment cluster is adopted, and the Shared document media library can be realized by configuring Docker Volume to point to the same directory on the host machine.*

 ② *Adopted nginx polling load balancing strategy, so you need to configure tomcat mechanism of sharing session, if the configuration session keep mechanism, can not use redis service, and the ` context.xml` make corresponding changes.* 

 ③ *When `setup.wizard.enabled=false` in `portal-ext.properties`，Liferay Portal will check if there is initialized data in the database at startup, and if there is no initialized data, it will initiate it first. If multiple nodes simultaneously initialize data, there will be an error, so the second node can only start after the initialization is completed when database is fire-new.*
