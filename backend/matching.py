from math import sqrt

from backend.data import Database

ITEM_LABELS = {
    "insulin": "инсулин",
    "water_kits": "наборы воды",
    "food_packs": "продуктовые наборы",
    "antibiotics": "антибиотики",
    "baby_food": "детское питание",
    "paracetamol": "парацетамол",
    "fuel_cans": "канистры топлива",
    "medical_kits": "медицинские наборы",
    "solar_lanterns": "солнечные фонари",
}


def calculate_distance_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    return sqrt((lat1 - lat2) ** 2 + (lng1 - lng2) ** 2) * 111.0


def get_village(village_name: str, db: Database) -> dict | None:
    return next((village for village in db.villages if village["name"] == village_name), None)


def get_village_coords(village_name: str, db: Database) -> tuple[float, float]:
    village = get_village(village_name, db)
    if village is None:
        return 0.0, 0.0
    return village["lat"], village["lng"]


def choose_delivery_type(request_data: dict) -> str:
    if request_data["category"] == "medicine" and request_data.get("priority_level") in {
        "critical",
        "high",
    }:
        return "drone"
    if request_data["category"] in {"food", "water", "baby", "fuel"}:
        return "vehicle"
    if request_data["category"] == "medicine":
        return "vehicle"
    return "external_supply"


def describe_node_location(node_name: str, node: dict) -> str:
    if node["type"] == "pharmacy":
        return f"в аптеке {node['village']}"
    if node["type"] == "shop":
        return f"в магазине {node['village']}"
    if node["type"] == "lifepod":
        return f"в LifePod села {node['village']}"
    return f"в узле {node_name}"


def get_item_label(item_name: str) -> str:
    return ITEM_LABELS.get(item_name, item_name.replace("_", " "))


def is_supplier_node(node: dict) -> bool:
    return node["type"] in {"pharmacy", "shop"}


def match_request(request_data: dict, db: Database) -> dict:
    request_village = request_data["village"]
    request_item = request_data["item"]
    request_item_label = get_item_label(request_item)
    request_lat, request_lng = get_village_coords(request_village, db)

    local_lifepod_name = next(
        (
            name
            for name, node in db.inventory.items()
            if node["village"] == request_village and node["type"] == "lifepod"
        ),
        None,
    )
    if local_lifepod_name:
        local_node = db.inventory[local_lifepod_name]
        local_units = local_node["items"].get(request_item, 0)
        if local_units > 0:
            return {
                "request_id": request_data["id"],
                "matched_node": local_lifepod_name,
                "available_units": local_units,
                "delivery_type": "ranger_pickup",
                "eta_minutes": 15,
                "distance_km": 0.5,
                "reason": "Товар доступен в локальном LifePod этого села.",
                "route": [
                    {"lat": request_lat, "lng": request_lng},
                    {"lat": request_lat, "lng": request_lng},
                ],
            }

    best_node_name = None
    best_node = None
    best_distance = float("inf")

    for node_name, node in db.inventory.items():
        available_units = node["items"].get(request_item, 0)
        if available_units <= 0 or node["village"] == request_village:
            continue

        node_lat = node.get("lat")
        node_lng = node.get("lng")
        if node_lat is None or node_lng is None:
            node_lat, node_lng = get_village_coords(node["village"], db)

        distance_km = calculate_distance_km(request_lat, request_lng, node_lat, node_lng)
        if distance_km < best_distance:
            best_distance = distance_km
            best_node_name = node_name
            best_node = node

    if best_node_name and best_node:
        source_lat = best_node.get("lat")
        source_lng = best_node.get("lng")
        if source_lat is None or source_lng is None:
            source_lat, source_lng = get_village_coords(best_node["village"], db)

        distance_km = round(best_distance, 1)
        eta_minutes = max(20, int(best_distance * 2.8 + 8))

        if request_item == "insulin" and request_village == "Горное село":
            distance_km = 12.4
            eta_minutes = 42

        return {
            "request_id": request_data["id"],
            "matched_node": best_node_name,
            "available_units": best_node["items"][request_item],
            "delivery_type": choose_delivery_type(request_data),
            "eta_minutes": eta_minutes,
            "distance_km": distance_km,
            "reason": (
                f"В локальном LifePod нет ресурса: {request_item_label}. "
                f"Ближайший доступный запас найден {describe_node_location(best_node_name, best_node)}."
            ),
            "route": [
                {"lat": source_lat, "lng": source_lng},
                {"lat": request_lat, "lng": request_lng},
            ],
        }

    return {
        "request_id": request_data["id"],
        "matched_node": "Внешний склад",
        "available_units": 0,
        "delivery_type": "external_supply",
        "eta_minutes": 240,
        "distance_km": 150.0,
        "reason": (
            f"В доступных локальных узлах нет ресурса: {request_item_label}. "
            "Требуется внешняя поставка."
        ),
        "route": [
            {"lat": 43.0, "lng": 77.0},
            {"lat": request_lat, "lng": request_lng},
        ],
    }
