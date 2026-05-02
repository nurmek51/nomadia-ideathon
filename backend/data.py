import copy
from typing import Any


INITIAL_VILLAGES = [
    {
        "name": "Горное село",
        "risk_level": "critical",
        "is_isolated": True,
        "lat": 43.24,
        "lng": 76.91,
    },
    {
        "name": "Аксу",
        "risk_level": "stable",
        "is_isolated": False,
        "lat": 43.31,
        "lng": 77.02,
    },
]


INITIAL_INVENTORY = {
    "LifePod — Горное село": {
        "type": "lifepod",
        "village": "Горное село",
        "lat": 43.24,
        "lng": 76.91,
        "items": {
            "insulin": 0,
            "water_kits": 42,
            "food_packs": 120,
            "antibiotics": 5,
            "baby_food": 8,
        },
    },
    "Аптека Аксу": {
        "type": "pharmacy",
        "village": "Аксу",
        "lat": 43.31,
        "lng": 77.02,
        "items": {
            "insulin": 6,
            "antibiotics": 14,
            "paracetamol": 40,
        },
    },
    "Магазин Аксу": {
        "type": "shop",
        "village": "Аксу",
        "lat": 43.30,
        "lng": 77.00,
        "items": {
            "food_packs": 280,
            "water_kits": 90,
            "baby_food": 25,
        },
    },
}


INITIAL_AID_CREDITS = {
    "resident_demo": {
        "food": 30,
        "medicine": 15,
        "water": 10,
    }
}


class Database:
    def __init__(self) -> None:
        self.reset()

    def reset(self) -> None:
        self.villages = copy.deepcopy(INITIAL_VILLAGES)
        self.inventory = copy.deepcopy(INITIAL_INVENTORY)
        self.aid_credits = copy.deepcopy(INITIAL_AID_CREDITS)
        self.requests: list[dict[str, Any]] = []
        self.deliveries: list[dict[str, Any]] = []
        self.supplier_tasks: list[dict[str, Any]] = []
        self.issue_logs: list[dict[str, Any]] = []
        self.matches: dict[int, dict[str, Any]] = {}
        self.request_counter = 1
        self.delivery_counter = 1
        self.supplier_task_counter = 1
        self.issue_log_counter = 1

    def add_request(self, request_data: dict[str, Any]) -> dict[str, Any]:
        record = copy.deepcopy(request_data)
        record["id"] = self.request_counter
        self.request_counter += 1
        self.requests.append(record)
        return record

    def get_request(self, request_id: int) -> dict[str, Any] | None:
        return next((req for req in self.requests if req["id"] == request_id), None)

    def save_match(self, request_id: int, match_data: dict[str, Any]) -> None:
        self.matches[request_id] = copy.deepcopy(match_data)

    def get_match(self, request_id: int) -> dict[str, Any] | None:
        match = self.matches.get(request_id)
        return copy.deepcopy(match) if match else None

    def add_delivery(self, delivery_data: dict[str, Any]) -> dict[str, Any]:
        record = copy.deepcopy(delivery_data)
        record["delivery_id"] = self.delivery_counter
        self.delivery_counter += 1
        self.deliveries.append(record)
        return record

    def get_delivery(self, delivery_id: int) -> dict[str, Any] | None:
        return next(
            (delivery for delivery in self.deliveries if delivery["delivery_id"] == delivery_id),
            None,
        )

    def add_supplier_task(self, task_data: dict[str, Any]) -> dict[str, Any]:
        record = copy.deepcopy(task_data)
        record["task_id"] = self.supplier_task_counter
        self.supplier_task_counter += 1
        self.supplier_tasks.append(record)
        return record

    def get_supplier_task_by_request(self, request_id: int) -> dict[str, Any] | None:
        return next((task for task in self.supplier_tasks if task["request_id"] == request_id), None)

    def add_issue_log(self, issue_data: dict[str, Any]) -> dict[str, Any]:
        record = copy.deepcopy(issue_data)
        record["issue_id"] = self.issue_log_counter
        self.issue_log_counter += 1
        self.issue_logs.append(record)
        return record


db = Database()
