#!/bin/bash

# Prompt messages
PROMPT_APP_NAME="Please enter your application name: "
PROMPT_TARGET_PORT=$'\nEnter the TARGET_PORT: '
PROMPT_IMAGE_URL="Enter the IMAGE_URL: "
PROMPT_REPLICAS="Enter the number of REPLICAS: "
PROMPT_MEMORY_REQUEST="Enter the MEMORY_REQUEST (e.g., 64Mi): "
PROMPT_MEMORY_LIMIT="Enter the MEMORY_LIMIT (e.g., 128Mi): "
PROMPT_ENVIRONMENTS="Please enter the environment names (separated by space) in which you want to add the application: "
PROMPT_CONTINUE_ONBOARD="Do you want to onboard another application? (yes/no): "
PROMPT_CONTINUE_ENV="Do you want to add the application named {APPLICATION} to any other environment? (yes/no): "
PROMPT_ADD_ANOTHER="Do you want to add another existing application to an environment? (yes/no): "
PROMPT_PROCEED="An application with the name {APPLICATION} already exists. Do you want to proceed? (yes/no): "
PROMPT_APP_NOT_EXIST="The application {APPLICATION} does not exist."
PROMPT_ADD_INGRESS="Do you want to add Ingress for the application named {APPLICATION}? (yes/no): "
PROMPT_ADD_SECRET="Do you want to add secrets for the application named {APPLICATION}? (yes/no): "
PROMPT_GPU_REQUEST="Does the application require GPUs? (yes/no): "
PROMPT_GPU_LIMIT="Enter the GPU_LIMIT (e.g., 1, 2, etc.): "
PROMPT_BUILD_IMAGE="Do you want to build the image for application {APPLICATION} on Kubernetes? (yes/no): "
PROMPT_CONTEXT="What is the context value? "
PROMPT_DESTINATION="What is the destination? "
INVALID_INPUT="Invalid input. Please enter 'yes' or 'no' only."
INVALID_MEMORY="Invalid input. Memory value must be in the format of '64Mi' or '128Gi'."
INVALID_NUMBER="Invalid input. It must be a number."
INVALID_APPLICATION_NAME=$'\nInvalid APPLICATION name. It must contain only lowercase letters, numbers, and dashes, and must start and end with a lowercase letter or number.\n'
OUTPUT_RETURN_MAIN_MENU=$'\nReturning to the main menu'
OUTPUT_INVALID_INPUT="Invalid input. Returning to the main menu."

# Function to validate the APPLICATION name
validate_application_name() {
  if [[ ! "$1" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]]; then
    echo "$INVALID_APPLICATION_NAME"
    return 1
  else
    return 0
  fi
}

# Function to validate that the input is a number
validate_number() {
  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "$INVALID_NUMBER"
    return 1
  else
    return 0
  fi
}

# Function to validate MEMORY_REQUEST and MEMORY_LIMIT
validate_memory() {
  if [[ "$1" =~ ^[0-9]+(Mi|Gi|Ei|Pi|Ti|Ki|E|P|T|G|M|k)$ ]]; then
    return 0
  else
    printf "\n"
    echo "$INVALID_MEMORY"
    printf "\n"
    return 1
  fi
}

# Function to validate yes/no input
validate_yes_no() {
  if [[ "$1" =~ ^(yes|no)$ ]]; then
    return 0
  else
    printf "\n"
    echo "$INVALID_INPUT"
    return 1
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
      echo $'\nInvalid input. Please try again or press Ctrl+C to exit.\n'
    fi
  done
}

# Function to handle invalid input and return to the main menu
handle_invalid_input() {
  echo "$OUTPUT_INVALID_INPUT"
  echo "$OUTPUT_RETURN_MAIN_MENU"
  return
}

