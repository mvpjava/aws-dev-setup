#!/bin/bash -e

instance_id=i-081a9a0d3eea5d3f9
echo "Starting EC2 Instance ..."

# Function to display usage information
usage() {
    echo "Usage: $0 -i <instance-id>"
    echo "  -i <instance-id>: Specify the EC2 instance ID to start. Must match regex '^i-[0-9a-f]{17}$'"
    exit 1
}

# Parse command-line arguments
while getopts ":i:" opt; do
    case $opt in
        i)
            INSTANCE_ID="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done

# Check if the instance ID is provided
if [ -z "$INSTANCE_ID" ]; then
    echo "Error: EC2 instance ID is required."
    usage
fi

# Validate instance ID format
if [[ ! "$INSTANCE_ID" =~ ^i-[0-9a-f]{17}$ ]]; then
    echo "Error: Invalid EC2 instance ID format."
    echo "Instance ID must match the pattern '^i-[0-9a-f]{17}$'."
    exit 1
fi

# Start the EC2 instance
OUTPUT=$(aws ec2 start-instances --instance-ids "$INSTANCE_ID" 2>&1)
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "Error: Failed to start EC2 instance."
    echo "$OUTPUT"
    exit 1
else
    echo "Success: EC2 instance '$INSTANCE_ID' has been started."
fi


echo "Waiting for running state..."
OUTPUT=$(aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" 2>&1)
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "Error: Unable to start waiting for EC2 instance."
    echo "$OUTPUT"
    exit 1
else
    echo "Success: EC2 instance '$INSTANCE_ID' in running state."
fi
