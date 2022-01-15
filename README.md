# PgHero Logs

Slow query log parser for Postgres

```sh
Total    Avg  Count  Query
(min)   (ms)
   20   4381    283  SELECT DISTINCT "orders"."id" AS t0_r0, "orders"
    7   3574    120  SELECT "visits".* FROM "visits" WHERE ("visits".
    4  12621     20  SELECT DISTINCT "order_deliveries"."id" AS t0_r0
```

## Installation

Run:

```sh
gem install pghero_logs
```

It can take a few minutes to compile the [query parser](https://pganalyze.com/blog/parse-postgresql-queries-in-ruby.html) :clock2:

## Getting Started

Tell Postgres to log slow queries in `postgresql.conf`

```conf
log_min_duration_statement = 20 # ms
```

Analyze the logs

```sh
cat /usr/local/var/log/postgres.log | pghero_logs
```

## Amazon RDS

First, download the logs. Create an IAM user with the policy below

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
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
aws configure
pghero_logs download <instance-id>
```

Once logs are downloaded, run

```sh
cat postgresql.log* | pghero_logs
```

To analyze with [PgBadger](https://github.com/dalibo/pgbadger), install

```sh
brew install pgbadger
```

And run

```sh
pgbadger --prefix "%t:%r:%u@%d:[%p]:" --outfile pgbadger.html postgresql.log*
open pgbadger.html
```

Thanks to [RDS PgBadger](https://github.com/sportngin/rds-pgbadger) for the prefix.

## History

View the [changelog](https://github.com/ankane/pghero_logs/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/pghero_logs/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/pghero_logs/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/pghero_logs.git
cd pghero_logs
bundle install
```
