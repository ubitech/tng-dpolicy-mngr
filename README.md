# 5GTango policy manager
Policies in 5GTANGO are considering deployment and operational aspects of network services over programmable infrastructure. Operational or runtime policies regard the runtime adaptation of network service mechanisms in order to optimally support the overall performance achieved. 

Every runtime runtime policy is defined upon a specific NS. Based on this, for each NS, a set of rules per policy can be defined. Each rule consists of the expressions part, denoting a set of conditions to be met and the actions part denoting actions upon the fulfillment of the conditions. The conditions may regard resources consumption aspects, software-specific aspects, status of a VNF or a NS, while the set of actions may regard resources allocation/disposal aspects, live migration and mobility aspects, horizontal scaling aspects and network functions management or activation aspects.

A network service may be associated with a set of runtime policies, however only one can be active each time. A runtime policy can be defined by the software developer of the NS, having detailed knowledge of the business logic of the developed software, or the network operator/service platform manager having knowledge of the available resources and the set of active SLAs. Knowledge of SLAs can lead to description of set of rules guaranteeing that such SLAs can be respected in the maximum possible way.

Policies enforcement is realized through a rule-based management system. Based on the set of activated rules associated with the deployed network services and the real time collection of data, inference is realized leading to policies enforcement. Such enforcement takes place over the deployed network services, while the inference follows a continuous match-resolve-act approach. In the match phase, the set of defined conditions are examined, leading to the set of rules that have to be activated, while in the resolve phase, conflict resolution over the set of rules to be activated is taking place. The act phase concerns the triggering of the suggested actions aiming at the guidance of various orchestration components of the 5GTANGO service platform. For each rule, an inertial period is introduced denoting the time period that the same rule should not be re-triggered.

#### Technical Overview  

Current project consists of a scalable policy engine based on the following prototype: https://github.com/ubitech/generic-policy-engine. Policy engine is based on drools technology with rule kjars discovery in a remote maven repository. Discovery of remote kjars is done via the drools KieScanner. KieScanner is a scanner of the maven repositories (both local and remote) used to automatically discover if there are new releases for a given KieModule and its dependencies and eventually deploy them in the KieRepository.

Sample runtime policy descriptors can be found at [policy descriptor examples](https://github.com/sonata-nfv/tng-schema/tree/master/policy-descriptor/examples) based at [policy descriptor schema](https://github.com/sonata-nfv/tng-schema/blob/master/policy-descriptor/policy-schema.yml). Policy rules defined at policy descriptors are translated at drool rules.

#### Policy engine Arquitecture:

<img src="/images/policyArchitecture.png" width="500">

The delivery of the different policy action messages are delivered at the policy engine workers as follows:  

<img src="/images/distributedpolicymanager.png" width="1000">

## Documentation - APIs and swagger support


Following table shows the API endpoints of the Policy Manager.
tng-policy-mngr supports its own swagger endpoint at http://<ip_adress>/swagger-ui.html

| Action | HTTP Method | Endpoint |
| --------------- | ------- | -------------------------------------------- |
| GET a list of all Runtime policies | `GET` |`/api/v1`|
| GET a list of all Runtime policies matching a specific network service | `GET` |`/api/v1?ns_uuid={value}`|
| Create a Runtime Policy | `POST` |`/api/v1`|
| GET a Runtime policy | `GET` |`/api/v1/{policy_uuid}`|
| Update a Runtime Policy | `PUT` |`/api/v1`|
| Delete a Runtime Policy | `DELETE` |`/api/v1/{policy_uuid}`|
| Bind a Runtime Policy to an SLA | `PATCH` |`/api/v1/bind/{policy_uuid}`|
| Define a Runtime Policy as default | `PATCH` |`/api/v1/default/{policy_uuid}`|
| GET a list of all Recommended Actions | `GET` |`/api/v1/actions`|
| Create the Placement Policy | `POST` |`/api/v1/placement`|
| GET the Placement policy | `GET` |`/api/v1/placement`|
| Pings to policy manager | `GET` |`/api/v1/pings`|


### Setup development environment
####  Built With (Dependencies)

* Sonata Service Platform local installation (recommended) or vpn connection to SP environment 
* [Docker >= 1.13](https://www.docker.com/)
* [Docker compose version 3](https://docs.docker.com/compose/)
* [Java version 1.8](https://www.oracle.com/technetwork/java/javase/overview/java8-2100321.html) - The programming language used
* [Maven](https://maven.apache.org/) - Dependency Management
* [Drools version 7.7.0](https://www.drools.org/) - Business Rules Management System (BRMS) solution used so as to enforce policies
* [Spring boot Framework 2.0.3 RELEASE](https://spring.io/projects/spring-boot) - Used application framework

#### Prerequisites:
1. Rabbitmq pub/sub framework  
You can access to http://localhost:15672 with username/password guest/guest.  
You should configure rabbitmq by ip at the application properties of policyengine  
```
docker-compose up -d broker
docker exec broker rabbitmq-plugins enable rabbitmq_management
```
2. A Nexus maven repository  
```
docker-compose up -d my-nexus //like this there is a connectivity problem between policy manager container and nexus
docker run -d -p 8081:8081 -p 8082:8082 -p 8083:8083 --name my-nexus sonatype/nexus3:3.0.0
```
You should create a new repository named  maven-group that includes the following sub repositories: central, releases & snapshots.  
Extra information can be found http://codeheaven.io/using-nexus-3-as-your-repository-part-1-maven-artifacts/  
You can access Nexus repository at http://localhost:8081  

You should update the ip of the remote nexus maven repository at the following files:  

* settings.xml
* /src/main/resources/application.properties


#### Local mode execution it in standalone mode:
```
mvn clean instal 
java -jar target/policy-engine-0.0.1-SNAPSHOT.jar 
```

#### Containerized mode:
In containerized  mode there is an extra prerequisites. This consist in enabling a load balancer in front of the workers. Traefik load balancer is selected for that. You can access traefik at http://localhost:8080/dashboard/    

##### Start Traefik load balancer
```
sudo service apache2 stop //Stop apache because traefik uses the port 80
docker-compose up -d reverse-proxy 
```

##### Create policyengine container(s)
```
docker  build -t policyengine . // build policy engine image
docker-compose up -d policyengine // Create only one worker
docker-compose up -d --scale policyengine=2  //Create a cluster of policy engine containers
```

##### Some usefull commmands for testing are:  
```docker images //fetch all docker images  
docker image prune -a // remove all images which are not used by existing containers  
docker rm $(docker stop $(docker ps -a -q --filter ancestor=policyengine --format="{{.ID}}")) // kill all policy engine workers
docker logs policyengine_policyengine_1 --follow //read logs from a worker
docker exec -it  policyengine_policyengine_1  bash // get inside the container

```  
### CI Integration
All pull requests are automatically tested by Jenkins and will only be accepted if no test is broken.

### License

This component is published under Apache 2.0 license. Please see the LICENSE file for more details.

### Lead Developers

The following lead developers are responsible for this repository and have admin rights. They can, for example, merge pull requests.

- Eleni Fotopoulou ([@elfo](https://github.com/efotopoulou))
- Anastasios Zafeiropoulos ([@tzafeir ](https://github.com/azafeiropoulos))

### Development

To contribute to the development of this 5GTANGO component, you may use the very same development workflow as for any other 5GTANGO Github project. That is, you have to fork the repository and create pull requests.


### Feedback-Chanel
* Please use the GitHub issues to report bugs.
