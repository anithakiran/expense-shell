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

