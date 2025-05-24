#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Main Menu
MAIN_MENU() {
  echo -e "Welcome to My Salon, how can I help you?\n"

  # Lista servizi
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  # Verifica se il servizio esiste
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  SERVICE_NAME=$(echo "$SERVICE_NAME" | xargs)

  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. What would you like today?\n"
    MAIN_MENU
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Verifica se esiste il cliente
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | xargs)

    # Se il cliente non esiste, chiedi nome
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | xargs)
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi

    # Prendi customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Inserisci appuntamento
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

    # Conferma
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
