from pathlib import Path

from azazel_core.ingest import CanaryTail, SuricataTail


def test_suricata_tail(tmp_path: Path):
    path = tmp_path / "eve.json"
    path.write_text('{"event_type": "alert", "alert": {"severity": 2}}\n')
    tail = SuricataTail(path=path)
    events = list(tail.stream())
    assert events[0].severity == 2


def test_canary_tail(tmp_path: Path):
    path = tmp_path / "canary.log"
    path.write_text('{"logtype": "login"}\n')
    tail = CanaryTail(path=path)
    events = list(tail.stream())
    assert events[0].name == "login"
