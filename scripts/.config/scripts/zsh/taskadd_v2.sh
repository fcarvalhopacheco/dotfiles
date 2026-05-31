#!/usr/bin/env zsh
# taskadd_v4.sh
# Compact/contextual Taskwarrior task creator for Fernando.

setopt NO_NOMATCH

CONFIG_FILE="${TASKADD_CONFIG:-/Users/fcp/.dotfiles/scripts/.config/scripts/zsh/conf/taskconfig_v2.sh}"
CUSTOM_CONFIG="${TASKADD_CUSTOM_CONFIG:-/Users/fcp/.dotfiles/scripts/.config/scripts/zsh/conf/taskconfig_custom.sh}"
USE_UDAS="${USE_UDAS:-1}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Config file not found: $CONFIG_FILE"
  echo "Set TASKADD_CONFIG=/path/to/taskconfig_v2.sh or edit CONFIG_FILE in taskadd_v2.sh"
  exit 1
fi
source "$CONFIG_FILE"
[[ -f "$CUSTOM_CONFIG" ]] && source "$CUSTOM_CONFIG"

line() { echo "----------------------------------------------------"; }
title() { echo; echo "== $1 =="; }
footer() { echo "Enter number/name | /term search | all | c custom | ? help"; }

print_cols() {
  local -a items=("$@")
  local i=1 cols="${TASKADD_COLS:-3}" width="${TASKADD_WIDTH:-24}"
  for item in "${items[@]}"; do
    printf "%3d) %-*s" "$i" "$width" "$item"
    (( i % cols == 0 )) && echo
    (( i++ ))
  done
  (( (i-1) % cols != 0 )) && echo
}

contains_exact() {
  local needle="$1"; shift
  local item
  for item in "$@"; do [[ "${item:l}" == "${needle:l}" ]] && return 0; done
  return 1
}

match_items_array() {
  local needle="${1:l}"; shift
  local item
  for item in "$@"; do [[ "${item:l}" == *"$needle"* ]] && print -r -- "$item"; done
}

dedupe_lines() { awk '!seen[tolower($0)]++'; }

slugify_tag() {
  local raw="$1"
  raw="${raw:l}"; raw="${raw// /-}"; raw="${raw//_/-}"
  raw="${raw//[^a-z0-9-]/}"; raw="${raw##-}"; raw="${raw%%-}"
  echo "$raw"
}

append_custom_value() {
  local array_name="$1" value="$2" safe="${value//\"/\\\"}"
  mkdir -p "$(dirname "$CUSTOM_CONFIG")"
  [[ ! -f "$CUSTOM_CONFIG" ]] && echo "# taskconfig_custom.sh" > "$CUSTOM_CONFIG"
  if ! grep -q "\"$safe\"" "$CUSTOM_CONFIG" 2>/dev/null; then
    echo "${array_name}+=(\"${safe}\")" >> "$CUSTOM_CONFIG"
    echo "Saved '$value' to $CUSTOM_CONFIG"
  fi
}

