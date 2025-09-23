from pathlib import Path

import yaml

from azazel_core.config import AzazelConfig


def test_config_from_file(tmp_path: Path):
    data = {"node": "azazel"}
    path = tmp_path / "config.yaml"
    path.write_text(yaml.safe_dump(data))

    cfg = AzazelConfig.from_file(path)
    assert cfg.require("node") == "azazel"
    assert cfg.get("missing", "default") == "default"
