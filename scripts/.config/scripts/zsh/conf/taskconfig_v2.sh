# taskconfig_v4.sh
# Compact/contextual vocabulary for Fernando's Taskwarrior workflow.
# Use with taskadd_v4.sh.

program_options=(HOT WHOTS ACO SOEST PERSONAL LEGACY)
hot_scope_options=(Cruise AnnualReport Infrastructure Research Training Administration General)
whots_scope_options=(Deployment Cruise DataReport Infrastructure Research Training General)
aco_scope_options=(Deployment Cruise Research Infrastructure General)
soest_scope_options=(Server Backup Website Database Admin Training General)
personal_scope_options=(Health Finance Learning Business Creative Home Family Admin General)
legacy_scope_options=(BATS HYDRO OA METS Other)

component_core_ocean=(CTD AutoSal Bottle DiscreteSalinity Oxygen Temperature Pressure Conductivity Rosette TraceMetal BGC MetObs TSG Underway UCTD ShipADCP LADCP ADCP MicroCAT MooredADCP MooringPosition MooringDeployment MooringRecovery SedimentTraps PPArray GasArray WireWalker NetTow HyperPro IFCB UVP VMP Seaglider SUBSEA McLanePumps BridgeLog CruisePlan Loading LARS GlassBalls)
component_reports=(DailyReport CruiseReport PostCruiseReport AnnualReport DataReport YearReview PerformanceReview Documentation Publication Presentation Email)
component_infra=(CurrentStatus Website Database Server Backup Borg NAS QNAP GitHub Sphinx Hugo Python MATLAB Linux Neovim Taskwarrior Inventory Workflow)
component_personal=(Fitness Paddling Surf Run Bike Finance Rent Course Book BibleStudy Training Travel Family Business Blog YouTube Home Admin)
component_legacy=(BATS HYDRO OA METS WorkLog)
component_all=(${component_core_ocean[@]} ${component_reports[@]} ${component_infra[@]} ${component_personal[@]} ${component_legacy[@]} Other)

typeset -A component_suggestions
component_suggestions=(
  "HOT.Cruise" "CTD AutoSal Bottle Oxygen Temperature Pressure TraceMetal SedimentTraps PPArray GasArray WireWalker NetTow ShipADCP Underway MetObs CruisePlan DailyReport BridgeLog Loading"
  "HOT.AnnualReport" "CTD AutoSal Bottle Oxygen Temperature DiscreteSalinity MetObs ShipADCP Underway AnnualReport YearReview"
  "HOT.Infrastructure" "CurrentStatus Website Database GitHub Python MATLAB Sphinx Server Backup Workflow Taskwarrior"
  "HOT.Research" "CTD Temperature Oxygen Pressure MicroCAT MooredADCP ShipADCP ACO MetObs Publication Presentation"
  "HOT.Training" "CTD AutoSal Python MATLAB Linux Sphinx Taskwarrior Documentation Training"
  "HOT.Administration" "CruisePlan Email Meeting Loading BridgeLog Documentation"
  "WHOTS.Deployment" "MicroCAT MooredADCP MooringPosition MooringDeployment MooringRecovery CTD TSG MetObs ShipADCP CruiseReport DataReport"
  "WHOTS.DataReport" "MicroCAT MooredADCP CTD TSG MetObs ShipADCP AnnualReport Documentation"
  "WHOTS.Infrastructure" "Website Database Python Sphinx GitHub Workflow"
  "SOEST.Server" "Server Linux Database Website Backup Borg NAS QNAP GitHub"
  "SOEST.Backup" "Backup Borg NAS QNAP Server Linux"
  "SOEST.Website" "Website GitHub Hugo Sphinx Python CurrentStatus"
  "SOEST.Database" "Database Pythonv MATLAB Inventory Server"
  "PERSONAL.Health" "Fitness Paddling Surf Run Bike Training"
  "PERSONAL.Finance" "Finance Rent"
  "PERSONAL.Learning" "Course Book BibleStudy Python Linux Taskwarrior Neovim"
  "PERSONAL.Business" "Business Blog YouTube Website Finance"
  "PERSONAL.Creative" "Blog YouTube Book Presentation Documentation"
)

worktype_common=(Review Update Write Meeting Planning Documentation Troubleshooting Other)
worktype_data=(DataProcessing DataQC Calibration Analysis Plotting FigureGeneration DataManagement DataArchive DataDissemination DataRequest DataDownload DataIngestion)
worktype_code=(Automation CodeDevelopment Refactor Debugging Testing CodeReview WebsiteUpdate SystemAdministration Backup)
worktype_ops=(CruisePreparation CruiseOperations Loading Deployment Recovery Maintenance Safety Scheduling Communication Procurement)
worktype_learning=(Learning CourseWork Training Research)
worktype_all=(${worktype_common[@]} ${worktype_data[@]} ${worktype_code[@]} ${worktype_ops[@]} ${worktype_learning[@]} ReportWriting DataReport PostCruiseReport Publication Submission Inventory Acquisition Email Other)

