from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

from backend.data import db
from backend.matching import is_supplier_node, match_request
from backend.priority import calculate_priority
from backend.schemas import (
    AidCreditsResponse,
    DashboardResponse,
    DeliveryApproveResponse,
    DeliveryCompleteResponse,
    DemoStateResponse,
    EmergencyRequestCreate,
    EmergencyRequestResponse,
    InventoryIssueRequest,
    InventoryIssueResponse,
    InventoryResponse,
    InventoryUpdateRequest,
    InventoryUpdateResponse,
    MatchResponse,
    PrioritizeResponse,
    RequestStatusViewResponse,
    RequestVerificationResponse,
    SupplierAcceptRequest,
    SupplierAcceptResponse,
    SupplierTaskResponse,
)

ROOT_DIR = Path(__file__).resolve().parent.parent
load_dotenv(ROOT_DIR / ".env")
load_dotenv(Path(__file__).resolve().parent / ".env")

app = FastAPI(title="Nomadia API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def model_to_dict(model) -> dict:
    if hasattr(model, "model_dump"):
        return model.model_dump()
    return model.dict()


def get_request_or_404(request_id: int) -> dict:
    request_data = db.get_request(request_id)
    if request_data is None:
        raise HTTPException(status_code=404, detail="Request not found")
    return request_data


def get_delivery_or_404(delivery_id: int) -> dict:
    delivery = db.get_delivery(delivery_id)
    if delivery is None:
        raise HTTPException(status_code=404, detail="Delivery not found")
    return delivery


def get_node_or_404(node_name: str) -> dict:
    node = db.inventory.get(node_name)
    if node is None:
        raise HTTPException(status_code=404, detail="Node not found")
    return node


def ensure_item_exists(node: dict, item_name: str) -> None:
    if item_name not in node["items"]:
        raise HTTPException(status_code=404, detail="Item not found")


def create_supplier_task_if_needed(request_data: dict, match_data: dict) -> None:
    matched_node = match_data["matched_node"]
    node = db.inventory.get(matched_node)
    if node is None or not is_supplier_node(node):
        return

    existing_task = db.get_supplier_task_by_request(request_data["id"])
    if existing_task:
        existing_task["supplier_node"] = matched_node
        existing_task["status"] = "pending"
        return

    db.add_supplier_task(
        {
            "request_id": request_data["id"],
            "supplier_node": matched_node,
            "item": request_data["item"],
            "status": "pending",
            "message": "Ожидается подтверждение поставщика",
        }
    )


def build_delivery_step(match_data: dict) -> str:
    matched_node = match_data["matched_node"]
    if match_data["delivery_type"] == "drone":
        if matched_node == "Аптека Аксу":
            return "Дрон вылетел из аптеки Аксу"
        return f"Дрон вылетел из {matched_node}"
    if match_data["delivery_type"] == "ranger_pickup":
        return "Рейнджер забирает ресурс из локального LifePod"
    if match_data["delivery_type"] == "vehicle":
        return f"Машина выехала из {matched_node}"
    return "Подтверждена внешняя поставка"


def decrement_inventory_for_delivery(request_data: dict, match_data: dict) -> None:
    matched_node = match_data["matched_node"]
    if matched_node not in db.inventory:
        return

    node = db.inventory[matched_node]
    requested_item = request_data["item"]
    available_units = node["items"].get(requested_item, 0)
    if available_units <= 0:
        raise HTTPException(status_code=409, detail="Item is no longer available")
    node["items"][requested_item] -= 1


def get_delivery_by_request_id(request_id: int) -> dict | None:
    return next((delivery for delivery in db.deliveries if delivery["request_id"] == request_id), None)


def build_request_status_view(request_data: dict) -> dict:
    match_data = db.get_match(request_data["id"])
    delivery = get_delivery_by_request_id(request_data["id"])
    return {
        "request_id": request_data["id"],
        "item": request_data["item"],
        "status": request_data["status"],
        "priority_score": request_data.get("priority_score"),
        "priority_level": request_data.get("priority_level"),
        "matched_node": None if match_data is None else match_data["matched_node"],
        "delivery_type": (
            delivery["delivery_type"]
            if delivery is not None
            else None if match_data is None else match_data["delivery_type"]
        ),
        "eta_minutes": (
            delivery["eta_minutes"]
            if delivery is not None
            else None if match_data is None else match_data["eta_minutes"]
        ),
        "current_step": None if delivery is None else delivery["current_step"],
        "route": [] if match_data is None else match_data["route"],
    }


@app.get("/health")
def health_check() -> dict:
    return {"status": "ok", "service": "Nomadia API"}


@app.get("/demo/state", response_model=DemoStateResponse)
def get_demo_state() -> dict:
    return {
        "villages": db.villages,
        "inventory": db.inventory,
        "requests": db.requests,
        "deliveries": db.deliveries,
        "supplier_tasks": db.supplier_tasks,
        "issue_logs": db.issue_logs,
    }


@app.post("/demo/reset")
def reset_demo() -> dict:
    db.reset()
    return {"message": "Демо сброшено"}


@app.post("/requests", response_model=EmergencyRequestResponse)
def create_request(payload: EmergencyRequestCreate) -> dict:
    village_exists = any(village["name"] == payload.village for village in db.villages)
    if not village_exists:
        raise HTTPException(status_code=400, detail="Unknown village")

    request_data = model_to_dict(payload)
    request_data["status"] = "created"
    request_data["priority_score"] = None
    request_data["priority_level"] = None
    return db.add_request(request_data)


@app.get("/requests", response_model=list[EmergencyRequestResponse])
def list_requests(
    role: str | None = Query(default=None),
    status: str | None = Query(default=None),
    village: str | None = Query(default=None),
) -> list[dict]:
    results = db.requests
    if role:
        results = [request for request in results if request["created_by_role"] == role]
    if status:
        results = [request for request in results if request["status"] == status]
    if village:
        results = [request for request in results if request["village"] == village]
    return results


@app.get("/requests/{request_id}", response_model=EmergencyRequestResponse)
def get_request(request_id: int) -> dict:
    return get_request_or_404(request_id)


@app.get("/requests/{request_id}/status-view", response_model=RequestStatusViewResponse)
def get_request_status_view(request_id: int) -> dict:
    request_data = get_request_or_404(request_id)
    return build_request_status_view(request_data)


@app.get("/resident/{resident_id}/latest-request", response_model=RequestStatusViewResponse)
def get_latest_resident_request(resident_id: str) -> dict:
    if resident_id != "resident_demo":
        raise HTTPException(status_code=404, detail="Resident not found")

    resident_requests = [
        request
        for request in db.requests
        if request["created_by_role"] == "resident"
    ]
    if not resident_requests:
        raise HTTPException(status_code=404, detail="Resident has no requests")

    return build_request_status_view(resident_requests[-1])


@app.post("/requests/{request_id}/verify", response_model=RequestVerificationResponse)
def verify_request(request_id: int) -> dict:
    request_data = get_request_or_404(request_id)
    request_data["status"] = "verified"
    return {
        "request_id": request_id,
        "status": "verified",
        "message": "Заявка подтверждена рейнджером",
    }


@app.post("/requests/{request_id}/prioritize", response_model=PrioritizeResponse)
def prioritize_request(request_id: int) -> dict:
    request_data = get_request_or_404(request_id)
    priority_data = calculate_priority(request_data, db)
    request_data["priority_score"] = priority_data["priority_score"]
    request_data["priority_level"] = priority_data["priority_level"]
    request_data["status"] = "prioritized"
    return priority_data


@app.post("/requests/{request_id}/match", response_model=MatchResponse)
def match_emergency_request(request_id: int) -> dict:
    request_data = get_request_or_404(request_id)
    match_data = match_request(request_data, db)
    db.save_match(request_id, match_data)
    request_data["status"] = "matched"
    create_supplier_task_if_needed(request_data, match_data)
    return match_data


@app.post("/supplier/accept-request", response_model=SupplierAcceptResponse)
def supplier_accept_request(payload: SupplierAcceptRequest) -> dict:
    request_data = get_request_or_404(payload.request_id)
    supplier_node = get_node_or_404(payload.supplier_node)
    if not is_supplier_node(supplier_node):
        raise HTTPException(status_code=400, detail="Node is not a supplier")

    supplier_task = db.get_supplier_task_by_request(payload.request_id)
    if supplier_task is None:
        supplier_task = db.add_supplier_task(
            {
                "request_id": payload.request_id,
                "supplier_node": payload.supplier_node,
                "item": request_data["item"],
                "status": "pending",
                "message": "Ожидается подтверждение поставщика",
            }
        )

    supplier_task["supplier_node"] = payload.supplier_node
    supplier_task["status"] = "supplier_confirmed"
    supplier_task["message"] = "Поставщик подтвердил наличие ресурса"
    request_data["status"] = "supplier_confirmed"

    return {
        "request_id": payload.request_id,
        "supplier_node": payload.supplier_node,
        "status": "supplier_confirmed",
        "message": "Поставщик подтвердил наличие ресурса",
    }


@app.get("/supplier/tasks", response_model=list[SupplierTaskResponse])
def get_supplier_tasks(
    supplier_node: str | None = Query(default=None),
    status: str | None = Query(default=None),
) -> list[dict]:
    tasks = db.supplier_tasks
    if supplier_node:
        tasks = [task for task in tasks if task["supplier_node"] == supplier_node]
    if status:
        tasks = [task for task in tasks if task["status"] == status]
    return tasks


@app.post("/requests/{request_id}/approve-delivery", response_model=DeliveryApproveResponse)
def approve_delivery(request_id: int) -> dict:
    request_data = get_request_or_404(request_id)

    existing_delivery = next(
        (delivery for delivery in db.deliveries if delivery["request_id"] == request_id),
        None,
    )
    if existing_delivery:
        return existing_delivery

    match_data = db.get_match(request_id)
    if match_data is None:
        match_data = match_request(request_data, db)
        db.save_match(request_id, match_data)
        create_supplier_task_if_needed(request_data, match_data)

    decrement_inventory_for_delivery(request_data, match_data)
    delivery = db.add_delivery(
        {
            "request_id": request_id,
            "status": "in_delivery",
            "delivery_type": match_data["delivery_type"],
            "eta_minutes": match_data["eta_minutes"],
            "current_step": build_delivery_step(match_data),
        }
    )
    request_data["status"] = "in_delivery"
    return delivery


@app.post("/deliveries/{delivery_id}/complete", response_model=DeliveryCompleteResponse)
def complete_delivery(delivery_id: int) -> dict:
    delivery = get_delivery_or_404(delivery_id)
    request_data = get_request_or_404(delivery["request_id"])
    delivery["status"] = "delivered"
    request_data["status"] = "delivered"
    return {
        "delivery_id": delivery["delivery_id"],
        "request_id": delivery["request_id"],
        "status": "delivered",
        "message": "Доставка завершена",
    }


@app.get("/inventory", response_model=InventoryResponse)
def get_inventory() -> dict:
    return {"nodes": db.inventory}


@app.patch("/inventory/update", response_model=InventoryUpdateResponse)
def update_inventory(payload: InventoryUpdateRequest) -> dict:
    node = get_node_or_404(payload.node)
    node["items"][payload.item] = payload.quantity
    return {
        "node": payload.node,
        "item": payload.item,
        "quantity": payload.quantity,
        "message": "Запасы обновлены",
    }


@app.post("/inventory/issue", response_model=InventoryIssueResponse)
def issue_inventory(payload: InventoryIssueRequest) -> dict:
    node = get_node_or_404(payload.node)
    ensure_item_exists(node, payload.item)
    if node["items"][payload.item] < payload.quantity:
        raise HTTPException(status_code=409, detail="Not enough stock")

    node["items"][payload.item] -= payload.quantity
    db.add_issue_log(
        {
            "node": payload.node,
            "item": payload.item,
            "quantity": payload.quantity,
            "request_id": payload.request_id,
            "recipient": payload.recipient,
        }
    )

    if payload.request_id is not None:
        request_data = get_request_or_404(payload.request_id)
        request_data["status"] = "delivered"

    return {
        "node": payload.node,
        "item": payload.item,
        "quantity_issued": payload.quantity,
        "remaining": node["items"][payload.item],
        "message": "Ресурс выдан. Остатки обновлены.",
    }


@app.get("/aid-credits/{resident_id}", response_model=AidCreditsResponse)
def get_aid_credits(resident_id: str) -> dict:
    credits = db.aid_credits.get(resident_id)
    if credits is None:
        raise HTTPException(status_code=404, detail="Resident not found")
    return {"resident_id": resident_id, "credits": credits}


@app.get("/dashboard", response_model=DashboardResponse)
def get_dashboard() -> dict:
    critical_requests = sum(
        1
        for request_data in db.requests
        if request_data.get("priority_level") == "critical" and request_data["status"] != "delivered"
    )
    pending_requests = sum(
        1
        for request_data in db.requests
        if request_data["status"]
        in {"created", "verified", "prioritized", "matched", "supplier_confirmed"}
    )
    isolated_villages = sum(1 for village in db.villages if village["is_isolated"])
    active_deliveries = sum(
        1 for delivery in db.deliveries if delivery["status"] == "in_delivery"
    )
    delivered_today = sum(1 for delivery in db.deliveries if delivery["status"] == "delivered")

    low_stock_items = []
    for node_name, node in db.inventory.items():
        for item_name, quantity in node["items"].items():
            if quantity <= 0:
                low_stock_items.append(
                    {"node": node_name, "item": item_name, "quantity": quantity}
                )

    return {
        "critical_requests": critical_requests,
        "pending_requests": pending_requests,
        "isolated_villages": isolated_villages,
        "active_deliveries": active_deliveries,
        "delivered_today": delivered_today,
        "low_stock_items": low_stock_items,
    }
