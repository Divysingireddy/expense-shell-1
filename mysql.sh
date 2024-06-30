#!/bin/bash

echo "Please enter DB password:"
read -s mysql_root_password

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installation of Mysql"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MYSQL"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

#Below code will be useful for idempotent nature
mysql -h db.divaws78s.online -uroot -p${mysql_root_password} -e 'show databases;' &>>LOGFILE
if [ $? -ne 0 ]
then 
Mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
VALIDATE $? "MYSQL Root password setup"
else
echo -e "MySQL root password is already setup..$Y SKIPPING $N"
fi