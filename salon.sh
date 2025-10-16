#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ My Salon ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi  
  echo -e "\nWelome to my salon. How may i help you?\n"

  # Display list of services
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")

  # Display services
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Prompt for input
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # If not valid, show the list again
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "\nInvalid option. Please choose again."
  else
    # Get customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'") 

  # If not found, get customer info
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWe don't have any record of that number. Please enter your name."
    read CUSTOMER_NAME
    CUSTOMER_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Get time from customer
  echo -e "\nAt what time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Insert customer appointment
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirm appointment message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  fi   
} 
MAIN_MENU