choose_from_list() {
  local prompt="$1" suggested_name="$2" all_name="$3" default_value="$4" help_text="$5" custom_array="$6"
  local -a suggested all_items matches
  suggested=("${(@P)suggested_name}")
  all_items=("${(@P)all_name}")
  suggested=(${(f)$(printf "%s\n" "${suggested[@]}" | dedupe_lines)})

  while true; do
    title "$prompt"
    [[ -n "$default_value" ]] && echo "Default: $default_value"
    if (( ${#suggested[@]} > 0 )); then
      echo "Suggestions:"
      print_cols "${suggested[@]}"
    fi
    footer
    read "?Choice${default_value:+ [$default_value]}: " choice

    [[ -z "$choice" && -n "$default_value" ]] && SELECTED="$default_value" && return

    case "$choice" in
      \?) line; echo "$help_text"; echo; echo "Controls: /ctd search, all full list, c custom, exact name accepted."; line; continue ;;
      all) echo; echo "Full list:"; print_cols "${all_items[@]}"; continue ;;
      c) read "?Custom value: " custom
         if [[ -n "$custom" ]]; then
           SELECTED="$custom"
           read "?Save '$custom' for future use? (y/n): " saveit
           [[ "$saveit" =~ ^[Yy]$ && -n "$custom_array" ]] && append_custom_value "$custom_array" "$custom"
           return
         fi
         continue ;;
    esac

    if [[ "$choice" == /* ]]; then
      local term="${choice#/}"
      matches=(${(f)$(match_items_array "$term" "${all_items[@]}" | dedupe_lines)})
      if (( ${#matches[@]} == 0 )); then echo "No matches for '$term'."; continue; fi
      echo; echo "Search results for '$term':"; print_cols "${matches[@]}"
      read "?Choose result number/exact value, or Enter to search again: " s
      [[ -z "$s" ]] && continue
      if [[ "$s" == <-> && "$s" -ge 1 && "$s" -le "${#matches[@]}" ]]; then SELECTED="${matches[$s]}"; return; fi
      if contains_exact "$s" "${matches[@]}"; then
        for item in "${matches[@]}"; do [[ "${item:l}" == "${s:l}" ]] && SELECTED="$item" && return; done
      fi
      echo "Invalid search selection."; continue
    fi

    if [[ "$choice" == <-> && "$choice" -ge 1 && "$choice" -le "${#suggested[@]}" ]]; then SELECTED="${suggested[$choice]}"; return; fi
    if contains_exact "$choice" "${all_items[@]}"; then
      for item in "${all_items[@]}"; do [[ "${item:l}" == "${choice:l}" ]] && SELECTED="$item" && return; done
    fi
    echo "Invalid choice. Type ? for help, /term to search, or c for custom."
  done
}

get_scope_array_name() {
  case "$program" in
    HOT) echo hot_scope_options ;; WHOTS) echo whots_scope_options ;; ACO) echo aco_scope_options ;;
    SOEST) echo soest_scope_options ;; PERSONAL) echo personal_scope_options ;; LEGACY) echo legacy_scope_options ;;
    *) echo hot_scope_options ;;
  esac
}
context_key() { echo "${program}.${scope}"; }

suggested_components_for_context() {
  local raw="${component_suggestions[$(context_key)]}"
  [[ -n "$raw" ]] && { echo "$raw"; return; }
  case "$program" in
    HOT|WHOTS|ACO) echo "${component_core_ocean[@]} ${component_reports[@]}" ;;
    SOEST) echo "${component_infra[@]}" ;;
    PERSONAL) echo "${component_personal[@]}" ;;
    LEGACY) echo "${component_legacy[@]}" ;;
    *) echo Other ;;
  esac
}

suggested_worktypes_for_context() { local raw="${worktype_suggestions[$scope]}"; [[ -n "$raw" ]] && echo "$raw" || echo "${worktype_common[@]}"; }
suggested_tags_for_context() { local raw="${tag_suggestions[$(context_key)]}"; [[ -n "$raw" ]] && echo "$raw" || echo "next waiting blocked review followup year-review python matlab"; }

normalize_id() {
  local p="$1" s="$2" raw="$3"
  raw="${raw// /}"; raw="${raw//-/}"
  [[ -z "$raw" ]] && { echo General; return; }
  case "$p:$s" in
    HOT:Cruise) [[ "$raw" == H* ]] && echo "$raw" || echo "H$raw" ;;
    WHOTS:Deployment|WHOTS:Cruise|WHOTS:DataReport) [[ "$raw" == W* ]] && echo "$raw" || echo "W$raw" ;;
    ACO:Deployment|ACO:Cruise) [[ "$raw" == ACO* ]] && echo "$raw" || echo "ACO$raw" ;;
    *) echo "$raw" ;;
  esac
}

ask_id() {
  title "ID / anchor"
  case "$program:$scope" in
    HOT:Cruise) read "?HOT cruise number, e.g. 363 -> H363: " raw_id ;;
    WHOTS:Deployment|WHOTS:Cruise|WHOTS:DataReport) read "?WHOTS number, e.g. 21 -> W21: " raw_id ;;
    ACO:Deployment|ACO:Cruise) read "?ACO identifier, or Enter for General: " raw_id ;;
    HOT:AnnualReport) read "?Report year, e.g. 2025: " raw_id ;;
    SOEST:Server|SOEST:Backup|SOEST:Database|SOEST:Website) read "?System/site, e.g. helu, aina, qnap, borg, hahana: " raw_id ;;
    HOT:Research|WHOTS:Research|ACO:Research) read "?Research topic, e.g. DeepCTD, MooringMotion, BottomTemperature: " raw_id ;;
    PERSONAL:*) raw_id=General ;;
    *) read "?ID, or Enter for General: " raw_id ;;
  esac
  task_id="$(normalize_id "$program" "$scope" "$raw_id")"
  echo "Using ID: $task_id"
}

build_project_name() { [[ -z "$task_id" || "$task_id" == General ]] && project_name="${program}.${scope}.${component}" || project_name="${program}.${scope}.${task_id}.${component}"; }

choose_tags() {
  local suggestions=(${=:-$(suggested_tags_for_context)}) raw
  title "Tags"
  echo "Suggested: ${suggestions[*]}"
  echo "Comma-separated. Type ? to show tag groups. Enter to skip."
  read "?Tags: " raw
  if [[ "$raw" == "?" ]]; then
    echo "Workflow: ${tag_workflow[*]}"; echo "Report: ${tag_report[*]}"; echo "Tools: ${tag_tool[*]}"
    echo "People: ${tag_people[*]}"; echo "Science: ${tag_science[*]}"; echo "Personal: ${tag_personal[*]}"
    read "?Tags: " raw
  fi
  selected_tags=()
  if [[ -n "$raw" ]]; then
    local -a parts; parts=("${(@s:,:)raw}")
    for tag in "${parts[@]}"; do tag="$(slugify_tag "$tag")"; [[ -n "$tag" ]] && selected_tags+=("+$tag"); done
  fi
  [[ "$work_type" == CodeDevelopment || "$work_type" == Automation || "$work_type" == Refactor ]] && selected_tags+=(+code)
  [[ "$work_type" == Troubleshooting || "$work_type" == Debugging ]] && selected_tags+=(+troubleshooting)
  [[ "$work_type" == ReportWriting || "$work_type" == DataReport || "$work_type" == PostCruiseReport ]] && selected_tags+=(+report)
  [[ "$scope" == AnnualReport || "$component" == YearReview || "$component" == PerformanceReview ]] && selected_tags+=(+year-review)
  selected_tags=(${(f)$(printf "%s\n" "${selected_tags[@]}" | dedupe_lines)})
}

quick_capture() { title "Quick capture"; read "?Description: " desc; [[ -z "$desc" ]] && echo "Cancelled." && exit 0; task add "$desc" +inbox; exit $?; }

guided_task() {
  clear; echo "==================== Task Creation  ===================="; echo "Compact mode. Type ? when you need help."
  choose_from_list "Program" program_options program_options HOT "Program is the big world: HOT, WHOTS, ACO, SOEST, PERSONAL, LEGACY." ""; program="$SELECTED"
  local scope_array; scope_array="$(get_scope_array_name)"
  choose_from_list "Scope" "$scope_array" "$scope_array" "" "Scope is the container: Cruise, AnnualReport, Infrastructure, Research, Training, General, etc." ""; scope="$SELECTED"
  ask_id
  local comp_suggestions; comp_suggestions=(${=:-$(suggested_components_for_context)})
  choose_from_list "Component" comp_suggestions component_all "" "Component is the noun: instrument, system, deliverable, or life area affected by the task." component_all; component="$SELECTED"
  local wt_suggestions; wt_suggestions=(${=:-$(suggested_worktypes_for_context)})
  choose_from_list "Work type" wt_suggestions worktype_all "" "Work type is the action category: DataProcessing, DataQC, Calibration, ReportWriting, Automation, Troubleshooting, etc." worktype_all; work_type="$SELECTED"

  title "Role (optional)"; echo "Default: None. Type ? to list roles."; read "?Role [None]: " role_choice
  if [[ -z "$role_choice" ]]; then role=None; elif [[ "$role_choice" == "?" ]]; then print_cols "${role_options[@]}"; read "?Role [None]: " role_choice2; role="${role_choice2:-None}"; else role="$role_choice"; fi

  local default_verb="${default_verb_for_worktype[$work_type]}"; [[ -z "$default_verb" ]] && default_verb=Update
  choose_from_list "Description verb" verb_common verb_all "$default_verb" "Description should start with a clear verb: Reprocess HOT-363 CTD oxygen calibration." verb_all; verb="$SELECTED"
  title "Description details"; echo "Final description = '$verb' + details."; echo "Examples: HOT-363 CTD oxygen calibration | HOT-358 post-cruise assessment | Current.status HTML pipeline"
  read "?Details: " desc_details; [[ -z "$desc_details" ]] && desc_details="${program} ${task_id} ${component} ${work_type}"; task_desc="${verb} ${desc_details}"
  choose_tags
  title "Due / priority"; echo "Due is optional. Use real deadlines only."; read "?Due [none]: " due_date; due_date="${due_date//\"/}"; read "?Priority [none/H/M/L]: " priority; priority="${priority:u}"; [[ "$priority" != H && "$priority" != M && "$priority" != L ]] && priority=""
  title "Annotation (optional)"; echo "Use for paths, commands, decisions, or why this task exists."; read "?Annotation [skip]: " first_annotation
  build_project_name
  line; echo "Preview"; echo "Description : $task_desc"; echo "Project     : $project_name"; echo "Metadata    : program=$program scope=$scope taskid=$task_id component=$component worktype=$work_type role=$role"; [[ -n "$due_date" ]] && echo "Due         : $due_date"; [[ -n "$priority" ]] && echo "Priority    : $priority"; echo "Tags        : ${selected_tags[*]}"; [[ -n "$first_annotation" ]] && echo "Annotation  : $first_annotation"; line
  read "?Add task? (y/n): " ok; [[ ! "$ok" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 0
  cmd=(task add "$task_desc" project:"$project_name"); [[ -n "$due_date" ]] && cmd+=(due:"$due_date"); [[ -n "$priority" ]] && cmd+=(priority:"$priority")
  [[ "$USE_UDAS" == 1 ]] && cmd+=(program:"$program" scope:"$scope" taskid:"$task_id" component:"$component" worktype:"$work_type" role:"$role")
  cmd+=("${selected_tags[@]}")
  echo "Running:"; printf ' %q' "${cmd[@]}"; echo; "${cmd[@]}"
  if [[ -n "$first_annotation" ]]; then last_id="$(task +PENDING "$task_desc" limit:1 rc.verbose:nothing ids 2>/dev/null | head -n 1)"; [[ -n "$last_id" ]] && task "$last_id" annotate "$first_annotation"; fi
  echo "Task added."
}

echo "TaskAdd "; echo "g = guided structured task"; echo "q = quick inbox capture"; echo "? = help"; read "?Mode [g]: " mode
case "$mode" in q|Q) quick_capture ;; \?) echo "Guided: structured metadata. Quick: simple +inbox capture. Menus support /search, all, c, ?."; guided_task ;; *) guided_task ;; esac
