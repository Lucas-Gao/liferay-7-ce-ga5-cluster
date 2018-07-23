FROM mdelapenya/liferay-portal:7-ce-ga5-tomcat-hsql


COPY ./configs/portal-ext.properties $LIFERAY_CONFIG_DIR/
COPY ./configs/*.config $LIFERAY_CONFIG_DIR/osgi/
COPY ./configs/*.cfg $LIFERAY_CONFIG_DIR/osgi/
COPY ./configs/*.jar $LIFERAY_HOME/osgi/modules/
COPY ./configs/tomcat/lib/*.jar $LIFERAY_HOME/tomcat-8.0.32/lib/ext/
COPY ./configs/tomcat/context.xml $LIFERAY_HOME/tomcat-8.0.32/conf/
