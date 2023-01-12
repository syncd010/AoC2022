#!/bin/sh

if [ -z "$1" ]
then
    echo "Please provide a day number"
    exit
fi

DAY="day$1"

if [ -f "./bin/day$1.dart" ]
then
    echo "Day $1 already exists"
else
    cp "./bin/day_template.dart" "./bin/day$1.dart"
    sed -i "s+data/input+data/input$1+" "./bin/day$1.dart"
    touch "./data/input$1"
    touch "./data/input$1Test"
    echo "Day $1 created"
fi
