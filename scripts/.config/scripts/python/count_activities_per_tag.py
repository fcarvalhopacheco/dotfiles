import json
import subprocess
import sys
from collections import Counter


def run_taskwarrior_command(command):
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {command}")
        print(e.output)
        sys.exit(1)

def main(start_date, end_date, projects, task_type_options):
    # Create the taskwarrior command
    project_filter = ' or '.join([f'project:{project}' for project in projects])
    task_command = f'task status:completed "({project_filter}) end.after:{start_date} end.before:{end_date}" export'

    # Run the taskwarrior command
    task_output = run_taskwarrior_command(task_command)

    # Parse the JSON output
    tasks = json.loads(task_output)

    # Extract tags and count them
    tag_counter = Counter()
    total_tasks = len(tasks)
    for task in tasks:
        tags = task.get('tags', [])
        tag_counter.update(tags)

    # Sort tags by count (descending) or alphabetically
    sorted_tags = sorted(tag_counter.items(), key=lambda x: (-x[1], x[0]))

    # Calculate statistics
    total_unique_tags = len(tag_counter)
    most_frequent_tag = sorted_tags[0] if sorted_tags else ("None", 0)
    least_frequent_tag = sorted_tags[-1] if sorted_tags else ("None", 0)

    # Generate the report
    report_file = 'tag_activity_count_report.txt'
    with open(report_file, 'w') as report:
        report.write("Tag Activity Count Report\n")
        report.write("=========================\n")
        report.write(f"Period: {start_date} to {end_date}\n\n")
        report.write(f"Total tasks analyzed: {total_tasks}\n")
        report.write(f"Total unique tags: {total_unique_tags}\n")
        report.write(f"Most frequent tag: {most_frequent_tag[0]} ({most_frequent_tag[1]} occurrences)\n")
        report.write(f"Least frequent tag: {least_frequent_tag[0]} ({least_frequent_tag[1]} occurrences)\n")
        report.write("\nTag Count Details:\n")
        report.write(f"{'Tag':<30}{'Count':>10}{'Percentage':>15}\n")
        report.write(f"{'-'*55}\n")
        for tag, count in sorted_tags:
            percentage = (count / total_tasks) * 100 if total_tasks > 0 else 0
            report.write(f"{tag:<30}{count:>10}{percentage:>14.2f}%\n")

        # Task type details
        report.write("\nTask Type Percentages:\n")
        task_type_counts = {task_type: tag_counter.get(task_type, 0) for task_type in task_type_options}
        sorted_task_types = sorted(task_type_counts.items(), key=lambda x: (-x[1], x[0]))
        total_task_type_counts = sum(task_type_counts.values())

        report.write(f"{'Task Type':<30}{'Count':>10}{'Percentage':>15}\n")
        report.write(f"{'-'*55}\n")
        for task_type, count in sorted_task_types:
            percentage = (count / total_task_type_counts) * 100 if total_task_type_counts > 0 else 0
            report.write(f"{task_type:<30}{count:>10}{percentage:>14.2f}%\n")

    print(f"Tag activity count report generated: {report_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python count_all_tags_with_task_type_stats.py <start_date> <end_date>")
        print("Example: python count_all_tags_with_task_type_stats.py 2023-10-01 2024-10-01")
        sys.exit(1)

    start_date = sys.argv[1]
    end_date = sys.argv[2]
    projects = ["HOT", "WHOTS", "ACO"]
    task_type_options = [
        "Analyzes", "CodeDevelopment", "Conference", "CruiseParticipation",
        "CruisePreparation", "DataAnalysis", "DataArchive", "DataCalibration",
        "DataDissimination", "DataManagement", "DataProcessing", "DataReport",
        "DataQC", "DataRequest", "Instrumention", "Meeting", "Others",
        "PersonalDev", "PostCruiseReport", "SystemAdm", "Courses"
    ]

    main(start_date, end_date, projects, task_type_options)

