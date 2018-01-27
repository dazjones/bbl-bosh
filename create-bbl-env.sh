GCP_PROJECT=${GCP_PROJECT}
BBL_ENVIRONMENT=bbl-${GCP_PROJECT}
BASE_PATH=$(pwd)
BBL_STATE_PATH=${BASE_PATH}/${BBL_ENVIRONMENT}
SERVICE_ACCOUNT="bbl-service-account-user"
SERVICE_ACCOUNT_KEY_FILE="${BBL_STATE_PATH}/${SERVICE_ACCOUNT}.key.json"

export BBL_IAAS=gcp
export BBL_ENV_NAME=${BBL_ENVIRONMENT}
export BBL_GCP_REGION=${GCP_REGION}

if [ ! -d ${BBL_STATE_PATH} ]
then
    mkdir -p ${BBL_STATE_PATH}
fi

export BBL_GCP_SERVICE_ACCOUNT_KEY=$(cat ${SERVICE_ACCOUNT_KEY_FILE})

bbl plan -s ${BBL_STATE_PATH} $*

# Remove director external IP and set director tags
ENV_ID=$(grep env_id "${BBL_STATE_PATH}/vars/terraform.tfvars" | sed 's/^env_id="\(.*\)"$/\1/g')
sed -i "s/^.*bosh-director-ephemeral-ip-ops.*$/  -v  tags=[${ENV_ID}-bosh-director,no-ip]/g" "${BBL_STATE_PATH}/create-director.sh"
sed -i "s/^.*bosh-director-ephemeral-ip-ops.*$/  -v  tags=[${ENV_ID}-bosh-director,no-ip]/g" "${BBL_STATE_PATH}/delete-director.sh"

bbl up -s ${BBL_STATE_PATH} $*
