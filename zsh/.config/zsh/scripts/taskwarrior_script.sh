#!/bin/bash

echo "Select a project:"
select project in HOT WHOTS PERSONAL ACO METS; do
    break
done

echo "Enter Cruise Number:"
read cruise_number

echo "Select a task type:"
select task_type in DataProcessing CruisePreparation Analysis; do
    break
done

# Construct the task description
task_desc="Task for $project cruise $cruise_number [$task_type]"

# Add the task in Taskwarrior
task add "$task_desc" project:$project +$cruise_number +$task_type

