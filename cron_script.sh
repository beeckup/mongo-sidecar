#!/bin/sh

echo "Process starting..."

_now=$(date +"%s_%m_%d_%Y")

_name=$MONGO_FILENAME"_"$_now

_folder="$S3_BUCKET_FOLDER"

_file="dumpdb/$_name"

echo $_file



    echo "Dumping Mongodb database..."

    mongodump --uri $MONGO_URI --archive=./$_file

    if [ "$ZIP_FILE" = "true" ]; then
        echo "Compress  Mongodb database..."
        tar -cvzf "dumpdb/"$_name".tar.gz" $_file
        rm $_file
        _file="dumpdb/"$_name".tar.gz"

    fi


    if [ "$S3_UPLOAD" = "true" ]; then



        echo "S3 upload database ($_file) ..."

        aws configure set aws_access_key_id $S3_KEY
        aws configure set aws_secret_access_key $S3_SECRET

        if ! [ "$S3_MINIO_HOST" = "" ]; then
            #TODO
            echo "nothing to do"
        else
            aws s3 cp $_file s3://$S3_BUCKET/$S3_BUCKET_FOLDER/"$_name".tar.gz
        fi



        rm $_file

    fi



if [ "$CLEAN_DAYS" -gt "0" ]; then
    echo "Cleaning bucket"
    ./cleaner.sh "$S3_BUCKET" "$CLEAN_DAYS days" "$S3_BUCKET_FOLDER"

fi
