APPLICATION_ROOT_FOLDER=/home/teja_siram/Documents/Deployment/SAMPLEAPP
APPLICATION_JAR_NAME=sampleapp-0.0.1-SNAPSHOT.jar
S3_BUCKET_NAME=prodbuilds
S3_SUBFOLDER_NAME=SAMPLEAPP
APPLICATION_NAME=SAMPLEAPP

printf "\n"
echo Application_Name: $APPLICATION_NAME
echo "=========================================="

echo Application_Root_Folder: $APPLICATION_ROOT_FOLDER
echo "=========================================="

IP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
echo Deploying $APPLICATION_NAME on machine IP :::::::::::: $IP

printf "\n"

PID=`ps aux  |  grep -i $APPLICATION_JAR_NAME | grep -v grep  |  awk '{print $2}' `
echo Gracefully shutting down application $APPLICATION_NAME by killing processid ::::: $PID
#Stop the existing instance of the application
ps aux  |  grep -i $APPLICATION_JAR_NAME | grep -v grep  |  awk '{print $2}' |  xargs kill -9

printf "\n"
echo Application $APPLICATION_NAME shutdown completed

printf "\n"
echo "Please wait while taking back up of Nohup file to S3 folder"

#Take Backup of nohup to S3 folder
if [ -e $APPLICATION_ROOT_FOLDER/nohup.out ]
then 
    nohup_backupfilename=nohup_`date +%s`
    echo Taking backup to s3 folder to filename $nohup_backupfilename
    aws s3 cp $APPLICATION_ROOT_FOLDER/nohup.out s3://$S3_BUCKET_NAME/$S3_SUBFOLDER_NAME/NOHUP_BACKUPS/$nohup_backupfilename
else
    echo "nohup not present..Hence No taking any backup"
fi

printf "\n"

echo "Nohup backup succesfully transferred to S3"

echo "=============================================================================="

#copy the current build to old build
source1=$APPLICATION_ROOT_FOLDER/CurrentBuild/$APPLICATION_JAR_NAME
destination1=$APPLICATION_ROOT_FOLDER/OldBuild/
echo copying $source1 to $destination1
cp $source1 $destination1 

#copy the latest build from S3 Buckets	
printf "\n"
echo "Please wait while downloading latest build from  s3://$S3_BUCKET_NAME/$S3_SUBFOLDER_NAME/CurrentBuild"
aws s3 cp s3://$S3_BUCKET_NAME/$S3_SUBFOLDER_NAME/CurrentBuild/$APPLICATION_JAR_NAME $APPLICATION_ROOT_FOLDER/CurrentBuild/
printf "\n"
echo "Latest build successfully downloaded.."
printf "\n"

echo "starting the application with latest build"
#Start the application with nohup and write 
nohup java -jar $APPLICATION_ROOT_FOLDER/CurrentBuild/$APPLICATION_JAR_NAME &

NEWPID=`ps aux  |  grep -i $APPLICATION_JAR_NAME | grep -v grep  |  awk '{print $2}' `

echo Application succesfully started on machine :: $IP with new processid $NEWPID

echo "=========================================================="

