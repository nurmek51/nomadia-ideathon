import json
import os
from functools import lru_cache

from pydantic import BaseModel


DEFAULT_GEMINI_MODEL = "gemini-2.5-flash"
DEFAULT_GEMINI_TIMEOUT_MS = 8000

PRIORITY_LABELS_RU = {
    "critical": "критическая",
    "high": "высокая",
    "medium": "средняя",
    "low": "низкая",
}


class PriorityNarrative(BaseModel):
    summary: str
    reasons: list[str]
    recommended_action: str


def build_fallback_narrative(
    request_data: dict,
    priority_level: str,
    reasons: list[str],
    score: int,
) -> PriorityNarrative:
    if (
        request_data["item"] == "insulin"
        and request_data["urgency"] == "critical"
        and request_data["vulnerable_group"] == "chronic_patient"
    ):
        summary = (
            "Заявка критическая: нужен инсулин для пациента с хроническим заболеванием, "
            "в локальном LifePod запас отсутствует, село изолировано."
        )
    else:
        summary = (
            f"Заявка {PRIORITY_LABELS_RU.get(priority_level, priority_level)}: нужен {request_data['item']}, срочность {request_data['urgency']}, "
            f"локальный контекст учтён в приоритизации."
        )

    recommended_action = "Медицинская доставка дроном" if score >= 80 else "Наземная доставка"
    return PriorityNarrative(
        summary=summary,
        reasons=reasons,
        recommended_action=recommended_action,
    )


@lru_cache(maxsize=1)
def get_gemini_client():
    if (
        os.getenv("Nomadia_DISABLE_LLM", "").lower() in {"1", "true", "yes"}
        or os.getenv("LIFEMESH_DISABLE_LLM", "").lower() in {"1", "true", "yes"}
    ):
        return None

    api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
    if not api_key:
        return None

    try:
        from google import genai
        from google.genai import types
    except ImportError:
        return None

    return genai.Client(
        api_key=api_key,
        http_options=types.HttpOptions(
            api_version="v1",
            timeout=int(os.getenv("GEMINI_TIMEOUT_MS", DEFAULT_GEMINI_TIMEOUT_MS)),
        ),
    )


def generate_priority_narrative(
    request_data: dict,
    priority_level: str,
    reasons: list[str],
    score: int,
) -> PriorityNarrative:
    fallback = build_fallback_narrative(request_data, priority_level, reasons, score)
    client = get_gemini_client()
    if client is None:
        return fallback

    try:
        from google.genai import types

        prompt = (
            "You are assisting an emergency logistics dashboard.\n"
            "The numerical score and status are already decided by rules and must not be changed.\n"
            "Return a concise Russian JSON object with:\n"
            "- summary: 1 sentence for operators\n"
            "- reasons: 3 to 5 short bullet-style strings in Russian\n"
            "- recommended_action: short operational label in Russian\n\n"
            f"Request:\n{json.dumps(request_data, ensure_ascii=False)}\n"
            f"Priority level: {priority_level}\n"
            f"Priority score: {score}\n"
            f"Reasons from rules: {json.dumps(reasons, ensure_ascii=False)}\n"
        )

        response = client.models.generate_content(
            model=os.getenv("GEMINI_MODEL", DEFAULT_GEMINI_MODEL),
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=PriorityNarrative,
                temperature=0.2,
            ),
        )
        text = getattr(response, "text", None)
        if not text:
            return fallback

        if hasattr(PriorityNarrative, "model_validate_json"):
            parsed = PriorityNarrative.model_validate_json(text)
        else:
            parsed = PriorityNarrative.parse_raw(text)

        if not parsed.reasons:
            parsed.reasons = reasons
        if not parsed.recommended_action:
            parsed.recommended_action = fallback.recommended_action
        return parsed
    except Exception:
        return fallback
