S3_BUCKET_NAME=prodbuilds
S3_SUBFOLDER_NAME=SAMPLEAPP
BUILD_NUMBER=${GO_PIPELINE_COUNTER}
APPLICATION_JAR_NAME=sampleapp-0.0.1-SNAPSHOT.jar
CURRENT_BUILD_S3LOCATION=s3://$S3_BUCKET_NAME/$S3_SUBFOLDER_NAME/CurrentBuild/$APPLICATION_JAR_NAME
BUILD_NUMBER_S3LOCATION=s3://$S3_BUCKET_NAME/$S3_SUBFOLDER_NAME/$BUILD_NUMBER/$APPLICATION_JAR_NAME

printf "\n"
echo "=========================================="
printf "\n"
echo Uploading Build Number $BUILD_NUMBER to $CURRENT_BUILD_S3LOCATION
printf "\n"
aws s3 cp target/$APPLICATION_JAR_NAME $CURRENT_BUILD_S3LOCATION
echo Uploading to current Build folder completed
printf "\n"

echo Uploading Build Number $BUILD_NUMBER to BUILD_NUMBER_S3LOCATION
printf "\n"
aws s3 cp target/$APPLICATION_JAR_NAME $BUILD_NUMBER_S3LOCATION
echo Uploading to  Build Number folder completed
printf "\n"






