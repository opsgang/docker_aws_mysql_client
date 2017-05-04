#!/bin/bash
# vim: ts=4 sw=4 et sr smartindent:
#
# To run, set the following vars in your environment:
#
# $DBHOST: location of remote DB
# $DBPORT: listening mysql port
# $DBUSER: the user to connect as
# $DBPASS: the user's pword.
# $FILE: s3:// uri or absolute path to local file
#
REQUIRED_VARS="
    DBHOST
    DBPASS
    DBPORT
    DBUSER
    FILE
"

_set_SC() {
    if [[ $0 =~ ^-?bash$ ]]; then
        echo "bash"
    else
        basename $(realpath -- $0)
    fi
}

_check_var_defined() {
    local var_name="$1"
    local var_val="${!var_name}"
    [[ -z $var_val ]] && return 1
}

required_vars() {
    local rc=0
    local required_vars="$1"
    local this_var
    for this_var in $required_vars; do
        if ! _check_var_defined $this_var
        then
            e "\$$this_var must be set in env"
            rc=1
        fi
    done

    return $rc
}
# e() / i() ... print log msg
e() {
    echo -e "ERROR $SC: $*" >&2
}

i() {
    echo -e "INFO $SC: $*"
}

SC=$(_set_SC)
# ... validate required vars
required_vars "$REQUIRED_VARS" || exit 1

MYSQL_OPTS="--host=$DBHOST --port=$DBPORT --user=$DBUSER --password=$DBPASS"
[[ ! -z "$DBNAME" ]] && MYSQL_OPTS="$MYSQL_OPTS $DBNAME"

# ... test can connect to specific db
i "... verifying can connect to $DBHOST:$DBPORT (db ${DBNAME:-NOT PROVIDED}) with provided creds"
if ! mysql $MYSQL_OPTS -e 'select "1";'
then
    e "... couldn't connect to mysql host:port<$DBHOST:$DBPORT> (db ${DBNAME:-NOT PROVIDED})"
    exit 1
fi

LFILE=$FILE
if [[ $FILE =~ ^s3:// ]]; then
    LFILE=/var/tmp/$(basename $FILE)
    ! aws s3 cp "$FILE" $LFILE && e "... couldn't download $FILE to $LFILE" && exit 1
else
    [[ ! -r $LFILE ]] && e "... can not read file $LFILE" && exit 1
fi

i "... checking if gzipped"
if gunzip -t $LFILE 2>/dev/null
    UNZFILE=/var/tmp/my.sql
    i "... gunzipping to /var/tmp/my.sql"
    ! gunzip -c $LFILE >$UNZFILE && e "... failed to gunzip $LFILE" && exit 1
    LFILE=$UNZFILE
fi

# ... run
i "... running sql file"
mysql $MYSQL_OPTS < $LFILE