typeset -A worktype_suggestions
worktype_suggestions=(
  "Cruise" "CruisePreparation CruiseOperations DataProcessing DataQC Calibration ReportWriting Meeting Planning Troubleshooting"
  "Deployment" "Deployment Recovery DataProcessing DataQC Analysis ReportWriting Planning Troubleshooting"
  "AnnualReport" "ReportWriting DataProcessing DataQC Analysis Plotting FigureGeneration Review Submission"
  "DataReport" "ReportWriting DataProcessing DataQC Plotting FigureGeneration Review Submission"
  "Infrastructure" "Automation CodeDevelopment Refactor Testing Documentation SystemAdministration Troubleshooting WebsiteUpdate Backup"
  "Research" "Analysis Plotting FigureGeneration Research ReportWriting Documentation Publication"
  "Training" "Learning CourseWork Documentation Review"
  "Administration" "Planning Scheduling Communication Email Meeting Documentation Submission"
  "Server" "SystemAdministration Backup Troubleshooting Documentation Maintenance"
  "Backup" "Backup Troubleshooting SystemAdministration Documentation Testing"
  "Website" "WebsiteUpdate Automation CodeDevelopment Refactor Documentation Troubleshooting"
  "Database" "DataManagement DataIngestion DataQC CodeDevelopment Documentation Troubleshooting"
  "Health" "Training Planning Review"
  "Finance" "Planning Review Submission Communication"
  "Learning" "Learning CourseWork Documentation Review"
  "Business" "Planning Research Writing WebsiteUpdate"
  "Creative" "Writing Draft Review Publication"
  "General" "Planning Meeting Review Documentation Other"
)

verb_common=(Review Update Write Process Reprocess Analyze Calibrate Generate Plot Fix Troubleshoot Document Prepare Submit)
verb_all=(Add Analyze Archive Backup Build Calibrate Check Clean Compare Create Debug Document Download Draft Fix Generate Import Improve Investigate Learn Merge Move Organize Plot Prepare Process Publish Refactor Reprocess Review Run Submit Summarize Sync Test Troubleshoot Update Upload Write Other)
typeset -A default_verb_for_worktype
default_verb_for_worktype=(DataProcessing Process DataQC Review Calibration Calibrate Analysis Analyze Plotting Plot FigureGeneration Generate ReportWriting Write DataReport Write PostCruiseReport Write Automation Automate CodeDevelopment Build Refactor Refactor Debugging Debug Testing Test Troubleshooting Troubleshoot Documentation Document WebsiteUpdate Update SystemAdministration Fix Backup Backup Meeting Review Planning Prepare Submission Submit Learning Learn)

role_options=(None ChiefScientist WatchLeader ConsoleOperator CTDOperator Analyst DataManager Developer SystemAdministrator Mentor Student Personal)

tag_workflow=(next waiting blocked review followup submitted published urgent lowpriority needs-decision deep-work quick recurring someday)
tag_report=(year-review rcuh-review annual-report post-cruise daily-report publication presentation deliverable)
tag_tool=(python matlab github sphinx myst latex mysql gmt linux macos zsh taskwarrior neovim jinja2 hugo borg qnap google-drive website server)
tag_people=(fsm df mk tully paul bridge otg rcuh student gra intern vendor ship)
tag_science=(temperature salinity oxygen pressure deep-cast drift qc calibration adcp microcat metobs mooring aloha kahe trace-metal subsea incubator hazmat)
tag_personal=(health fitness paddling surf run bike finance rent family learning business blog youtube church travel)
tag_legacy=(legacy imported batsdb old-format needs-cleanup)
tag_all=(${tag_workflow[@]} ${tag_report[@]} ${tag_tool[@]} ${tag_people[@]} ${tag_science[@]} ${tag_personal[@]} ${tag_legacy[@]})

typeset -A tag_suggestions
tag_suggestions=(
  "HOT.Cruise" "next year-review matlab python daily-report post-cruise bridge otg deep-work"
  "HOT.AnnualReport" "year-review annual-report report matlab python qc calibration"
  "HOT.Infrastructure" "python website github deep-work code troubleshooting"
  "HOT.Research" "year-review temperature oxygen deep-cast python matlab publication"
  "WHOTS.Deployment" "year-review report python matlab mooring adcp microcat"
  "WHOTS.DataReport" "annual-report report python matlab mooring adcp microcat"
  "SOEST.Server" "server linux troubleshooting waiting fsm"
  "SOEST.Backup" "borg qnap backup server troubleshooting"
  "PERSONAL.Health" "health fitness paddling surf run bike"
  "PERSONAL.Finance" "finance rent followup"
  "PERSONAL.Learning" "learning course deep-work"
)

