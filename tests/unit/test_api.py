from azazel_core.api import APIServer


def test_api_health_route():
    server = APIServer()
    server.add_health_route(version="1.2.3")
    payload = server.dispatch("/health")
    assert payload["status"] == "ok"
    assert payload["version"] == "1.2.3"
