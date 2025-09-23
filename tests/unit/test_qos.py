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

    plan = QoSPlan.from_matches([bucket, classifier.match("198.51.100.5", 22)])
    commands = plan.as_dict()["commands"]
    assert commands[0]["class"] == "medical"
    assert commands[1]["class"] == "ops"
