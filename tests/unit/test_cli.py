from pathlib import Path

import yaml

from azctl import cli


def test_cli_build_machine(tmp_path: Path):
    data = {"events": [{"name": "escalate", "severity": 100}]}
    config = tmp_path / "events.yaml"
    config.write_text(yaml.safe_dump(data))

    machine = cli.build_machine()
    daemon = cli.AzazelDaemon(
        machine=machine,
        scorer=cli.ScoreEvaluator(),
        decisions_log=tmp_path / "decisions.log",
    )
    daemon.process_events(cli.load_events(str(config)))
    assert machine.current_state.name == "lockdown"
    log_lines = (tmp_path / "decisions.log").read_text().strip().splitlines()
    assert log_lines
    assert "\"actions\"" in log_lines[0]
