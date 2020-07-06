FROM openjdk:8 AS build
RUN wget https://dist.ballerina.io/downloads/1.2.4/ballerina-linux-installer-x64-1.2.4.deb
RUN dpkg -i ballerina-linux-installer-x64-1.2.4.deb
WORKDIR /usr/src/

ENV TZ=Asia/Colombo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD . /usr/src/

RUN ballerina build --skip-tests --all
RUN ls -l target/bin/

FROM openjdk:8

ENV TZ=Asia/Colombo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY  --from=build /usr/src/target /usr/src/target
WORKDIR /usr/src/target/
EXPOSE 9090
CMD java jar bin/services.jar --eclk.hub.db.url=jdbc:mysql://$DB_URL --eclk.hub.db.username=$DB_UN --eclk.hub.db.password=$DB_PW --eclk.hub.db.useSsl=$DB_USE_SSL --eclk.hub.db.encryptionkey=$DB_ENCRYPTION_KEY