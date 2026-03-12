#!/usr/bin/env python3
"""
NIH RePORTER Search Tool
搜索 NIH 资助项目数据库，为 NSFC 申请提供参考

Usage:
    python nih_reporter_search.py "macrophage tumor immunity"
    python nih_reporter_search.py "NLRP3 inflammasome" --limit 10
    python nih_reporter_search.py "CAR-T therapy" --year 2023
    python nih_reporter_search.py "B cell colitis" --output ./results.md
"""

import argparse
import json
import os
import sys
from datetime import datetime

try:
    import requests
except ImportError:
    print("Error: requests library not installed. Run: pip install requests")
    sys.exit(1)


API_URL = "https://api.reporter.nih.gov/v2/projects/search"


def search_nih_projects(
    keywords: str, limit: int = 5, fiscal_year: int = None, only_active: bool = True
) -> dict:
    """
    Search NIH RePORTER database for funded projects.

    Args:
        keywords: Search terms (e.g., "macrophage tumor immunity")
        limit: Maximum number of results (default: 5, max: 10)
        fiscal_year: Filter by specific fiscal year (optional)
        only_active: Only return active projects (default: True)

    Returns:
        dict with 'total' count and 'projects' list
    """
    # Limit to max 10 for detailed results
    limit = min(limit, 10)

    criteria = {
        "advanced_text_search": {
            "operator": "and",
            "search_field": "all",
            "search_text": keywords,
        }
    }

    if fiscal_year:
        criteria["fiscal_years"] = [fiscal_year]

    if only_active:
        criteria["is_active"] = True

    payload = {"criteria": criteria, "offset": 0, "limit": limit}

    try:
        response = requests.post(API_URL, json=payload, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error: Failed to query NIH RePORTER API: {e}")
        sys.exit(1)


def format_project_markdown(
    project: dict, index: int, full_abstract: bool = False
) -> str:
    """Format a single project as Markdown."""
    lines = []
    lines.append(f"\n## {index}. {project.get('project_title', 'N/A')}\n")

    # Basic Info Table
    lines.append("| Field | Value |")
    lines.append("|-------|-------|")

    # PI Information
    pis = project.get("principal_investigators", [])
    if pis:
        pi_names = [pi.get("full_name", "N/A") for pi in pis]
        lines.append(f"| **PI** | {', '.join(pi_names)} |")

    # Organization
    org = project.get("organization", {})
    if org:
        org_name = org.get("org_name", "N/A")
        org_city = org.get("org_city", "")
        org_country = org.get("org_country", "")
        lines.append(f"| **Organization** | {org_name} ({org_city}, {org_country}) |")

    # Funding Info
    award_amount = project.get("award_amount")
    if award_amount:
        lines.append(f"| **Award Amount** | ${award_amount:,} |")

    # Project Period
    start_date = project.get("project_start_date", "")
    end_date = project.get("project_end_date", "")
    if start_date and end_date:
        start_year = start_date[:4] if start_date else "N/A"
        end_year = end_date[:4] if end_date else "N/A"
        lines.append(f"| **Project Period** | {start_year} - {end_year} |")

    # Activity Code (e.g., R01, R21)
    activity_code = project.get("activity_code", "")
    if activity_code:
        lines.append(f"| **Grant Type** | {activity_code} |")

    # Agency
    agency = project.get("agency_ic_admin", {})
    if agency:
        lines.append(
            f"| **Agency** | {agency.get('name', 'N/A')} ({agency.get('abbreviation', '')}) |"
        )

    # Project Number
    project_num = project.get("project_num", "")
    if project_num:
        lines.append(f"| **Project Number** | {project_num} |")
        appl_id = project.get("appl_id", "")
        lines.append(
            f"| **Details Link** | https://reporter.nih.gov/project-details/{appl_id} |"
        )

    lines.append("")

    # Abstract (full or truncated)
    abstract = project.get("abstract_text", "")
    if abstract:
        abstract = abstract.replace("\r\n", "\n").replace("\r", "\n").strip()
        if not full_abstract and len(abstract) > 500:
            abstract = abstract[:500] + "..."
        lines.append("### Abstract\n")
        lines.append(abstract)
        lines.append("")

    lines.append("---")

    return "\n".join(lines)


def generate_markdown_report(
    keywords: str, result: dict, output_path: str = None, full_abstract: bool = True
) -> str:
    """Generate a Markdown report of search results."""
    total = result.get("meta", {}).get("total", 0)
    projects = result.get("results", [])
    search_id = result.get("meta", {}).get("search_id", "")

    lines = []
    lines.append(f"# NIH RePORTER Search Results\n")
    lines.append(f"**Search Keywords**: {keywords}\n")
    lines.append(f"**Search Date**: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
    lines.append(f"**Total Projects Found**: {total:,}\n")
    lines.append(f"**Showing**: Top {len(projects)} projects\n")
    lines.append(
        f"**Web Link**: https://reporter.nih.gov/search/{search_id}/projects\n"
    )
    lines.append("---\n")

    for i, project in enumerate(projects, 1):
        lines.append(format_project_markdown(project, i, full_abstract))

    content = "\n".join(lines)

    # Save to file if output path specified
    if output_path:
        # Ensure directory exists
        output_dir = os.path.dirname(output_path)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)

        with open(output_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"✅ Report saved to: {output_path}")

    return content


def format_project_console(project: dict, index: int) -> str:
    """Format a single project for console display."""
    lines = []
    lines.append(f"\n{'=' * 60}")
    lines.append(f"[{index}] {project.get('project_title', 'N/A')}")
    lines.append(f"{'=' * 60}")

    pis = project.get("principal_investigators", [])
    if pis:
        pi_names = [pi.get("full_name", "N/A") for pi in pis]
        lines.append(f"PI: {', '.join(pi_names)}")

    org = project.get("organization", {})
    if org:
        lines.append(f"Org: {org.get('org_name', 'N/A')}")

    award_amount = project.get("award_amount")
    if award_amount:
        lines.append(f"Award: ${award_amount:,}")

    activity_code = project.get("activity_code", "")
    if activity_code:
        lines.append(f"Type: {activity_code}")

    abstract = project.get("abstract_text", "")
    if abstract:
        abstract = abstract.replace("\n", " ").strip()
        if len(abstract) > 300:
            abstract = abstract[:300] + "..."
        lines.append(f"Abstract: {abstract}")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Search NIH RePORTER for funded projects",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python nih_reporter_search.py "macrophage tumor immunity"
  python nih_reporter_search.py "NLRP3 inflammasome" --limit 10
  python nih_reporter_search.py "CAR-T therapy" --year 2024
  python nih_reporter_search.py "B cell colitis" --output ./nih_results.md
  python nih_reporter_search.py "tumor microenvironment" -n 5 -o results.md
        """,
    )
    parser.add_argument(
        "keywords", help='Search keywords (e.g., "macrophage tumor immunity")'
    )
    parser.add_argument(
        "--limit",
        "-n",
        type=int,
        default=5,
        help="Number of results (default: 5, max: 10)",
    )
    parser.add_argument(
        "--year", "-y", type=int, help="Filter by fiscal year (e.g., 2024)"
    )
    parser.add_argument(
        "--all", "-a", action="store_true", help="Include inactive projects"
    )
    parser.add_argument(
        "--output", "-o", type=str, help="Output path for Markdown report"
    )
    parser.add_argument("--json", action="store_true", help="Output raw JSON")

    args = parser.parse_args()

    # Limit to max 10
    limit = min(args.limit, 10)

    print(f'\n🔍 Searching NIH RePORTER for: "{args.keywords}"')
    print(f"   Limit: {limit} results")
    if args.year:
        print(f"   Fiscal Year: {args.year}")
    if args.output:
        print(f"   Output: {args.output}")
    print()

    result = search_nih_projects(
        keywords=args.keywords,
        limit=limit,
        fiscal_year=args.year,
        only_active=not args.all,
    )

    total = result.get("meta", {}).get("total", 0)
    projects = result.get("results", [])

    print(f"📊 Found {total:,} total projects, showing top {len(projects)}:\n")

    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
        return

    if not projects:
        print("No projects found.")
        return

    # Generate markdown report if output path specified
    if args.output:
        generate_markdown_report(args.keywords, result, args.output, full_abstract=True)

    # Console output
    for i, project in enumerate(projects, 1):
        print(format_project_console(project, i))

    print(f"\n{'=' * 60}")
    print(f"📌 Total matching projects in NIH database: {total:,}")
    print(
        f"🔗 Web search: https://reporter.nih.gov/search/{result.get('meta', {}).get('search_id', '')}/projects"
    )
    if args.output:
        print(f"📄 Full report saved to: {args.output}")
    print(f"{'=' * 60}\n")


if __name__ == "__main__":
    main()
