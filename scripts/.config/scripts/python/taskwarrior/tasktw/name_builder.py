from __future__ import annotations

"""Centralized naming logic for TaskAdd.

This module is intentionally independent from the interactive prompt. The same
rules can be reused later by the migration planner so old tasks and new tasks
follow the same naming system.

Canonical structure
-------------------
Project:
    Program.Scope.[TaskID].Component

Description:
    Verb + readable details

Metadata:
    program/scope/taskid/component/worktype/role

The important rule is: TaskID is included in the project path only when it adds
information. For templates like HOT Mercator, the scope is already "Mercator";
typing ID "Mercator" should not create HOT.Mercator.Mercator.Blueprint.
"""

from dataclasses import dataclass
import re


_CAMEL_RE = re.compile(r"(?<!^)([A-Z][a-z])")


def humanize(value: str) -> str:
    """Turn internal labels into readable text without breaking acronyms."""

    value = value or ""
    acronyms = {
        "CTD", "TSG", "ADCP", "LADCP", "UCTD", "BGC", "QNAP", "NAS", "IFCB",
        "UVP", "VMP", "SST", "SSS", "SSH", "ALOHA", "GMT", "PyGMT", "AI",
    }
    if value in acronyms:
        return value
    return _CAMEL_RE.sub(r" \1", value.replace("_", " ")).strip()


@dataclass(frozen=True)
class NameContext:
    program: str
    scope: str
    taskid: str
    component: str
    worktype: str
    verb: str = ""
    details: str = ""


