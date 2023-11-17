#!/bin/bash

clear

echo "==================== Task Creation ===================="

select_project() {
    echo -e "\nSelect a project:"
    select project in ACO HOT PERSONAL WHOTS; do
        echo -e "\nSelected project: $project"
        echo "----------------------------------------------------"
        break
    done
}

enter_cruise_number() {
    if [[ "$project" == "HOT" || "$project" == "WHOTS" || "$project" == "ACO" ]]; then
        read -p "Enter Cruise Number: " cruise_number
        echo -e "\nEntered Cruise Number: $cruise_number"
        echo "----------------------------------------------------"
    else
        cruise_number="N/A"
    fi
}


select_personal_details() {
    if [[ "$project" == "PERSONAL" ]]; then
        echo -e "Select Personal Activity:\n"
        select personal_activity in \
                "FamilyAndRelationships" \
                "HealthAndFitness" \
                "HobbiesAndLeisure" \
                "HouseholdManagement" \
                "PersonalDevelopment" \
            "PersonalFinance"; do
            echo -e "\nSelected Activity: $personal_activity"
            echo "----------------------------------------------------"
            break
        done

        echo -e "Select Personal Task:\n"
        select personal_task in \
                "ArtProjects" \
                "BookReading" \
                "BudgetPlanning" \
                "Code"\
                "ExerciseRoutine" \
                "FamilyTime" \
                "FinancialReview" \
                "Gardening" \
                "HomeImprovement" \
                "HouseCleaning" \
                "InvestmentResearch" \
                "Journaling" \
                "LanguageLearning" \
                "LearnTaskwarrior" \
                "MealPreparation" \
                "Meditation" \
                "OnlineCourse" \
                "ReadBook" \
                "SkillDevelopment" \
                "SocialNetworking" \
                "TravelPlanning" \
                "Workout"; do
            echo -e "\nSelected Task: $personal_task"
            echo "----------------------------------------------------"
            break
        done
    fi
}

select_what_and_task_type() {
    if [[ "$project" != "PERSONAL" ]]; then
        echo -e "Select 'What' you are working on:\n"
        select what in \
            "AutoSal" \
            "BGC" \
            "Bottles" \
            "CTD" \
            "GitHub" \
            "IFCB" \
            "LADCP" \
            "MetObs" \
            "MicroCats" \
            "MooredADCP" \
            "Others" \
            "ShipADCP" \
            "TSG" \
            "Underway" \
            "UVP" \
            "YearReview"; do
            echo -e "\nSelected What: $what"
            echo "----------------------------------------------------"
            break
        done

        echo -e "Select Task Type:\n"
        select task_type in \
            "Analyzes" \
            "CodeDevelopment" \
            "Conference" \
            "CruiseParticipation" \
            "CruisePreparation" \
            "DataAnalysis" \
            "DataArchive" \
            "DataDissimination" \
            "DataManagement" \
            "DataProcessing" \
            "DataReport" \
            "DataQC" \
            "DataRequest" \
            "Instrumention" \
            "Meeting" \
            "Others" \
            "PersonalDev" \
            "SystemAdm"; do
            echo -e "\nSelected Task Type: $task_type"
            echo "----------------------------------------------------"
            break
        done
    fi
}

select_project
enter_cruise_number
select_personal_details
select_what_and_task_type

# Construct the task description
if [[ "$project" == "PERSONAL" ]]; then
    task_desc="[$project][$personal_activity][$personal_task]"
else
    task_desc="[$project][$cruise_number][$what][$task_type]"
fi


# Add the task in Taskwarrior
if [[ "$project" == "PERSONAL" ]]; then
    tags="tags:$personal_activity,$personal_task"
    task add "$task_desc" project:$project $tags
else
    tags="tags:$cruise_number,$what,$task_type"
    task add "$task_desc" project:$project $tags
fi

