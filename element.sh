#!/bin/bash

PSQL="psql -X --username=yellowflash2041 --dbname=periodic_table --tuples-only -c"

INPUT=$1

if [[ -z $INPUT ]]
then
  echo -e "Please provide an element as an argument."
else
  # find input (atomic number)
  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER_VAR=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1' OR name='$1'")
  else
    ATOMIC_NUMBER_INT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  fi

  # define ATOMIC_NUMBER
  if [[ -z $ATOMIC_NUMBER_VAR ]]
  then
    ATOMIC_NUMBER=$ATOMIC_NUMBER_INT
  else
    ATOMIC_NUMBER=$ATOMIC_NUMBER_VAR
  fi

  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
    # define necessary variables
    NAME=$($PSQL "select name from elements where atomic_number=$ATOMIC_NUMBER")
    SYMBOL=$($PSQL "select symbol from elements where atomic_number=$ATOMIC_NUMBER")
    TYPE=$($PSQL "select type from types join properties on types.type_id=properties.type_id where atomic_number=$ATOMIC_NUMBER")
    ATOMIC_MASS=$($PSQL "select atomic_mass from properties where atomic_number=$ATOMIC_NUMBER")
    MELTING_PT=$($PSQL "select melting_point_celsius from properties where atomic_number=$ATOMIC_NUMBER")
    BOILING_PT=$($PSQL "select boiling_point_celsius from properties where atomic_number=$ATOMIC_NUMBER")

    # format necessary variables (get rid of leading spaces)
    ATOMIC_NUMBER_FORMAT=$(echo $ATOMIC_NUMBER | sed 's/ //g')
    NAME_FORMAT=$(echo $NAME | sed 's/ //g')
    SYMBOL_FORMAT=$(echo $SYMBOL | sed 's/ //g')
    TYPE_FORMAT=$(echo $TYPE | sed 's/ //g')
    ATOMIC_MASS_FORMAT=$(echo $ATOMIC_MASS | sed 's/ //g')
    MELTING_PT_FORMAT=$(echo $MELTING_PT | sed 's/ //g')
    BOILING_PT_FORMAT=$(echo $BOILING_PT | sed 's/ //g')

    # print message
    echo "The element with atomic number $ATOMIC_NUMBER_FORMAT is $NAME_FORMAT ($SYMBOL_FORMAT). It's a $TYPE_FORMAT, with a mass of $ATOMIC_MASS_FORMAT amu. $NAME_FORMAT has a melting point of $MELTING_PT_FORMAT celsius and a boiling point of $BOILING_PT_FORMAT celsius."
  fi
fi