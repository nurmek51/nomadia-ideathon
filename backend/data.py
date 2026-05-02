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
    {
        "name": "Туркана, Кения",
        "risk_level": "high",
        "is_isolated": True,
        "lat": 3.12,
        "lng": 35.61,
    },
    {
        "name": "Гулу, Уганда",
        "risk_level": "medium",
        "is_isolated": False,
        "lat": 2.77,
        "lng": 32.30,
    },
    {
        "name": "Таматаве, Мадагаскар",
        "risk_level": "high",
        "is_isolated": True,
        "lat": -18.15,
        "lng": 49.40,
    },
    {
        "name": "Агадес, Нигер",
        "risk_level": "critical",
        "is_isolated": True,
        "lat": 16.97,
        "lng": 7.99,
    },
    {
        "name": "Санта-Роса, Перу",
        "risk_level": "medium",
        "is_isolated": True,
        "lat": -3.77,
        "lng": -73.24,
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
    "LifePod — Туркана": {
        "type": "lifepod",
        "village": "Туркана, Кения",
        "lat": 3.12,
        "lng": 35.61,
        "items": {
            "water_kits": 18,
            "food_packs": 34,
            "baby_food": 3,
            "fuel_cans": 2,
            "antibiotics": 1,
        },
    },
    "Аптека Гулу": {
        "type": "pharmacy",
        "village": "Гулу, Уганда",
        "lat": 2.77,
        "lng": 32.30,
        "items": {
            "insulin": 4,
            "antibiotics": 9,
            "paracetamol": 28,
            "medical_kits": 11,
        },
    },
    "Склад Таматаве": {
        "type": "warehouse",
        "village": "Таматаве, Мадагаскар",
        "lat": -18.15,
        "lng": 49.40,
        "items": {
            "water_kits": 60,
            "food_packs": 90,
            "baby_food": 20,
            "fuel_cans": 12,
        },
    },
    "Магазин Агадес": {
        "type": "shop",
        "village": "Агадес, Нигер",
        "lat": 16.97,
        "lng": 7.99,
        "items": {
            "food_packs": 46,
            "water_kits": 21,
            "fuel_cans": 15,
            "solar_lanterns": 10,
        },
    },
    "LifePod — Санта-Роса": {
        "type": "lifepod",
        "village": "Санта-Роса, Перу",
        "lat": -3.77,
        "lng": -73.24,
        "items": {
            "water_kits": 11,
            "food_packs": 24,
            "baby_food": 6,
            "insulin": 1,
        },
    },
}


INITIAL_AID_CREDITS = {
    "resident_demo": {
        "food": 30,
        "medicine": 15,
        "water": 10,
    },
    "resident_turkana": {
        "food": 22,
        "medicine": 9,
        "water": 18,
    },
    "resident_agades": {
        "food": 16,
        "medicine": 12,
        "water": 20,
    },
    "resident_tamatave": {
        "food": 28,
        "medicine": 10,
        "water": 14,
    },
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
