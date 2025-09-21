#!/usr/bin/env python3
"""Render the Suricata configuration template from azazel.yaml."""
from __future__ import annotations

import argparse
import re
from pathlib import Path

import yaml


PLACEHOLDER = re.compile(r"\{\{\s*ruleset\s*\|\s*default\('balanced'\)\s*\}\}")


def render(template: str, ruleset: str) -> str:
    return PLACEHOLDER.sub(ruleset, template)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("config", help="Path to azazel.yaml")
    parser.add_argument("template", help="Path to Suricata template")
    parser.add_argument("--output", default="-", help="Output file or '-' for stdout")
    args = parser.parse_args(argv)

    cfg = yaml.safe_load(Path(args.config).read_text())
    ruleset = cfg.get("soc", {}).get("suricata_ruleset", "balanced")
    template = Path(args.template).read_text()
    rendered = render(template, ruleset)

    if args.output == "-":
        print(rendered)
    else:
        Path(args.output).write_text(rendered)
    return 0


if __name__ == "__main__":  # pragma: no cover - CLI entry point
    raise SystemExit(main())
