#!/bin/bash
clear

echo "==================== Task Creation ===================="

select_project() {
    echo -e "\nSelect a project:"
    select project in \
        ACO \ 
        HOT \
        PERSONAL \
        WHOTS 
    do
        echo -e "\nSelected project: $project"
        echo "----------------------------------------------------"
        break
    done
}

enter_cruise_number() {
    if [[ "$project" == "HOT" || "$project" == "WHOTS" ]]; then
        read -p "Enter Cruise Number: " cruise_number
        echo -e "\nEntered Cruise Number: $cruise_number"
        echo "----------------------------------------------------"
    else
        cruise_number="N/A"
    fi
}

select_what() {
    echo -e "Select what you are working on:"
    select what in \
        "autosal" \
        "bgc" \
        "bottles" \
        "ctd" \
        "github" \
        "ifcb" \
        "ladcp" \
        "metobs" \
        "microcats" \
        "mooredAdcp" \
        "others" \
        "shipAdcp" \
        "tsg" \
        "underway" \
        "uvp" \
        "yearReview"

    do
        echo -e "\nSelected what: $what"
        echo "----------------------------------------------------"
        break
    done
}

select_task_type() {
    echo -e "Select task type:"
    select task_type in \
        "analyzes" \
        "codeDevelopment" \
        "conference" \
        "cruiseParticipation" \
        "cruisePreparation" \
        "dataAnalysis" \
        "dataArchive" \
        "dataDissimination" \
        "dataManagement" \
        "dataProcessing" \
        "dataReport" \
        "dataQC" \
        "dataRequest" \
        "instrumention" \
        "meeting" \
        "others" \
        "personalDev" \
        "systemAdm"
    do
        echo -e "\nSelected task type: $task_type"
        echo "----------------------------------------------------"
        break
    done
}

select_project
enter_cruise_number
select_what
select_task_type

# Construct the task description
task_desc="[$project][$cruise_number][$what][$task_type]"

# Add the task in Taskwarrior
task add "$task_desc" project:$project +$cruise_number +$task_type