# Function to check if the application already exists
check_existing_application() {
  if [[ -f "kustomize/base/${1}/${1}.yaml" ]]; then
    while true; do
      printf "\n"
      read -p "$(echo "$PROMPT_PROCEED" | sed "s/{APPLICATION}/$1/")" choice
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
      echo "$OUTPUT_RETURN_MAIN_MENU"
      return
    fi
    prompt_input "$PROMPT_TARGET_PORT" validate_number TARGET_PORT
    read -p "$PROMPT_IMAGE_URL" IMAGE_URL
    prompt_input "$PROMPT_REPLICAS" validate_number REPLICAS

    # Prompt for MEMORY_REQUEST with validation
    while true; do
      read -p "$PROMPT_MEMORY_REQUEST" MEMORY_REQUEST
      if validate_memory "$MEMORY_REQUEST"; then
        break
      fi
    done

    # Prompt for MEMORY_LIMIT with validation
    while true; do
      read -p "$PROMPT_MEMORY_LIMIT" MEMORY_LIMIT
      if validate_memory "$MEMORY_LIMIT"; then
        break
      fi
    done

    # Prompt for GPU request
    while true; do
      read -p "$PROMPT_GPU_REQUEST" GPU_REQUEST
      if validate_yes_no "$GPU_REQUEST"; then
        break
      fi
    done

    # Prompt for GPU limit if required
    if [[ "$GPU_REQUEST" == "yes" ]]; then
      prompt_input "$PROMPT_GPU_LIMIT" validate_number GPU_LIMIT
    else
      GPU_LIMIT=""
    fi

    # Prompt for including Ingress and secrets
    while true; do
      read -p "$(echo "$PROMPT_ADD_INGRESS" | sed "s/{APPLICATION}/$APPLICATION/")" ADD_INGRESS
      if validate_yes_no "$ADD_INGRESS"; then
        break
      fi
    done

    while true; do
      read -p "$(echo "$PROMPT_ADD_SECRET" | sed "s/{APPLICATION}/$APPLICATION/")" ADD_SECRET
      if validate_yes_no "$ADD_SECRET"; then
        break
      fi
    done

    # Prompt for image build option.
    while true; do
      read -p "$(echo "$PROMPT_BUILD_IMAGE" | sed "s/{APPLICATION}/$APPLICATION/")" BUILD_IMAGE
      if [[ "$BUILD_IMAGE" == "yes" || "$BUILD_IMAGE" == "no" ]]; then
        break
      else
        echo "$INVALID_INPUT"
      fi
    done


    # Create the application folder
    mkdir -p kustomize/base/${APPLICATION}

    # Create the Kubernetes manifest based on user choices
    {
      # Add Deployment section
      cat kustomize/template/Deployment.yaml | sed -e "s|{{APPLICATION}}|${APPLICATION}|g" \
        -e "s|{{TARGET_PORT}}|${TARGET_PORT}|g" \
        -e "s|{{IMAGE_URL}}|${IMAGE_URL}|g" \
        -e "s|{{REPLICAS}}|${REPLICAS}|g" \
        -e "s|{{MEMORY_REQUEST}}|${MEMORY_REQUEST}|g" \
        -e "s|{{MEMORY_LIMIT}}|${MEMORY_LIMIT}|g"
      
  # Append GPU limits if requested
      if [[ "$GPU_REQUEST" == "yes" ]]; then
        printf "\n"
        printf '              nvidia.com/gpu: "%s"' "$GPU_LIMIT"
      fi

      # Always add separator after Deployment section
      echo $'\n---'

      # Add Service section
      cat kustomize/template/Service.yaml | sed -e "s|{{APPLICATION}}|${APPLICATION}|g" \
        -e "s|{{TARGET_PORT}}|${TARGET_PORT}|g"
      
      # Add separator if Ingress or Secret are included
      if [[ "$ADD_SECRET" == "yes" || "$ADD_INGRESS" == "yes" ]]; then
        echo $'\n---'
      fi

      # Add VaultStaticSecret section if required
      if [[ "$ADD_SECRET" == "yes" ]]; then
        cat kustomize/template/VaultStaticSecret.yaml | sed "s|{{APPLICATION}}|${APPLICATION}|g"
        
        # Add separator if Ingress is included
        if [[ "$ADD_INGRESS" == "yes" ]]; then
          echo $'\n---'
        fi
      fi

      # Add Ingress section if required
      if [[ "$ADD_INGRESS" == "yes" ]]; then
        cat kustomize/template/Ingress.yaml | sed "s|{{APPLICATION}}|${APPLICATION}|g"
        # No separator needed after the last section
      fi

      # Add separator if Pod section is included
        if [[ "$BUILD_IMAGE" == "yes" ]]; then
          echo $'\n---'
      fi

      # Add Pod section if required
      if [[ "$BUILD_IMAGE" == "yes" ]]; then
        cat kustomize/template/Pod.yaml | sed -e "s|{{APPLICATION}}|${APPLICATION}|g"
      fi

    } > kustomize/base/${APPLICATION}/${APPLICATION}.yaml

    # Create the kustomization.yaml file
    cat <<EOF > kustomize/base/${APPLICATION}/kustomization.yaml
resources:
  - ${APPLICATION}.yaml
EOF

    echo "${APPLICATION}.yaml file created at kustomize/base/${APPLICATION}/${APPLICATION}.yaml"
    echo "kustomization.yaml file created at kustomize/base/${APPLICATION}/kustomization.yaml"

    printf "\n"
    read -p "$PROMPT_CONTINUE_ONBOARD" continue_choice
    if [[ "$continue_choice" != "yes" && "$continue_choice" != "no" ]]; then
      handle_invalid_input
      return
    elif [[ "$continue_choice" == "no" ]]; then
      echo "$OUTPUT_RETURN_MAIN_MENU"
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
      echo "$(echo "$PROMPT_APP_NOT_EXIST" | sed "s/{APPLICATION}/$APPLICATION/")"
      echo "$OUTPUT_RETURN_MAIN_MENU"
      return
    fi

    prompt_input "$PROMPT_ENVIRONMENTS" validate_application_name ENVIRONMENTS

    # Update kustomization.yaml files in the overlay directories
    update_overlay_kustomization "$APPLICATION" "$ENVIRONMENTS"

    echo "$APPLICATION has been added to the specified environments."

    read -p "$PROMPT_CONTINUE_ENV" continue_choice
    if [[ "$continue_choice" != "yes" && "$continue_choice" != "no" ]]; then
      handle_invalid_input
      return
    elif [[ "$continue_choice" == "no" ]]; then
      echo "$OUTPUT_RETURN_MAIN_MENU"
      return
    fi
  done
}

# Main script loop
while true; do
  echo "Main Menu"
  echo "1. Onboard a new application"
  echo "2. Add an existing application to an environment"
  echo "3. Abort"

  read -p "Please select an option (1, 2, or 3): " option

  case $option in
    1)
      create_application
      ;;
    2)
      add_existing_application
      ;;
    3)
      exit 0
      ;;
    *)
      handle_invalid_input
      ;;
  esac
done
