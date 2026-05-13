#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~ Salon Appointment Scheduler ~~~~\n"
SCHEDULE_MENU() {
  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # display services
  echo -e "\nSo you're interested in my salon. Pick one of the following services we have available:"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  # ask which service they'd like
  echo -e "\nWhich service would you like to schedule?"
  read SERVICE_ID_SELECTED
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-3]+$ ]]
  then
    # send to main menu
    echo -e "\nThat is not a valid service number." 
    SCHEDULE_MENU
  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
    fi
    # get appointment time 
    while true
    do
      echo -e "\nWhat time would you like your service to be, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME
      if [[ $SERVICE_TIME =~ ^([0-9]|1[0-9]|2[0-4])(:[0-5][0-9])?([aApP][mM])?$ ]]
      then
        break
      else
        echo -e "\nThat is not a valid time."
      fi
    done
    # insert new customer
    if [[ -z $($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'") ]]
    then
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    fi
    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # insert new appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');")
    # get bike info
    APPOINTMENT_INFO=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    APPOINTMENT_INFO_FORMATTED=$(echo $APPOINTMENT_INFO | sed 's/ |/"/')
    # send to main menu
    echo -e "\nI have put you down for a $APPOINTMENT_INFO_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    EXIT_MENU
  fi
}


EXIT_MENU() {
  echo -e "\nSee you then!\n"
}

SCHEDULE_MENU
