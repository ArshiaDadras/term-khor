#!/bin/bash

# Script Name:   Term-Khor
# Description:   Automates course selection on Sharif University's course selection system.
# Author:        Arshia Dadras
# GitHub:        https://github.com/arshiadadras/
#
# Usage: ./select_course.sh -t <token> -c <course1,course2,...> -u <unit1,unit2,...> [-s <start_time>] [-e <end_time>]
#
# Options:
#   -t <token>       Your authentication token.
#   -i <student_id>  Your student ID for authentication.
#   -p <password>    Your password for authentication.
#   -c <courses>     Comma-separated list of course codes.
#   -u <units>       Comma-separated list of units corresponding to the courses.
#   -s <start_time>  Start time for the course selection in HH:MM format (default: 08:00).
#   -e <end_time>    End time for the course selection in HH:MM format (default: 00:00).
#
# Notes:
#   - The script requires GNU date and cURL to be installed.
#   - Ensure that the number of courses matches the number of units.
#   - The script will terminate gracefully if the user sends a SIGINT or SIGTERM signal (Ctrl+C).
#   - The script will attempt to register for the courses every 50 milliseconds. Adjust the sleep time as needed.
#   - The script will wait until the adjusted start time to begin course registration and will continue until the end time.

# Function to display usage information
usage() {
    echo "Usages:"
    echo "  $0 -t <token> -c <course1,course2,...> -u <unit1,unit2,...> [-s <start_time>] [-e <end_time>]"
    echo "  $0 -i <student_id> -p <password> -c <course1,course2,...> -u <unit1,unit2,...> [-s <start_time>] [-e <end_time>]"
    echo "Options:"
    echo "  -t <token>                  JWT token for authentication (required without: student_id)."
    echo "  -i <student_id>             Student ID for authentication (required without: token)."
    echo "  -p <password>               Password for authentication (required without: token)."
    echo "  -c <course1,course2,...>    Comma separated list of \`courseID-groupID\`s (required). Example: -c 40455-1,40103-2"
    echo "  -u <unit1,unit2,...>        Comma separated list of unit for each course (required). Example: -u 3,1"
    echo "  -s <start_time>             Start time of the course selection in the format of \`HH:MM\` (default: 08:00). Example: -s 08:00"
    echo "  -e <end_time>               End time of the course selection in the format of \`HH:MM\` (default: 00:00). Example: -e 10:00"
    exit 1
}

# Function to handle script termination and cleanup
cleanup() {
    echo -e "\033[0;33m`gdate +%H:%M:%S.%3N`: Cleaning up the script...\033[0m"
    wait
    pkill -P $$
    echo -e "\033[0;31m`gdate +%H:%M:%S.%3N`: Course selection script terminated.\033[0m"
    exit 1
}

# Trap signals and call cleanup function
trap cleanup SIGINT SIGTERM

# Parse command-line arguments
while getopts ":t:i:p:c:u:s:e:" opt; do
    case $opt in
        t) token=$OPTARG ;;
        i) student_id=$OPTARG ;;
        p) password=$OPTARG ;;
        c) courses=(${OPTARG//,/ }) ;;
        u) units=(${OPTARG//,/ }) ;;
        s) start_time=$OPTARG ;;
        e) end_time=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Validate required arguments
if [ -n "$student_id" ] && [ -n "$password" ]; then
    echo -e "\033[0;36m`gdate +%H:%M:%S.%3N`: Authenticating with the provided student ID and password...\033[0m"
    token=$(python3 token_finder/main.py $student_id $password 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo -e "\033[0;31mError: Failed to authenticate with the provided student ID and password\033[0m"
        exit 1
    fi
fi
if [ -z "$token" ] || [ -z "$courses" ] || [ ${#courses[@]} -ne ${#units[@]} ]; then
    echo -e "\033[0;31mError: Invalid arguments\033[0m"
    usage
fi

# Check if required tools are installed
if ! command -v gdate &> /dev/null; then
    echo -e "\033[0;33mError: GNU date is required to run this script\033[0m"
    exit 1
fi
if ! command -v curl &> /dev/null; then
    echo -e "\033[0;33mError: cURL is required to run this script\033[0m"
    exit 1
fi

# Set default values for optional arguments
start_time=${start_time:-08:00}
end_time=${end_time:-00:00}

# Display the provided arguments
echo -e "\033[0;36m`gdate +%H:%M:%S.%3N`: Course selection script started with the following arguments:\033[0m"
echo -e "\033[0;36m  - Token:       $token\033[0m"
echo -e "\033[0;36m  - Courses:     ${courses[@]}\033[0m"
echo -e "\033[0;36m  - Units:       ${units[@]}\033[0m"
echo -e "\033[0;36m  - Start Time:  $start_time\033[0m"
echo -e "\033[0;36m  - End Time:    $end_time\033[0m"

# Function to wait until the specified (adjusted) start time
wait_until_start() {
    if [ $(gdate +%H:%M) < $start_time ]; then
        start_timestamp=$(gdate -d "today $start_time" +%s)
    else
        start_timestamp=$(gdate -d "tomorrow $start_time" +%s)
    fi
    update_timestamp=$((start_timestamp-300))

    if [ -z "$student_id" ] || [ -z "$password" ] || [ $(gdate +%s) -ge $update_timestamp ]; then
        up_to_date=true
    else
        up_to_date=false
    fi

    while [ $(gdate -d "now + 1 second" +%H:%M) != $start_time ]; do
        echo -e "\033[0;90m`gdate +%H:%M:%S.%3N`: Waiting for the course selection to start at $start_time...\033[0m"

        if [ $up_to_date = false ] && [ $(gdate +%s) -ge $update_timestamp ]; then
            echo -e "\033[0;36m`gdate +%H:%M:%S.%3N`: Updating the login token...\033[0m"
            token=$(python3 token_finder/main.py $student_id $password 2>/dev/null)

            if [ $? -ne 0 ]; then
                echo -e "\033[0;31mError: Failed to authenticate with the provided student ID and password\033[0m"
                exit 1
            fi
            up_to_date=true
        fi

        sleep 1
    done
}

# Function to attempt courses registration
counter=0
attempt_registration() {
    current_counter=$counter
    echo -e "\033[0;35m`gdate +%H:%M:%S.%3N`: Attempt $current_counter to register for courses...\033[0m"

    for i in "${!courses[@]}"; do
        echo -e "\033[0;34m`gdate +%H:%M:%S.%3N`: Registering for course ${courses[i]} with ${units[i]} units on attempt $current_counter...\033[0m"

        curl --silent -o /dev/null --location --request POST "https://my.edu.sharif.edu/api/reg" \
             --header "Authorization: ${token}" \
             --header 'Content-Type: application/json' \
             --data-raw "{\"action\":\"add\",\"course\":\"${courses[i]}\",\"units\":${units[i]}}" &
    done

    wait
    echo -e "\033[0;32m`gdate +%H:%M:%S.%3N`: Registration attempt $current_counter completed.\033[0m"
}

# Main script execution
main() {
    echo -e "\033[0;36m`gdate +%H:%M:%S.%3N`: Course selection script started.\033[0m"
    wait_until_start

    while [ $(gdate +%H:%M) != $end_time ]; do
        counter=$((counter+1))
        attempt_registration &
        sleep 0.05
    done

    echo -e "\033[0;36m`gdate +%H:%M:%S.%3N`: Waiting for the last registration attempt to complete...\033[0m"
    while [ $(jobs -r) ]; do
        sleep 1
    done
    echo -e "\033[0;36m`gdate +%H:%M:%S.%3N`: Course selection script completed.\033[0m"
}

# Run the main function
main
