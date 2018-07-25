# Liferay 7 Community Edition GA5 Cluster

[中文文档](https://github.com/Lucas-Gao/liferay-7-ce-ga5-cluster/blob/master/README.md)

 This repository is a Docker Compose project that allows you to run a Liferay portal cluster composed of two working nodes.
 
 This Docker Compose contains this services:
 
 1. **nginx**: Load Balancer
 2. **liferay-portal-node-1**: Liferay Portal 7 GA5 node 1
 3. **liferay-portal-node-2**: Liferay Portal 7 GA5 node 2
 4. **mysql**: database of two Liferay Portal nodes
 5. **redis**: redis for store tomcat session
 6. **elasticsearch**: elasticsearch in remote operation mode
