FROM maven

WORKDIR /app
RUN cd /app
EXPOSE 8090
COPY settings.xml .
COPY settings.xml /root/.m2/settings.xml
COPY /target/tng-dpolicy-mngr-1.5.0.jar .
COPY /sample-kjar /app/sample-kjar
COPY /deploykjar.sh /app/deploykjar.sh

ENV MONGO_DB son-mongo

#ENV HOST_BROKER int-sp-ath.5gtango.eu
#ENV CATALOGUE int-sp-ath.5gtango.eu:4011
#ENV MONITORING_MANAGER int-sp-ath.5gtango.eu:8000
#ENV REPO int-sp-ath.5gtango.eu:4012

ENV HOST_BROKER son-broker
ENV CATALOGUE tng-cat:4011
ENV MONITORING_MANAGER son-monitor-manager:8000
ENV REPO tng-rep:4012

ENV NEXUS son-nexus

CMD ["java","-jar","-Dspring.profiles.active=policyProfile","tng-dpolicy-mngr-1.5.0.jar"]