class NameBuilder:
    """Build final Taskwarrior project/description strings."""

    def normalized_taskid(self, ctx: NameContext) -> str:
        tid = (ctx.taskid or "").strip()
        if not tid or tid == "General":
            return "General"

        duplicate_values = {
            ctx.program.lower(),
            ctx.scope.lower(),
            ctx.component.lower(),
            ctx.component.replace(" ", "").lower(),
        }

        if tid.lower() in duplicate_values:
            return "General"

        generic_ids = {
            "general", "mercator", "copernicus", "infrastructure",
            "website", "workflow", "taskwarrior",
        }
        if tid.lower() in generic_ids and tid.lower() == ctx.scope.lower():
            return "General"

        return tid

    def include_taskid_in_project(self, ctx: NameContext) -> bool:
        tid = self.normalized_taskid(ctx)
        return bool(tid and tid != "General")

    def project(self, ctx: NameContext) -> str:
        """Build Program.Scope.[TaskID].Component."""

        component = ctx.component or "Other"
        tid = self.normalized_taskid(ctx)

        if ctx.program == "PERSONAL":
            return f"PERSONAL.{component}" if component and component != "Other" else "PERSONAL"

        if tid != "General":
            return f"{ctx.program}.{ctx.scope}.{tid}.{component}"

        return f"{ctx.program}.{ctx.scope}.{component}"

    def suggested_details(self, ctx: NameContext) -> str:
        """Return context-aware suggested description details."""

        program, scope = ctx.program, ctx.scope
        taskid, component, worktype = ctx.taskid, ctx.component, ctx.worktype
        comp = humanize(component)
        wt = humanize(worktype).lower()

        if program == "HOT" and scope == "Mercator":
            if component == "Blueprint":
                return "HOT Mercator/Copernicus project blueprint"
            if component in {"Forecast", "Recent", "Reanalysis"}:
                return f"HOT Mercator {comp.lower()} workflow"
            if component == "CopernicusDownload":
                return "HOT Copernicus Marine data-download workflow"
            if component == "DatasetMapping":
                return "HOT Mercator variable and dataset mapping"
            if component in {"ALOHA", "Kahe", "Kaena", "Stations"}:
                return f"HOT Mercator map overlays for {comp}"
            if component in {"SSH", "SST", "SSS", "Currents", "MixedLayerDepth", "Waves", "OceanColor", "Chlorophyll"}:
                return f"HOT Mercator {comp} product"
            if component == "DriftPrediction":
                return "HOT Mercator forecast-based array drift prediction"
            if component in {"GitHubPages", "Website", "HeluDeployment"}:
                return "HOT Mercator web deployment workflow"
            if component == "AI":
                return "AI-assisted HOT Mercator summary workflow"
            return f"HOT Mercator {comp} {wt}"

        if program == "HOT" and scope == "Cruise":
            cruise = taskid.replace("H", "HOT-") if taskid.startswith("H") else taskid
            if worktype == "DataProcessing":
                return f"{cruise} {comp} data"
            if worktype == "DataQC":
                return f"{cruise} {comp} QC"
            if worktype == "Calibration":
                return f"{cruise} {comp} calibration"
            if worktype in {"ReportWriting", "DataReport", "PostCruiseReport"}:
                return f"{cruise} {comp} report"
            return f"{cruise} {comp} {wt}"

        if program == "HOT" and scope == "AnnualReport":
            if component == "PerformanceReview":
                return f"{taskid} RCUH performance review"
            if component in {"AnnualReport", "DataReport", "YearReview"}:
                return f"{taskid} HOT annual report"
            return f"{taskid} HOT {comp} annual-report section"

        if program == "HOT" and scope == "Infrastructure":
            subject = {
                "CurrentStatus": "Current.status pipeline",
                "Website": "HOT website",
                "Database": "HOT database",
                "Server": "HOT server",
                "Backup": "HOT backup",
                "Workflow": "HOT workflow",
                "Taskwarrior": "Taskwarrior workflow",
                "MercatorCopernicus": "HOT Mercator/Copernicus workflow",
            }.get(component, f"HOT {comp}")

            if worktype == "Backup":
                return f"{subject} backup workflow"
            if worktype == "Automation":
                return f"{subject} automation"
            if worktype == "WebsiteUpdate":
                return f"{subject} update"
            if worktype == "Troubleshooting":
                return f"{subject} problem"
            return f"{subject} {wt}"

        if program == "WHOTS":
            whots = taskid.replace("W", "WHOTS-") if taskid.startswith("W") else taskid
            if worktype in {"ReportWriting", "DataReport"}:
                return f"{whots} {comp} data-report section"
            if worktype == "CruisePreparation":
                return f"{whots} {comp} cruise preparation"
            return f"{whots} {comp} {wt}"

        if program == "SOEST":
            base = taskid if taskid and taskid != "General" else "SOEST"
            if worktype == "Backup":
                return f"{base} {comp} backup workflow"
            return f"{base} {comp} {wt}"

        if program == "PERSONAL":
            return f"{comp} {wt}"

        return f"{program} {scope} {comp} {wt}".strip()

    def description(self, ctx: NameContext) -> str:
        """Build Verb + Details. If details missing, generate details."""

        verb = ctx.verb or "Update"
        details = ctx.details or self.suggested_details(ctx)
        return f"{verb} {details}".strip()

    def metadata_preview(self, ctx: NameContext, role: str = "<role>") -> str:
        """Return compact UDA preview line."""

        return (
            f"program={ctx.program} scope={ctx.scope} "
            f"taskid={self.normalized_taskid(ctx)} component={ctx.component} "
            f"worktype={ctx.worktype} role={role}"
        )

    def warning_for_taskid(self, ctx: NameContext) -> str:
        """Return warning text if taskid would be normalized away."""

        original = (ctx.taskid or "").strip()
        normalized = self.normalized_taskid(ctx)
        if original and original != "General" and normalized == "General":
            return (
                f"'{original}' repeats program/scope/component context, so taskid "
                "will be stored as General and omitted from the project path."
            )
        return ""

    def warning_for_verb_worktype(self, verb: str, worktype: str) -> str:
        """Warn if the chosen verb suggests a different worktype."""

        conflict_map = {
            "Build": {"CodeDevelopment", "Automation", "SoftwarePackaging"},
            "Publish": {"WebPublishing", "DataDissemination", "Publication", "DataReport"},
            "Forecast": {"Forecasting"},
            "Predict": {"DriftPrediction", "Forecasting"},
            "Validate": {"Validation", "Testing"},
            "Deploy": {"Deployment", "DeploymentAutomation", "WebPublishing"},
        }
        likely = conflict_map.get(verb)
        if likely and worktype not in likely:
            return (
                f"Verb '{verb}' often fits worktype {sorted(likely)}. "
                f"You selected '{worktype}', so reports will count this as {worktype}."
            )
        return ""
