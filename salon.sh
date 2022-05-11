#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

SERVICE_SELECTION() {
  echo -e "\n$1"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo -e "$SERVICE_ID) $SERVICE"
  done

  APPOINTMENT_SCHEDULER
}

APPOINTMENT_SCHEDULER() {
  #get service selection
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #return to main menu
    SERVICE_SELECTION "I could not find that service. What would you like today?"
    return
  fi

  #if selection is not a service
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    #return to main menu
    SERVICE_SELECTION "I could not find that service. What would you like today?"
    return
  fi

  #get phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  #get customers name from database
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #if customers name does not exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    #insert customer into database
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  #get customers id from database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #get appointment time from customer
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME

  #insert appointment into database
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  #inform customer of appointment 
  if [[ $INSERT_APPOINTMENT = 'INSERT 0 1' ]]
  then
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}
SERVICE_SELECTION "Welcome to My Salon, how can I help you?"
