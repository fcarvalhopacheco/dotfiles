from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path

from tasktw.templates import TaskTemplate


@dataclass
class AppConfig:
    """Application configuration loaded from JSON files."""

    config_dir: Path
    templates: dict[str, TaskTemplate]
    vocabulary: dict

    @classmethod
    def load(cls, config_dir: Path) -> "AppConfig":
        templates_path = config_dir / "templates.json"
        vocabulary_path = config_dir / "vocabulary.json"

        if not templates_path.exists():
            raise FileNotFoundError(f"Missing templates file: {templates_path}")
        if not vocabulary_path.exists():
            raise FileNotFoundError(f"Missing vocabulary file: {vocabulary_path}")

        templates_raw = json.loads(templates_path.read_text())
        vocabulary = json.loads(vocabulary_path.read_text())

        templates = {
            key: TaskTemplate.from_dict(key, data)
            for key, data in templates_raw["templates"].items()
        }

        return cls(config_dir=config_dir, templates=templates, vocabulary=vocabulary)

    def default_verb_for_worktype(self, worktype: str) -> str:
        return self.vocabulary.get("default_verb_for_worktype", {}).get(worktype, "Update")

    def clean_tag(self, tag: str) -> str:
        """Normalize tags to lower_snake_case.

        Tags are intentionally less formal than UDAs, but they should still be
        searchable and consistent. This also fixes common typos/aliases.
        """

        tag = str(tag).strip().lower()
        tag = tag.replace("+", "")
        tag = tag.replace("-", "_").replace(" ", "_")
        tag = re.sub(r"[^a-z0-9_]", "", tag)
        tag = re.sub(r"_+", "_", tag).strip("_")
        aliases = self.vocabulary.get("tag_aliases", {})
        return aliases.get(tag, tag)

    def clean_tags(self, tags: list[str]) -> list[str]:
        cleaned: list[str] = []
        for tag in tags:
            t = self.clean_tag(tag)
            if t and t not in cleaned:
                cleaned.append(t)
        return cleaned

    def known_tags(self) -> set[str]:
        tags: set[str] = set()
        for key, value in self.vocabulary.items():
            if key.startswith("tag_") and isinstance(value, list):
                tags.update(self.clean_tag(str(v)) for v in value)
        tags.update(self.clean_tag(str(v)) for v in self.vocabulary.get("tags_all", []))
        tags.update(self.clean_tag(str(v)) for v in self.vocabulary.get("tag_aliases", {}).values())
        return {t for t in tags if t}

    def apply_automatic_tags(self, tags: list[str], worktype: str, scope: str, component: str) -> list[str]:
        """Add useful tags derived from metadata, without duplicating."""

        result = list(tags)

        def add(tag: str) -> None:
            tag = self.clean_tag(tag)
            if tag and tag not in result:
                result.append(tag)

        if worktype in {"CodeDevelopment", "Automation", "Refactor", "Debugging", "Testing", "SoftwarePackaging"}:
            add("code")
        if worktype in {"Troubleshooting", "Debugging"}:
            add("troubleshooting")
        if worktype in {"ReportWriting", "DataReport", "PostCruiseReport"}:
            add("report")
        if scope == "AnnualReport" or component in {"YearReview", "PerformanceReview"}:
            add("year_review")
        if scope == "Mercator":
            add("mercator")
            add("copernicus")
        if component in {"Forecast", "DriftPrediction"}:
            add("forecast")
        if component == "Reanalysis":
            add("reanalysis")
        if component in {"PyGMT", "GMT"}:
            add("pygmt")

        return result

    def infer_role(self, program: str, scope: str, component: str, worktype: str) -> str:
        """Infer responsibility/hat from context.

        Role should not duplicate worktype. It answers: in what capacity are
        you doing this?
        """

        if program == "PERSONAL":
            return "Personal"

        if scope in {"Server", "Backup"} or worktype in {"SystemAdministration", "Backup"}:
            return "SystemAdministrator"

        if worktype in {
            "CodeDevelopment", "Automation", "Refactor", "Debugging", "Testing",
            "WebsiteUpdate", "SiteGeneration", "DeploymentAutomation",
            "SoftwarePackaging", "EnvironmentSetup",
        }:
            return "Developer"

        if worktype in {"DataDissemination", "Archive", "DataManagement", "DataReport", "WebPublishing"}:
            return "DataManager"

        if worktype in {
            "DataProcessing", "DataQC", "Calibration", "Analysis", "Plotting",
            "FigureGeneration", "Forecasting", "Reanalysis", "ModelComparison",
            "Validation", "DataVisualization", "DriftPrediction",
        }:
            return "Analyst"

        if scope == "Cruise" and component in {"CruisePlan", "DailyReport", "PostCruiseReport", "CruiseReport"}:
            return "ChiefScientist"

        if worktype in {"CruiseOperations", "CruisePreparation"}:
            return "MarineResearchSpecialist"

        if worktype in {"Training", "Learning"}:
            return "Mentor"

        if scope == "Mercator":
            # Planning a new project/blueprint is still part of your technical
            # research-specialist role until it becomes pure code or analysis.
            return "MarineResearchSpecialist"

        return "MarineResearchSpecialist"
