from backend.data import Database
from backend.llm import generate_priority_narrative


def calculate_priority(request_data: dict, db: Database) -> dict:
    score = 0
    reasons: list[str] = []

    if request_data["category"] == "medicine":
        score += 25
        reasons.append("Критически важная медицинская заявка")

    if request_data["urgency"] == "critical":
        score += 25
        reasons.append("Высокая срочность")

    if request_data["vulnerable_group"] != "none":
        score += 20
        reasons.append("Пациент из уязвимой группы")

    local_lifepod = next(
        (
            node
            for node in db.inventory.values()
            if node["village"] == request_data["village"] and node["type"] == "lifepod"
        ),
        None,
    )
    local_quantity = (
        0 if local_lifepod is None else local_lifepod["items"].get(request_data["item"], 0)
    )
    if local_quantity == 0:
        score += 15
        reasons.append("В локальном LifePod нет нужного ресурса")

    village = next((item for item in db.villages if item["name"] == request_data["village"]), None)
    if village and village["is_isolated"]:
        score += 15
        reasons.append("Село временно изолировано")

    score = min(score, 100)

    if score >= 85:
        priority_level = "critical"
    elif score >= 70:
        priority_level = "high"
    elif score >= 40:
        priority_level = "medium"
    else:
        priority_level = "low"

    narrative = generate_priority_narrative(request_data, priority_level, reasons, score)

    return {
        "request_id": request_data["id"],
        "priority_score": score,
        "priority_level": priority_level,
        "ai_summary": narrative.summary,
        "reasons": narrative.reasons,
        "recommended_action": narrative.recommended_action,
    }
