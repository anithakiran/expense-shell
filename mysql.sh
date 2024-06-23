#!/bin/bash

USERID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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
    echo -e "installation is $R failure $N "
else
    echo -e "installation is $G successfull $N"
fi
}

dnf install mysql-server -y  &>> $LOGFILE
VALIDATE $? "Installing Mysql-Server"

systemctl enable mysqld  &>> $LOGFILE
VALIDATE $? "Enabling mysql-server"

systemctl start mysqld  &>> $LOGFILE
VALIDATE $? "starting mysql-server"

echo  "please enter DB password"
read -s mysql_root_password

mysql_secure_installation --set-root-pass ExpenseApp@1 &>> $LOGFILE
VALIDATE $? "setting up root password"

mysql -h devopsaws78s.online -uroot -p${mysql_root_password} -e 'show database'; &>> $LOGFILE

if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi