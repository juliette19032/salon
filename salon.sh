#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "Welcome to My Salon, how can I help you?" 
  #display services
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read ID BAR SERVICE
  do
    echo "$ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  
  # check if service is correct 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
  then
    # send to main menu
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
    #get name of service
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *|//')
    BOOK_SERVICE
  fi
}
BOOK_SERVICE() {
  #ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  #if phone does not exist, "I don't have a record for that phone number, what's your name?""
  # if customer doesn't exist
  if [[ -z $PHONE ]]
  then
    # get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')") 
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  #CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *|//')
  # What time would you like your cut, Fabio?
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME?"
  read SERVICE_TIME
  #I have put you down for a cut at 10:30, Fabio.
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
  INSERT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
  if [[ $INSERT_TIME == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *|//'g)."
  fi
}
MAIN_MENU


