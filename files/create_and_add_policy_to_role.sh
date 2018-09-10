#!/bin/bash
# run this from ansible provisioning host (local

# creates policy if policy name doesn't exist yet, then attach to role
# - role must already exist
# - policy name is the document filename without extension
# - assumes the extension of policy document filename is .json

ERROR_MISSING_ROLE=20
ERROR_CREATING_POLICY=21
ERROR_ATTACHING_POLICY_TO_ROLE=23

AWS_PROFILE=$1
ROLE_NAME=$2
DOCUMENT_PATH=$3
IAM_PATH=${4:-/hx/}

if [ $# -lt 3 ]
then
    echo "$0 <aws_profile> <policy_document_fullpath> <role_name> <iam_path>"
    exit $ERROR_MISSING_ARGUMENTS
fi

echo "aws_profile is $AWS_PROFILE"
echo "document_path is $DOCUMENT_PATH"
echo "role name is $ROLE_NAME"
echo "iam path is $IAM_PATH"

# name the policy after the document file
POLICY_NAME=$(basename "$DOCUMENT_PATH" .json)
echo "policy name is $POLICY_NAME"


# role must exist
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" \
    | jq '.Role.Arn' | sed 's/"//g')
if [ -z "$ROLE_ARN" ]; then
    echo "missing role $ROLE_NAME"
    exit $ERROR_MISSING_ROLE
fi
echo "role arn is $ROLE_ARN"

# check if managed policy already exists
POLICY_ARN=$(aws iam list-policies --scope Local \
    | jq ".Policies[] | select(.PolicyName == \"$POLICY_NAME\") | .Arn" \
    | sed 's/"//g')
if [ -z "$POLICY_ARN" ]; then
    # create managed policy
    POLICY_ARN=$(aws iam create-policy \
        --policy-name "${POLICY_NAME}" \
        --path "${IAM_PATH}" \
        --description "created by $0 on $(date)" \
        --policy-document "file://${DOCUMENT_PATH}" \
        --profile "${AWS_PROFILE}" \
        | jq '.Policy.Arn' \
        | sed 's/"//g')
    if [ $? -ne 0 ]; then
        exit $ERROR_CREATING_POLICY
    fi
fi
echo "policy arn is $POLICY_ARN"

# add managed policy to role
aws iam attach-role-policy \
    --role-name "${ROLE_NAME}" \
    --policy-arn "${POLICY_ARN}" \
    --profile "${AWS_PROFILE}"
if [ $? -ne 0 ]; then
    exit $ERROR_ATTACHING_POLICY_TO_ROLE
fi

echo "${POLICY_ARN}"

