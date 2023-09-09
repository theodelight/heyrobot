#!/bin/bash

# Define the Flask server URL
URL="http://127.0.0.1:5000/go"

# Function to print usage
usage() {
    echo "Usage: $0 <part> <action> <duration>"
    echo "Examples:"
    echo "  $0 grip open 1"
    echo "  $0 wrist up 2"
    echo "  $0 elbow down 3"
    echo "  $0 shoulder up 1"
    echo "  $0 base clockwise 2"
    echo "  $0 led on 3"
    exit 1
}

# Function to send go to Flask server
send_go() {
    curl -s -X POST -H "Content-Type: application/json" -d "{\"go\":$1}" $URL
}

# Validate the number of parameters
if [ $# -lt 2 ]; then
    usage
fi

# Parse the parameters
PART="$1"
ACTION="$2"
DURATION="$3"

# Convert part and action into the correct go
case "$PART $ACTION" in
    "grip open")      CMD="[\"02\", \"00\", \"00\"]" ;;
    "grip close")     CMD="[\"01\", \"00\", \"00\"]" ;;
    "wrist up")       CMD="[\"04\", \"00\", \"00\"]" ;;
    "wrist down")     CMD="[\"08\", \"00\", \"00\"]" ;;
    "elbow up")       CMD="[\"10\", \"00\", \"00\"]" ;;
    "elbow down")     CMD="[\"20\", \"00\", \"00\"]" ;;
    "shoulder up")    CMD="[\"40\", \"00\", \"00\"]" ;;
    "shoulder down")  CMD="[\"80\", \"00\", \"00\"]" ;;
    "base clockwise") CMD="[\"00\", \"01\", \"00\"]" ;;
    "base counter-clockwise") CMD="[\"00\", \"02\", \"00\"]" ;;
    "led on")         CMD="[\"00\", \"00\", \"01\"]" ;;
    *)
        usage
        ;;
esac

# Send the go
send_go "$CMD"

# Sleep for the specified duration
sleep "$DURATION"

# Send the stop go
STOP_CMD="[\"00\", \"00\", \"00\"]"
send_go "$STOP_CMD"

