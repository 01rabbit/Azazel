"""A minimal API dispatcher for Azazel."""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Callable, Dict

from .schemas import HealthResponse

Handler = Callable[[], Dict[str, str]]


@dataclass
class APIServer:
    routes: Dict[str, Handler] = field(default_factory=dict)

    def add_health_route(self, version: str) -> None:
        def handler() -> Dict[str, str]:
            return HealthResponse(status="ok", version=version).as_dict()

        self.routes["/health"] = handler

    def dispatch(self, path: str) -> Dict[str, str]:
        if path not in self.routes:
            raise KeyError(f"No handler for path {path}")
        return self.routes[path]()
