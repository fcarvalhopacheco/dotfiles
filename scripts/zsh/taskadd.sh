clear
echo "==================== Task Creation ===================="

# Load the file
source /Users/fcp/.dotfiles/scripts/zsh/conf/taskconfig.sh

# Styling Function
echo_line() {
    echo "----------------------------------------------------"
}

# Functions
select_project() {
    echo -e "\033[34mSelect a project:\033[0m"  # Blue color for prompts
    select project in "${(@k)projects}"; do
        [[ -n $project ]] && break || echo -e "\033[31mInvalid selection. Please try again.\033[0m"  # Red for errors
    done
    echo_line
}

enter_cruise_number() {
    if [[ ${projects[$project]} == "Cruise" ]]; then
        read "?Enter Cruise Number: " cruise_number
        cruise_number=${cruise_number:-"N/A"}
        echo_line
    else
        cruise_number="N/A"
    fi
}

select_personal_details() {
    if [[ ${projects[$project]} == "Personal" ]]; then
        echo "Select Personal Activity:"
        select personal_activity in "${personal_activities[@]}"; do
            [[ -n $personal_activity ]] && break || echo "Invalid selection. Please try again."
        done
        echo_line

        echo "Select Personal Task:"
        select personal_task in "${personal_tasks[@]}"; do
            [[ -n $personal_task ]] && break || echo "Invalid selection. Please try again."
        done
        echo_line
    fi
}

select_what_and_task_type() {
    if [[ ${projects[$project]} != "Personal" ]]; then
        echo "Select 'What' you are working on:"
        select what in "${what_options[@]}"; do
            [[ -n $what ]] && break || echo "Invalid selection. Please try again."
        done
        echo_line

        echo "Select Task Type:"
        select task_type in "${task_type_options[@]}"; do
            [[ -n $task_type ]] && break || echo "Invalid selection. Please try again."
        done
        echo_line
    fi
}

confirm_and_add_task() {
    echo "Enter Due Date for the task."
    echo "You can use specific dates (e.g., '2023-12-31'), durations (e.g., '2weeks'), or relative dates (e.g., 'tomorrow', 'friday')."
    echo "Refer to Taskwarrior documentation for more options: https://taskwarrior.org/docs/durations/"
    echo " "
    read -r "?Enter Due Date: " due_date
    due_date=${due_date//\"/}  # Remove quotes if any
    echo_line

    # Construct the task description and tags
    if [[ "$project" == "PERSONAL" ]]; then
        task_desc="[$project][$personal_activity][$personal_task]"
        tags="tags:$personal_activity,$personal_task"
        echo "Task to add: $task_desc\nDue: $due_date\n"
    else
        task_desc="[$project][$cruise_number][$what][$task_type]"
        tags="tags:$cruise_number,$what,$task_type"
        echo "Task to add: $task_desc\nCruise Number: $cruise_number\nWhat: $what\nTask Type: $task_type\nDue: $due_date\n"
    fi

    read -r "?Confirm adding this task? (y/n): " input_confirm
    if [[ $input_confirm =~ ^[Yy]$ ]]; then
        task add "$task_desc" project:"$project" due:"$due_date" "$tags"
        echo "Task added successfully."
    else
        echo "Task addition cancelled."
    fi
    echo_line
}


select_project
enter_cruise_number
select_personal_details
select_what_and_task_type
confirm_and_add_task
