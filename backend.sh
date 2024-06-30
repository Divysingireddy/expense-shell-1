#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
echo "Please enter DB password:"
read -s mysql_root_password

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2.....$R FAILURE $N"
    else
    echo -e "$2......$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
echo "Please run this script with root access"
exit 1
else
echo "You are a super user"
fi
dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE $? "Enabling Nodejs"

dnf install nodejs -y &>>LOGFILE
VALIDATE $? "Installing Nodejs"
id expense &>>LOGFILE
if [ $? -ne 0 ]
then
useradd expense &>>LOGFILE
VALIDATE $? "Creating expense user"
else
echo -e "user expense is alraedy created $Y SKIPPING $N"
fi

mkdir -p /app &>>LOGFILE
VALIDATE $? "Creating app directory" 

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>LOGFILE
VALIDATE $? "Installing Nodejs dependencies"

cp /home/ec2-user/expense-shell/backend.service  /etc/systemd/system/backend.service
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "reload backend"

systemctl start backend &>>LOGFILE
VALIDATE $? "start backend service"

systemctl enable backend &>>LOGFILE
VALIDATE $? "enable backend"

dnf install mysql -y &>>LOGFILE
VALIDATE $? "Installing mysql Client"

mysql -h db.divaws78s.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>LOGFILE
VALIDATE $? "Schema Loading"

systemctl restart backend &>>LOGFILE
VALIDATE $? "Restart backend"










