#!/bin/bash

USERNAME=$2
PASSWORD=$3

checkError()
{
    ERROR_CODE=$1
    MESSAGE=$2
    if [ $ERROR_CODE -ne 0 ]
    then
        echo $MESSAGE
        exit 1
    fi
}

addUser()
{
  # Checks to see is Password is empty. If so, it generates a random password
  if [ -z "$PASSWORD" ];
  then
    PASSWORD=$(date +%s | sha256sum | base64 | head -c 32)
  fi

  echo $PASSWORD
  # Write username and password to credentials file
  echo "Hello $USERNAME, Here are your credentials to log in" >> credentials.txt
  echo "" >> credentials.txt
  echo "username: $USERNAME" >> credentials.txt
  echo "password: $PASSWORD" >> credentials.txt

  # This line is to add a user that is passed in as first command lione argument
  sudo useradd -m $USERNAME
  checkError $? "Could not create $USERNAME"
  
  # Send success message to person running script
  echo "Great Job!!! $USERNAME has been added to the system successfully"

  # This line is to set password for user that is passed in as second command line argument
  echo $USERNAME:$PASSWORD | sudo chpasswd
  checkError $? "Unable to set password for $USERNAME"
  echo "Successfully set the user's password!"

  # Send email to user
  mail -A ./credentials.txt -s "Here are your credentials" "$USERNAME@ourcooltechcompany.com" < /dev/null
  checkError $? "Failed sending mail to $USERNAME"
  echo "Successfully sent credentials to $USERNAME@ourcooltechcompany.com!"

  #Delete credentials file from system
  rm -rf credentials.txt

  # Copy rules file into users home directory
  sudo cp rules.txt /home/$USERNAME/  
}

deleteUser()
{
  sudo userdel -r $USERNAME
  checkError $? "Failed to delete user $USERNAME"
  echo "$USERNAME has been deleted!"
}

if [ "$1" == "add" ]
then
  addUser
elif [ "$1" == "remove" ]
then
  deleteUser
else
  echo "You need to specify either [add] or [remove]"
fi
