#!/bin/bash

PSQL="psql -U freecodecamp -d salon -q -t -A -c"

while true
do
  printf '\nWelcome to My Salon!\n\n'
  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id"

  printf '\nWhich service would you like?\n'
  read SERVICE_ID_SELECTED || exit 0

  if [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]
  then
    printf '\nPlease select a valid service.\n'
    continue
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z "$SERVICE_NAME" ]]
  then
    printf '\nPlease select a valid service.\n'
    continue
  fi

  break
done

printf '\nWhat is your phone number?\n'
read CUSTOMER_PHONE || exit 0

PHONE_SQL=${CUSTOMER_PHONE//\'/\'\'}

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$PHONE_SQL'")

if [[ -z "$CUSTOMER_ID" ]]
then
  printf '\nWhat is your name?\n'
  read CUSTOMER_NAME || exit 0

  NAME_SQL=${CUSTOMER_NAME//\'/\'\'}

  CUSTOMER_ID=$($PSQL "INSERT INTO customers(phone, name) VALUES('$PHONE_SQL', '$NAME_SQL') RETURNING customer_id")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

printf '\nWhat time would you like your appointment?\n'
read SERVICE_TIME || exit 0

TIME_SQL=${SERVICE_TIME//\'/\'\'}

$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$TIME_SQL')" > /dev/null

printf '\nI have put you down for a %s at %s, %s.\n' "$SERVICE_NAME" "$SERVICE_TIME" "$CUSTOMER_NAME"
