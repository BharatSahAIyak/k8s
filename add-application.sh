#!/bin/bash

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
      read -p "An application with the name ${1} already exists. Do you want to proceed? (yes/no): " choice
      case "$choice" in
        yes) return 0;;
        no) echo "Aborting."; exit 1;;
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
      awk -v app="  - ../../base/${application}" '/resources:/ {print; print app; next}1' \
        kustomize/overlays/${env}/kustomization.yaml > kustomize/overlays/${env}/kustomization.yaml.tmp \
        && mv kustomize/overlays/${env}/kustomization.yaml.tmp kustomize/overlays/${env}/kustomization.yaml
      echo "Updated kustomize/overlays/${env}/kustomization.yaml"
    else
      echo "Environment ${env} does not exist in the overlays directory."
    fi
  done
}

# Function to create a new application
create_application() {
  while true; do
    # Prompt the user for inputs
    prompt_input "Please enter your application name: " validate_application_name APPLICATION
    check_existing_application "$APPLICATION"
    prompt_input "Enter the TARGET_PORT: " validate_number TARGET_PORT
    read -p "Enter the IMAGE_URL: " IMAGE_URL
    prompt_input "Enter the number of REPLICAS: " validate_number REPLICAS

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

    echo "Kubernetes manifest file created at kustomize/base/${APPLICATION}/${APPLICATION}.yaml"
    echo "kustomization.yaml file created at kustomize/base/${APPLICATION}/kustomization.yaml"

    read -p "Do you want to add another application? (yes/no): " continue_choice
    if [[ "$continue_choice" != "yes" ]]; then
      echo "Aborting."
      break
    fi
  done
}

# Function to add an existing application to specific environments
add_existing_application() {
  while true; do
    prompt_input "Please enter your application name: " validate_application_name APPLICATION

    # Check if the application YAML file exists
    if [[ ! -f "kustomize/base/${APPLICATION}/${APPLICATION}.yaml" ]]; then
      echo "The application ${APPLICATION} does not exist. Aborting."
      exit 1
    fi

    while true; do
      read -p "Please enter the environment names (separated by space) in which you want to add the application: " ENVIRONMENTS

      # Update the overlay kustomization.yaml files
      update_overlay_kustomization "$APPLICATION" "$ENVIRONMENTS"

      read -p "Do you want to add the application to other environments? (yes/no): " continue_env
      if [[ "$continue_env" != "yes" ]]; then
        break
      fi
    done

    read -p "Do you want to add another application? (yes/no): " continue_choice
    if [[ "$continue_choice" != "yes" ]]; then
      echo "Aborting."
      break
    fi
  done
}

# Main menu
while true; do
  echo "Please select the action you want to do:"
  echo "1. Create an application"
  echo "2. Add an existing application"
  echo "3. Abort"
  read -p "Enter your choice (1, 2, or 3): " choice

  case "$choice" in
    1) create_application;;
    2) add_existing_application;;
    3) echo "Aborting."; exit 0;;
    *) echo "Invalid choice. Please enter 1, 2, or 3.";;
  esac
done
