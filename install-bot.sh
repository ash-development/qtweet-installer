#!/bin/bash

set -e

####################################################################################
#                                                                                  #
# Project 'qtweet-installer'                                                       #
#                                                                                  #
# Copyright (C) 2021, Ash Schnoor, <ash@schnoor.email>                             #
#                                                                                  #
#   This program is free software: you can redistribute it and/or modify           #
#   it under the terms of the GNU General Public License as published by           #
#   the Free Software Foundation, either version 3 of the License, or              #
#   (at your option) any later version.                                            #
#                                                                                  #
#   This program is distributed in the hope that it will be useful,                #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of                 #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  #
#   GNU General Public License for more details.                                   #
#                                                                                  #
#   You should have received a copy of the GNU General Public License              #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.         #
#                                                                                  #
# https://github.com/ash-development/qtweet-installer/new/main/blob/master/LICENSE #
#                                                                                  #
# This script is not associated with the official QTweet Project.                  #
# https://github.com/ash-development/qtweet-installer/                             #
#                                                                                  #
####################################################################################

####### Visual functions ########

print_error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

print_warning() {
  COLOR_YELLOW='\033[1;33m'
  COLOR_NC='\033[0m'
  echo ""
  echo -e "* ${COLOR_YELLOW}WARNING${COLOR_NC}: $1"
  echo ""
}

print_brake() {
  for ((n=0;n<$1;n++));
    do
      echo -n "#"
    done
    echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

########## Variables ############

# Credentials for the database. 
export DB_NAME=qtweetData
export DB_USER=qtweetAdmin
export DB_PASSWORD=hunter2

export DISCORD_TOKEN=

export TWITTER_API_KEY=
export TWITTER_API_SECRET_KEY=
export TWITTER_ACCESS_TOKEN=
export TWITTER_ACCESS_TOKEN_SECRET=
## DBL Token is for Discord Bot List (now top.gg).
## You don't need to set this unless you want to put your bot on top.gg
export DBL_TOKEN=

export TIMEZONE=Europe/Paris
export DEFAULT_LANG=en

# Verbose mode allows me to get more information in case of bugs.
# set it to 1 and let the bot run before sending me your logs
export VERBOSE=0

# App stuff
export PREFIX=!!
export BOT_NAME=QTweet

## These variables set how fast the bot spawns shards. We avoid doing it too quickly.
## I don't recommend touching this, it won't affect you if your bot is in under 1000
## servers anyway.
export SHARD_SPAWN_DELAY=20000
export SHARD_SPAWN_TIMEOUT=120000

# The max amount we're willing to wait to reconnect to Twitter
# 0 means no maximum
export TWITTER_MAX_RECONNECT_DELAY=240000

# If we don't get a tweet in this many seconds, reconnect the stream
export TWEETS_TIMEOUT=3600

# These 2 variables are used for checking that twitter users in the DB are valid at boot
## How long to wait in seconds between two batches of users
export USERS_CHECK_TIMEOUT=1800
## How many users to check in one batch
export USERS_BATCH_SIZE=500
## Set to 1 to disable this check at boot
export DISABLE_SANITY_CHECK=0

# Disable streams completely.
# This is only meant for debugging purposes and will make QTweet non-functional to most users.
export DISABLE_STREAMS=0

##### User input functions ######

required_input() {
  local  __resultvar=$1
  local  result=''

  while [ -z "$result" ]; do
      echo -n "* ${2}"
      read -r result

      [ -z "$result" ] && print_error "${3}"
  done

  eval "$__resultvar="'$result'""
}

password_input() {
  local  __resultvar=$1
  local  result=''
  local default="$4"

  while [ -z "$result" ]; do
    echo -n "* ${2}"

    # modified from https://stackoverflow.com/a/22940001
    while IFS= read -r -s -n1 char; do
      [[ -z $char ]] && { printf '\n'; break; } # ENTER pressed; output \n and break.
      if [[ $char == $'\x7f' ]]; then # backspace was pressed
          # Only if variable is not empty
          if [ -n "$result" ]; then
            # Remove last char from output variable.
            [[ -n $result ]] && result=${result%?}
            # Erase '*' to the left.
            printf '\b \b' 
          fi
      else
        # Add typed char to output variable.
        result+=$char
        # Print '*' in its stead.
        printf '*'
      fi
    done
    [ -z "$result" ] && [ -n "$default" ] && result="$default"
    [ -z "$result" ] && print_error "${3}"
  done

  eval "$__resultvar="'$result'""
}

##### Main installation functions #####
git clone https://github.com/atomheartother/QTweet.git
cd QTweet
cp .example.env .env
