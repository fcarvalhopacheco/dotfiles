#!/usr/bin/env python3
from tasktw.name_builder import NameBuilder, NameContext

nb = NameBuilder()
ctx = NameContext(
    program="HOT",
    scope="Mercator",
    taskid="Mercator",
    component="Blueprint",
    worktype="Planning",
    verb="Build",
)
print("Warning:", nb.warning_for_taskid(ctx))
print("Project:", nb.project(ctx))
print("Description:", nb.description(ctx))
print("Metadata:", nb.metadata_preview(ctx, role="MarineResearchSpecialist"))
