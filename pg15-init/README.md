# dev-tapdb-pg12 

Builds a postgresql server image with a simple database init suitable for development.

## Expected deployment
This postgresql instance is designed for development support and has a very low level of
security.

## databases
On startup, the following user accounts are created (name : password):
```
cadmin  : pw-cadmin
tapadm  : pw-tapadm
tapuser : pw-tapuser
```
These users are available in all databases.

## databases and schemas
The following schemas are created in all databases (name : acccount with full authorization):
```
tap_upload : tapuser
tap_schema : tapadm
uws        : tapadm
```

Databases to be created, and additional schemas for content, are configured by including the
file /tmp/init-content-schemas.sh:
```
CATALOGS="db1 db2 ..."
SCHEMAS="schema1 schema2 ..."
```

At least one database (CATALOG) and one schema is needed to start a useful postgresql server.
The `cadmin` account will have full authorization in these "content" schema(s).
