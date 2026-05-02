import json
import os
import subprocess
import time
import unittest
import urllib.error
import urllib.request


BASE_URL = "http://127.0.0.1:8002"


class DemoFlowTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        env = os.environ.copy()
        env["Nomadia_DISABLE_LLM"] = "1"
        cls.server = subprocess.Popen(
            [
                os.path.join(".venv", "bin", "python"),
                "-m",
                "uvicorn",
                "main:app",
                "--host",
                "127.0.0.1",
                "--port",
                "8002",
            ],
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        for _ in range(30):
            try:
                response = cls.request("GET", "/health")
                if response["status"] == "ok":
                    return
            except Exception:
                time.sleep(0.5)

        raise RuntimeError("Server did not start in time")

    @classmethod
    def tearDownClass(cls) -> None:
        cls.server.terminate()
        try:
            cls.server.wait(timeout=10)
        except subprocess.TimeoutExpired:
            cls.server.kill()
            cls.server.wait(timeout=5)

    @staticmethod
    def request(method: str, path: str, body: dict | None = None) -> dict:
        data = None
        headers = {}
        if body is not None:
            data = json.dumps(body).encode("utf-8")
            headers["Content-Type"] = "application/json"

        req = urllib.request.Request(BASE_URL + path, data=data, headers=headers, method=method)
        with urllib.request.urlopen(req, timeout=20) as response:
            return json.loads(response.read().decode("utf-8"))

    @staticmethod
    def request_expect_error(method: str, path: str, body: dict | None = None) -> tuple[int, dict]:
        data = None
        headers = {}
        if body is not None:
            data = json.dumps(body).encode("utf-8")
            headers["Content-Type"] = "application/json"

        req = urllib.request.Request(BASE_URL + path, data=data, headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=20) as response:
                return response.status, json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as error:
            payload = json.loads(error.read().decode("utf-8"))
            return error.code, payload

    def setUp(self) -> None:
        reset_response = self.request("POST", "/demo/reset")
        self.assertEqual(reset_response["message"], "Демо сброшено")

    def test_full_demo_flow(self) -> None:
        created_request = self.request(
            "POST",
            "/requests",
            {
                "category": "medicine",
                "item": "insulin",
                "urgency": "critical",
                "vulnerable_group": "chronic_patient",
                "village": "Горное село",
                "description": "Пациенту срочно нужен инсулин",
                "created_by_role": "resident",
            },
        )
        self.assertEqual(created_request["status"], "created")
        self.assertEqual(created_request["priority_level"], None)

        request_id = created_request["id"]

        request_list = self.request("GET", "/requests")
        self.assertEqual(len(request_list), 1)

        request_detail = self.request("GET", f"/requests/{request_id}")
        self.assertEqual(request_detail["id"], request_id)

        resident_latest_created = self.request("GET", "/resident/resident_demo/latest-request")
        self.assertEqual(resident_latest_created["status"], "created")
        self.assertEqual(resident_latest_created["request_id"], request_id)

        verified = self.request("POST", f"/requests/{request_id}/verify")
        self.assertEqual(verified["status"], "verified")

        prioritized = self.request("POST", f"/requests/{request_id}/prioritize")
        self.assertEqual(prioritized["priority_score"], 100)
        self.assertEqual(prioritized["priority_level"], "critical")
        self.assertTrue(prioritized["ai_summary"])

        matched = self.request("POST", f"/requests/{request_id}/match")
        self.assertEqual(matched["matched_node"], "Аптека Аксу")
        self.assertEqual(matched["delivery_type"], "drone")
        self.assertEqual(matched["eta_minutes"], 42)

        status_view_after_match = self.request("GET", f"/requests/{request_id}/status-view")
        self.assertEqual(status_view_after_match["matched_node"], "Аптека Аксу")
        self.assertEqual(status_view_after_match["delivery_type"], "drone")
        self.assertEqual(status_view_after_match["eta_minutes"], 42)

        demo_state = self.request("GET", "/demo/state")
        self.assertEqual(len(demo_state["supplier_tasks"]), 1)
        self.assertEqual(demo_state["supplier_tasks"][0]["supplier_node"], "Аптека Аксу")

        supplier_tasks = self.request("GET", "/supplier/tasks?supplier_node=%D0%90%D0%BF%D1%82%D0%B5%D0%BA%D0%B0%20%D0%90%D0%BA%D1%81%D1%83")
        self.assertEqual(len(supplier_tasks), 1)
        self.assertEqual(supplier_tasks[0]["request_id"], request_id)

        approve_blocked_status, approve_blocked_payload = self.request_expect_error(
            "POST",
            f"/requests/{request_id}/approve-delivery",
        )
        self.assertEqual(approve_blocked_status, 409)
        self.assertEqual(
            approve_blocked_payload["detail"],
            "Сначала поставщик должен подтвердить наличие ресурса",
        )

        supplier_confirmed = self.request(
            "POST",
            "/supplier/accept-request",
            {"request_id": request_id, "supplier_node": "Аптека Аксу"},
        )
        self.assertEqual(supplier_confirmed["status"], "supplier_confirmed")

        inventory = self.request("GET", "/inventory")
        self.assertIn("LifePod — Горное село", inventory["nodes"])

        updated_inventory = self.request(
            "PATCH",
            "/inventory/update",
            {"node": "Аптека Аксу", "item": "insulin", "quantity": 6},
        )
        self.assertEqual(updated_inventory["quantity"], 6)

        credits = self.request("GET", "/aid-credits/resident_demo")
        self.assertEqual(credits["credits"]["medicine"], 15)

        approved = self.request("POST", f"/requests/{request_id}/approve-delivery")
        self.assertEqual(approved["status"], "in_delivery")
        self.assertEqual(approved["delivery_type"], "drone")

        resident_latest_delivery = self.request("GET", "/resident/resident_demo/latest-request")
        self.assertEqual(resident_latest_delivery["status"], "in_delivery")
        self.assertEqual(resident_latest_delivery["current_step"], "Дрон вылетел из аптеки Аксу")

        dashboard = self.request("GET", "/dashboard")
        self.assertEqual(dashboard["critical_requests"], 1)
        self.assertEqual(dashboard["pending_requests"], 0)
        self.assertGreaterEqual(dashboard["isolated_villages"], 5)
        self.assertEqual(dashboard["active_deliveries"], 1)
        self.assertEqual(dashboard["delivered_today"], 0)

        completed = self.request("POST", f"/deliveries/{approved['delivery_id']}/complete")
        self.assertEqual(completed["status"], "delivered")

        issue_result = self.request(
            "POST",
            "/inventory/issue",
            {
                "node": "LifePod — Горное село",
                "item": "food_packs",
                "quantity": 3,
                "request_id": None,
                "recipient": "Семья #12",
            },
        )
        self.assertEqual(issue_result["remaining"], 117)

        final_state = self.request("GET", "/demo/state")
        self.assertEqual(final_state["requests"][0]["status"], "delivered")
        self.assertEqual(final_state["deliveries"][0]["status"], "delivered")
        self.assertEqual(len(final_state["issue_logs"]), 1)


if __name__ == "__main__":
    unittest.main()
