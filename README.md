# REFACTOR IN PROGRESS

# Sidecar Backup Mongo

* Only tested with AWS, minio WIP *

## Automatic Mongod Backup on S3

Example deploy on  ```deploy_sidecar_example/docker-compose.yml```

Copy `env.sample` as `.env`

ENVIROMENT VARIABLE   | DESCRIPTION | Values
----------   | ---------- | --------------  
MONGO_URI | SRV MONGODB URI | Mongodb uri
MONGO_FILENAME | Filename prefix | String
SCHEDULE | see below | 
ZIP_FILE | true to enable tar.gz compression | `true` or empty
CLEAN_DAYS | number of backup retention days | integer or empty

## Schedule

Tip on ```SCHEDULE``` enviroment variable:

Field name   | Mandatory? | Allowed values  | Allowed special characters
----------   | ---------- | --------------  | --------------------------
Seconds      | Yes        | 0-59            | * / , -
Minutes      | Yes        | 0-59            | * / , -
Hours        | Yes        | 0-23            | * / , -
Day of month | Yes        | 1-31            | * / , - ?
Month        | Yes        | 1-12 or JAN-DEC | * / , -
Day of week  | Yes        | 0-6 or SUN-SAT  | * / , - ?

## Minio/S3 config

ENVIROMENT VARIABLE   | DESCRIPTION | Values
----------   | ---------- | --------------  
S3_BUCKET_FOLDER | Where to put backup | string without starting slash |
S3_UPLOAD | Flag to enable s3 upload | `true` or empty
S3_BUCKET | Bucket name | string (Aws bucket name)
S3_MINIO_HOST | host:port | `host:port/` or empty is AWS s3
S3_PROTOCOL | protocol type | `http` or `https` or `s3` if AWS
S3_KEY | key | string , AWS_ACCESS_KEY_ID
S3_SECRET | secret | string AWS_SECRET_ACCESS_KEY
MINIO_PORT | local minio port to expose on host | port number

# Usage

Create `.env` file:

```bash
### db connection
MONGO_URI=db
MONGO_FILENAME=superbackup
### cron schedule
SCHEDULE=0 * * * * *

### PUT S3_UPLOAD to true to upload your dump on s3 or minio bucket
S3_UPLOAD=true
### S3 or minio host
S3_HOST=minio:9000
### Protocol
S3_PROTOCOL=http
### Your bucket name
S3_BUCKET=cicciopollo
### minio or s3 credentials
S3_KEY=85A8U57ZITLSLFBYKNCG
S3_SECRET=14MAuAetrv7y3E6zAuUOimXy5KYRqrZKw3cWuEe/
### port of local minio
MINIO_PORT=9000

### ZIP FILE
ZIP_FILE=true

### Number of days to maintain backup history
CLEAN_DAYS=15

```

Create `docker-compose.yml` file:

```yml
version: '2'
services:
  sidecar-backup-mongo:
      image: beeckup/sidecar-backup-mongo:latest
      volumes:
          - ./dumpdb:/go/src/app/dumpdb
      restart: always
      environment:
        - MONGO_URI=${MONGO_URI}
        - MONGO_FILENAME=${MONGO_FILENAME}
        - SCHEDULE=${SCHEDULE}
        - S3_UPLOAD=${S3_UPLOAD}
        - S3_BUCKET=${S3_BUCKET}
        - S3_BUCKET_FOLDER=${S3_BUCKET_FOLDER}
        - S3_KEY=${S3_KEY}
        - S3_SECRET=${S3_SECRET}
        - S3_PROTOCOL=${S3_PROTOCOL}
        - ZIP_FILE=${ZIP_FILE}
        - CLEAN_DAYS=${CLEAN_DAYS}
```

Launch with

```bash
docker-compose up -d
```
