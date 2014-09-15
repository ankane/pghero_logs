# PgHero Logs

Slow query log parser for Postgres

```sh
Total    Avg  Count  Query
(min)   (ms)
   20   4381    283  SELECT DISTINCT "orders"."id" AS t0_r0, "orders"
    7   3574    120  SELECT "visits".* FROM "visits" WHERE ("visits".
    4  12621     20  SELECT DISTINCT "order_deliveries"."id" AS t0_r0
```

## Install

```sh
gem install pghero_logs
```

It can take 10 minutes or more to compile the [query parser](https://pganalyze.com/blog/parse-postgresql-queries-in-ruby.html) :clock2:

Tell Postgres to log slow queries in `postgresql.conf`

```conf
log_min_duration_statement = 20 # ms
```

Analyze the logs

```sh
cat /usr/local/var/postgres/server.log | pghero_logs
```

## Amazon RDS

First, download the logs. Create an IAM user with the policy below

```sh
{
  "Statement": [
    {
      "Sid": "Stmt1410669817271",
      "Action": [
        "rds:DescribeDBLogFiles",
        "rds:DownloadDBLogFilePortion"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

And run

```sh
export AWS_ACCESS_KEY_ID=test123
export AWS_SECRET_ACCESS_KEY=secret123
export AWS_DB_INSTANCE_IDENTIFIER=production
pghero_logs download
```

Once logs are downloaded, run

```sh
cat logs/postgresql.log.* | pghero_logs
```
