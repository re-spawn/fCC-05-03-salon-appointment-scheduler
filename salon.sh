#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo "~~~ Salon Appointment Scheduler ~~~"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "$1"
  fi
  echo Choose service from menu:
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ [0-9]+ ]]
  then
    MAIN_MENU
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU
    else
      echo What is your phone number?
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo What is your name?
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESPONSE=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      while [[ -z $SERVICE_TIME ]]
      do
        echo What time do you want your appointment?
        read SERVICE_TIME
      done
      INSERT_APPOINTMENT_RESPONSE=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
      echo I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.
    fi
  fi
}
MAIN_MENU

