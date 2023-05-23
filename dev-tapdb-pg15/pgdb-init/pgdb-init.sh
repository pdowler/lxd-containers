#!/bin/bash

VER=15
PGBASE=/var/lib/pgsql/$VER

LOG=$PGBASE/do-init.log
touch $LOG

echo -n "START: " >> $LOG
date >> $LOG

INITDB=0

if [ -e $PGBASE/data/postgresql.conf ]; then
    echo "$0: detected existing setup... skipping database init" >> $LOG
else
    INITDB=1
fi

if [ $INITDB == 1 ]; then
    # change ownership of injected config files
    chown -R postgres.postgres ${PGBASE}/*
    su -l postgres -c '/bin/bash /usr/local/bin/pgdb-init-postgres.sh' >> $LOG
fi

# configure server to start automatically
systemctl enable postgresql-${VER}.service >> $LOG

# start server
systemctl start postgresql-${VER}.service >> $LOG

if [ $INITDB == 1 ]; then
    # create standard user(s), database(s), schema(s)
    su -l postgres -c '/bin/bash /usr/local/bin/pgdb-init-content.sh' >> $LOG
fi

echo -n "DONE: " >> $LOG
date >> $LOG

