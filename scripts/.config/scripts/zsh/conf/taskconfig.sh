# Configuration arrays or read them from an external file

# taskconfig.sh - Configuration for task creation script

# Projects configuration
declare -A projects=(
    ["ACO"]="Cruise"
    ["HOT"]="Cruise"
    ["PERSONAL"]="Personal"
    ["WHOTS"]="Cruise"
)

# Personal activities configuration
personal_activities=(
    "FamilyAndRelationships" "HealthAndFitness"
    "HobbiesAndLeisure" "HouseholdManagement"
    "PersonalDevelopment" "PersonalFinance"
)

# Personal tasks configuration
personal_tasks=( "ArtProjects" "Bike" "BookReading" "BudgetPlanning" "Code"
    "ExerciseRoutine" "FamilyTime" "FinancialReview" "Gardening"
    "HomeImprovement" "HouseCleaning" "InvestmentResearch" "Journaling"
    "LanguageLearning" "Taskwarrior" "MealPreparation" "Meditation"
    "Neovim" "OnlineCourse" "Paddle" "Run" "ReadBook" "Surf" "SkillDevelopment" 
    "SocialNetworking" "TravelPlanning" "Workout"
)

# 'What' options configuration
what_options=(
    "AutoSal" "BGC" "Bottles" "CTD" "CS" "GitHub" "IFCB" "LADCP" "MetObs"
    "MicroCats" "MooredADCP" "ShipADCP" "TSG" "Underway" "UVP"
    "YearReview" "GlassBalls" "Courses" "Meeting" "Computer" "Loading" "Others" 
    "CruiseParticipation"
)

# Task type options configuration
task_type_options=( "Analyzes" "Substandard" "CodeDevelopment" "Conference"
	"CruiseParticipation" "CruisePreparation" "DataAnalysis" "DataArchive"
	"DataCalibration" "DataDissimination" "DataManagement" "DataProcessing"
	"DataReport" "DailyReport" "DataQC" "DataRequest" "Instrumention" "Meeting" "Others"
	"PersonalDev" "PostCruiseReport" "SystemAdm" "Courses" 
)



