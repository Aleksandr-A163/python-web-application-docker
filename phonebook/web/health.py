"""Проверка доступности веб-приложения."""

from fastapi import APIRouter


router = APIRouter(tags=["health"])


@router.get("/ping/")
def ping() -> dict[str, str]:
    """Возвращает простой ответ для проверки работы HTTP-сервера."""

    return {"message": "pong"}
