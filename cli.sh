#!/bin/bash

# Prompt messages
PROMPT_APP_NAME="Please enter your application name: "
PROMPT_TARGET_PORT="Enter the TARGET_PORT: "
PROMPT_IMAGE_URL="Enter the IMAGE_URL: "
PROMPT_REPLICAS="Enter the number of REPLICAS: "
PROMPT_ENVIRONMENTS="Please enter the environment names (separated by space) in which you want to add the application: "
PROMPT_CONTINUE_ONBOARD="Do you want to onboard another application? (yes/no): "
PROMPT_CONTINUE_ENV="Do you want to add ${APPLICATION} application to any other environment? (yes/no): "
PROMPT_ADD_ANOTHER="Do you want to add another existing application to an environment? (yes/no): "
PROMPT_PROCEED="An application with the name ${APPLICATION} already exists. Do you want to proceed? (yes/no): "
OUTPUT_RETURN_MAIN_MENU=$'\nReturning to the main menu'

# Function to validate the APPLICATION name
validate_application_name() {
  if [[ ! "$1" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]]; then
    echo "Invalid APPLICATION name. It must contain only lowercase letters, numbers, and dashes, and must start and end with a lowercase letter or number."
    return 1
  else
    return 0
  fi
}

# Function to validate that the input is a number
validate_number() {
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. It must be a number."
    return 1
  else
    return 0
  fi
}

# Function to prompt the user for input and validate it
prompt_input() {
  local prompt_message=$1
  local validation_function=$2
  local input_variable=$3
  local input_value

  while true; do
    read -p "$prompt_message" input_value
    if $validation_function "$input_value"; then
      eval "$input_variable='$input_value'"
      break
    else
      echo "Invalid input. Please try again or press Ctrl+C to exit."
    fi
  done
}

# Function to check if the application already exists
check_existing_application() {
  if [[ -f "kustomize/base/${1}/${1}.yaml" ]]; then
    while true; do
      read -p "$PROMPT_PROCEED" choice
      case "$choice" in
        yes) return 0;;
        no) return 1;;  # Return 1 to indicate not to proceed
        *) echo "Please answer yes or no.";;
      esac
    done
  fi
}

# Function to update the kustomization.yaml files in the overlay directories
update_overlay_kustomization() {
  local application=$1
  local environments=$2
  for env in $environments; do
    if [[ -d "kustomize/overlays/${env}" ]]; then
      local overlay_file="kustomize/overlays/${env}/kustomization.yaml"
      local app_entry="  - ../../base/${application}"

      if grep -q "$app_entry" "$overlay_file"; then
        echo "The application ${application} is already present in ${overlay_file}."
      else
        awk -v app="$app_entry" '/resources:/ {print; print app; next}1' "$overlay_file" > "${overlay_file}.tmp" \
          && mv "${overlay_file}.tmp" "$overlay_file"
        echo "Added ${application} to ${overlay_file}."
      fi
    else
      echo "Environment ${env} does not exist in the kustomize/overlays directory."
    fi
  done
}

# Function to create a new application
create_application() {
  while true; do
    # Prompt the user for inputs
    prompt_input "$PROMPT_APP_NAME" validate_application_name APPLICATION
    if ! check_existing_application "$APPLICATION"; then
      echo $OUTPUT_RETURN_MAIN_MENU
      return
    fi
    prompt_input "$PROMPT_TARGET_PORT" validate_number TARGET_PORT
    read -p "$PROMPT_IMAGE_URL" IMAGE_URL
    prompt_input "$PROMPT_REPLICAS" validate_number REPLICAS

    # Create the application folder
    mkdir -p kustomize/base/${APPLICATION}

    # Replace placeholders in the manifest template and create the Kubernetes manifest
    sed -e "s|{{APPLICATION}}|${APPLICATION}|g" \
        -e "s|{{TARGET_PORT}}|${TARGET_PORT}|g" \
        -e "s|{{IMAGE_URL}}|${IMAGE_URL}|g" \
        -e "s|{{REPLICAS}}|${REPLICAS}|g" \
        kustomize/template/application.yaml > kustomize/base/${APPLICATION}/${APPLICATION}.yaml

    # Create the kustomization.yaml file
    cat <<EOF > kustomize/base/${APPLICATION}/kustomization.yaml
resources:
  - ${APPLICATION}.yaml
EOF

    echo "${APPLICATION}.yaml file created at kustomize/base/${APPLICATION}/${APPLICATION}.yaml"
    echo "kustomization.yaml file created at kustomize/base/${APPLICATION}/kustomization.yaml"

    read -p "$PROMPT_CONTINUE_ONBOARD" continue_choice
    if [[ "$continue_choice" != "yes" ]]; then
      echo "${OUTPUT_RETURN_MAIN_MENU}"
      return
    fi
  done
}

# Function to add an existing application to specific environments
add_existing_application() {
  while true; do
    prompt_input "$PROMPT_APP_NAME" validate_application_name APPLICATION

    # Check if the application YAML file exists
    if [[ ! -f "kustomize/base/${APPLICATION}/${APPLICATION}.yaml" ]]; then
      echo "The application ${APPLICATION} does not exist."
      printf "\n"  # Add a blank line for better readability
    else
      while true; do
        read -p "$PROMPT_ENVIRONMENTS" ENVIRONMENTS

        # Update the overlay kustomization.yaml files
        update_overlay_kustomization "$APPLICATION" "$ENVIRONMENTS"

        read -p "$PROMPT_CONTINUE_ENV" continue_env
        if [[ "$continue_env" != "yes" ]]; then
          break
        fi
      done
    fi

    read -p "$PROMPT_ADD_ANOTHER" continue_choice
    if [[ "$continue_choice" != "yes" ]]; then
      echo "${OUTPUT_RETURN_MAIN_MENU}"
      return
    fi
  done
}

# Main menu
while true; do
  echo
  echo "Please select the action you want to do:"
  echo "1. Onboard an application"
  echo "2. Add an existing application to an environment"
  echo "3. Abort"
  echo
  read -p "Enter your choice (1, 2, or 3): " choice

  case "$choice" in
    1) create_application;;
    2) add_existing_application;;
    3) echo "Aborting."; exit 0;;
    *) echo "Invalid choice. Please enter 1, 2, or 3.";;
  esac
done
