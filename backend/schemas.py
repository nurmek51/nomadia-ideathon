from typing import Any, Literal

from pydantic import BaseModel


RequestCategory = Literal["medicine", "food", "water", "baby", "fuel"]
UrgencyLevel = Literal["low", "medium", "high", "critical"]
VulnerableGroup = Literal["child", "pregnant", "elderly", "chronic_patient", "none"]
CreatedByRole = Literal["resident", "ranger", "supplier", "dispatcher"]


class EmergencyRequestCreate(BaseModel):
    category: RequestCategory
    item: str
    urgency: UrgencyLevel
    vulnerable_group: VulnerableGroup
    village: str
    description: str
    created_by_role: CreatedByRole


class EmergencyRequestResponse(EmergencyRequestCreate):
    id: int
    status: str
    priority_score: int | None = None
    priority_level: str | None = None


class PrioritizeResponse(BaseModel):
    request_id: int
    priority_score: int
    priority_level: str
    ai_summary: str
    reasons: list[str]
    recommended_action: str


class RoutePoint(BaseModel):
    lat: float
    lng: float


class MatchResponse(BaseModel):
    request_id: int
    matched_node: str
    available_units: int
    delivery_type: str
    eta_minutes: int
    distance_km: float
    reason: str
    route: list[RoutePoint]


class DeliveryApproveResponse(BaseModel):
    delivery_id: int
    request_id: int
    status: str
    delivery_type: str
    eta_minutes: int
    current_step: str


class DeliveryCompleteResponse(BaseModel):
    delivery_id: int
    request_id: int
    status: str
    message: str


class DemoStateResponse(BaseModel):
    villages: list[dict[str, Any]]
    inventory: dict[str, dict[str, Any]]
    requests: list[dict[str, Any]]
    deliveries: list[dict[str, Any]]
    supplier_tasks: list[dict[str, Any]]
    issue_logs: list[dict[str, Any]]


class DashboardLowStockItem(BaseModel):
    node: str
    item: str
    quantity: int


class DashboardResponse(BaseModel):
    critical_requests: int
    pending_requests: int
    isolated_villages: int
    active_deliveries: int
    delivered_today: int
    low_stock_items: list[DashboardLowStockItem]


class RequestVerificationResponse(BaseModel):
    request_id: int
    status: str
    message: str


class SupplierAcceptRequest(BaseModel):
    request_id: int
    supplier_node: str


class SupplierAcceptResponse(BaseModel):
    request_id: int
    supplier_node: str
    status: str
    message: str


class InventoryResponse(BaseModel):
    nodes: dict[str, dict[str, Any]]


class InventoryUpdateRequest(BaseModel):
    node: str
    item: str
    quantity: int


class InventoryUpdateResponse(BaseModel):
    node: str
    item: str
    quantity: int
    message: str


class InventoryIssueRequest(BaseModel):
    node: str
    item: str
    quantity: int
    request_id: int | None = None
    recipient: str


class InventoryIssueResponse(BaseModel):
    node: str
    item: str
    quantity_issued: int
    remaining: int
    message: str


class AidCreditsResponse(BaseModel):
    resident_id: str
    credits: dict[str, int]


class SupplierTaskResponse(BaseModel):
    task_id: int
    request_id: int
    supplier_node: str
    item: str
    status: str
    message: str


class RequestStatusViewResponse(BaseModel):
    request_id: int
    item: str
    status: str
    priority_score: int | None = None
    priority_level: str | None = None
    matched_node: str | None = None
    delivery_type: str | None = None
    eta_minutes: int | None = None
    current_step: str | None = None
    route: list[RoutePoint] = []
