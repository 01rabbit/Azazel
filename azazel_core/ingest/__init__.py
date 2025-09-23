"""Log ingestion helpers."""

from .suricata_tail import SuricataTail
from .canary_tail import CanaryTail

__all__ = ["SuricataTail", "CanaryTail"]
