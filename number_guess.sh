#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number
SECRET=$((1 + $RANDOM%1000))

# ask for username
echo "Enter your username:"
read USERNAME

# query database
IFS='|' read PLAYED BEST <<< $($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")

# welcome message depending on match
if [[ -n $PLAYED ]]
then
  echo "Welcome back, $USERNAME! You have played $PLAYED games, and your best game took $BEST guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

# initialise guess and tries count
GUESS=0
TRIES=0

# first guess message
echo -e "Guess the secret number between 1 and 1000:"

# while guess not equal to secret number
while [[ $GUESS != $SECRET ]]
do
  # increase tries count
  ((TRIES++))
  # read input
  read GUESS

  # if not integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -gt $SECRET ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
    fi
  fi

done

# update database
if [[ -n $PLAYED ]]
then
  # existing user - update row
  NEW_PLAYED=$(($PLAYED+1))
  NEW_BEST=$BEST; if [[ $TRIES -lt $BEST ]]; then NEW_BEST=$TRIES; fi
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_PLAYED, best_game=$NEW_BEST WHERE username='$USERNAME';")
else
  # new user - insert row
  INSERT_RESULT=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 1, $TRIES);")
fi
