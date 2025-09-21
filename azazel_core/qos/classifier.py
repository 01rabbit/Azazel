"""Classify network flows into QoS buckets."""
from __future__ import annotations

from dataclasses import dataclass
from ipaddress import ip_address, ip_network
from typing import Dict, Iterable, List


@dataclass
class QoSBucket:
    name: str
    cidrs: List[str]
    ports: List[int]


@dataclass
class TrafficClassifier:
    """Very small helper used by unit tests to bucket flows."""

    buckets: Dict[str, QoSBucket]

    def match(self, source_ip: str, dest_port: int) -> str:
        address = ip_address(source_ip)
        for bucket in self.buckets.values():
            if any(address in ip_network(cidr) for cidr in bucket.cidrs):
                return bucket.name
            if dest_port in bucket.ports:
                return bucket.name
        return "best-effort"

    @classmethod
    def from_config(cls, config: Dict[str, Dict[str, Iterable]]) -> "TrafficClassifier":
        buckets = {
            name: QoSBucket(
                name=name,
                cidrs=[str(c) for c in cfg.get("dest_cidrs", [])],
                ports=[int(p) for p in cfg.get("ports", [])],
            )
            for name, cfg in config.items()
        }
        return cls(buckets=buckets)
