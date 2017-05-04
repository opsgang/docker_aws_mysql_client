# docker\_aws\_mysql\_client
[1]: https://github.com/opsgang/docker_aws_env "github repo for aws_env docker image"
<!--
    vim: et sr sw=4 ts=4 smartindent syntax=markdown:
-->

_... opsgang/aws_env with mysql client - default CMD will execute a file of sql (optionally gzipped)_


See [opsgang/aws_env] [1].

# EXAMPLES

```bash

# ... run arbitary sql query

QUERY="mysql -h host.example.com --port 1234 -u bob -p$(cat db_password.txt) my_db -e 'select * from my_table;'"
docker run -v /path/to/sqlfile:/sqlfile -t --rm opsgang/aws_mysql_client:stable "/bin/bash -C $QUERY"

```

```bash

# ... sql script stored in s3, using host's IAM - file can be gzipped or not.
export file=s3://some-bucket/path/to/sql #

export db_host="localhost" db_user="bob" db_pass="$(cat secret.txt)" # change values as needed

docker run -t --rm \
    --env db_host --env db_user --env db_pass --env file \
    opsgang/aws_mysql_client:stable

```

```bash

# ... sql script in S3, passing AWS creds - file can be gzipped or not
export file=s3://some-bucket/path/to/sql #

export db_host="localhost" db_user="bob" db_pass="$(cat secret.txt)" # change values as needed
export AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY # these should be defined already

docker run -t --rm \
    --env DB_HOST --env DB_USER --env DB_PASS --env FILE \
    --env AWS_DEFAULT_REGION --env AWS_ACCESS_KEY_ID --env AWS_SECRET_ACCESS_KEY
    opsgang/aws_mysql_client:stable

```

```bash

# ... sql script on container's host at /path/to/sqlfile - file can be gzipped or not.
# (we will mount it on the container at /sqlfile)
export FILE=/sqlfile

export DB_HOST="localhost" DB_USER="bob" DB_PASS="$(cat secret.txt)" # change values as needed

docker run -t --rm \
    -v /path/to/sqlfile:/sqlfile \
    --env DB_HOST --env DB_USER --env DB_PASS --env FILE \
    opsgang/aws_mysql_client:stable

```

