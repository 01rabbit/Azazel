from pathlib import Path

from azazel_core.qos import QoSPlan, TrafficClassifier


def test_classifier_and_plan():
    classifier = TrafficClassifier.from_config(
        {
            "medical": {"dest_cidrs": ["203.0.113.0/24"]},
            "ops": {"ports": [22]},
        }
    )
    bucket = classifier.match("203.0.113.10", 80)
    assert bucket == "medical"

    profiles = {
        "lte": {"uplink_kbps": 5000},
        "sat": {"uplink_kbps": 2000},
    }
    plan = QoSPlan.from_profile(profiles, "lte", Path("configs/tc/classes.htb"))
    data = plan.as_dict()
    assert data["profile"] == "lte"
    assert data["uplink_kbps"] == 5000
    classes = data["classes"]
    assert classes["medical"]["rate_kbps"] == 2000
    assert classes["medical"]["ceil_kbps"] == 5000
    assert classes["ops"]["rate_kbps"] == 1250
    assert classes["suspect"]["priority"] == 4
