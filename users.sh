#!/bin/bash

USERNAME=$2
PASSWORD=$3

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

  # This line is to set password for user that is passed in as second command line argument
  echo $USERNAME:$PASSWORD | sudo chpasswd

  # Send email to user
  mail -A ./credentials.txt -s "Here are your credentials" "$USERNAME@ourcooltechcompany.com" < /dev/null

  #Delete credentials file from system
  rm -rf credentials.txt

  # Copy rules file into users home directory
  sudo cp rules.txt /home/$USERNAME/

  # Send success message to person running script
  echo "Great Job!!! $USERNAME has been added to the system successfully"
}

deleteUser()
{
  sudo userdel -r $USERNAME
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
