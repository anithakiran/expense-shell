#!/bin/bash

USERID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo  "please enter DB password"
read  mysql_root_password

if [ $USERID -ne 0 ]
then 
    echo "please run this script with root access"
    exit 1
else
    echo "your are super user"
fi

echo "script started executing at : $TIMESTAMP"

VALIDATE() {
if [ $1 -ne 0 ]
then    
    echo -e "$2 is $R failure $N "
else
    echo -e "$2 is $G successfull $N"
fi
}

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>> $LOGFILE
if [ $? -ne 0 ]
then 
    useradd expense &>> $LOGFILE
    VALIDATE $? "creating expense user"
else
    echo -e "expense user already exist.... $Y skipping $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>> $LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>> $LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>> $LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing mysql client"


mysql -h db.devopsaws78s.online -uroot -p${mysql_root_password}  < /app/schema/backend.sql &>> $LOGFILE
VALIDATE $? "Loading scehma"

systemctl restart backend &>> $LOGFILE
VALIDATE $? "Restarting backend"


