from strictdoc.core.project_config import ProjectConfig


def create_config() -> ProjectConfig:
    return ProjectConfig(
        project_title="String Calculator Spec",
        # This list replaces the defaults, so the first four are repeated.
        project_features=[
            "TABLE_SCREEN",
            "TRACEABILITY_SCREEN",
            "DEEP_TRACEABILITY_SCREEN",
            "SEARCH",
            "HTML2PDF",
        ],
        # Only the requirements are in sdoc so far. The Markdown files
        # (conventions, glossary, verification, old requirement .md) stay out.
        include_doc_paths=[
            "requirements/**.sdoc",
            "requirements/**.sgra",
            # Behavior tests, generated from features/*.feature by
            # tools/feature_to_sdoc.py (make export runs it first).
            "build/generated/**.sdoc",
        ],
        # Shared grammar, imported by every requirement document as
        # IMPORT_FROM_FILE: @requirements
        grammars={
            "@requirements": "requirements/requirements.sgra",
        },
    )
