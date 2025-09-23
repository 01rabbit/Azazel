from azazel_core.actions import BlockAction, DelayAction, RedirectAction, ShapeAction


def test_delay_action_plan():
    action = DelayAction(delay_ms=150)
    plan = list(action.plan("192.0.2.10"))
    assert plan[0].parameters["delay"] == "150ms"


def test_block_action_plan():
    action = BlockAction()
    plan = list(action.plan("198.51.100.2"))
    assert plan[0].parameters["value"] == "198.51.100.2"


def test_redirect_action_plan():
    action = RedirectAction(target_host="192.0.2.1")
    plan = list(action.plan("203.0.113.50"))
    assert plan[0].parameters["redirect"] == "192.0.2.1"


def test_shape_action_plan():
    action = ShapeAction(rate_kbps=512)
    plan = list(action.plan("wan0"))
    assert plan[0].parameters["rate"] == "512kbps"
