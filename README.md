# Телефонный справочник в Docker

Учебное гибридное приложение для управления контактами на Python. Проект
поддерживает консольный интерфейс, HTML-страницы на FastAPI и Jinja2, а также
JSON API. Контакты сохраняются в файле `contacts.json`.

В основе проекта лежит единая предметная модель: CLI и веб-интерфейс используют
один класс `PhoneBook` и не дублируют правила работы с контактами.

Это отдельный репозиторий на основе
[python-web-application](https://github.com/Aleksandr-A163/python-web-application)
с сохранённой историей исходного проекта.

## Запуск в Docker

Установите Docker с поддержкой Linux-контейнеров (например, Docker Desktop).
Локальная установка Python для этого способа запуска не требуется.

```bash
git clone https://github.com/Aleksandr-A163/python-web-application-docker.git
cd python-web-application-docker
docker build -t python-web-application-docker .
docker run --rm --name phonebook-web -p 8000:8000 python-web-application-docker
```

Откройте главную страницу: <http://localhost:8000/>.
Проверка доступности: <http://localhost:8000/ping/> — статус `200`, JSON
`{"message":"pong"}`. Документация API: <http://localhost:8000/docs>.
Для остановки нажмите `Ctrl+C` в терминале с контейнером.

Dockerfile сначала копирует `requirements.txt` и устанавливает зависимости
отдельным слоем, затем копирует приложение вместе с шаблонами и статикой.
Отдельный этап `test` устанавливает зависимости разработки и запускает
весь набор тестов с `-W error` и требованием покрытия 100%. Обычная сборка
образа также зависит от успешного прохождения этого этапа.
Итоговый образ не содержит установленных тестовых зависимостей и запускает
Uvicorn от непривилегированного пользователя на `0.0.0.0:8000`.
Порт объявлен через `EXPOSE 8000`; параметр `-p 8000:8000` публикует его
на компьютере. См. [справочник Dockerfile](https://docs.docker.com/reference/dockerfile/).

Только сборка тестового этапа:

```bash
docker build --target test -t python-web-application-docker:test .
```

GitHub Actions собирает образ, запускает тесты и проверяет `/ping/` после
каждого push и pull request. Сборка не публикует образ в Docker Hub.

Контейнер начинает работу с `contacts.json` из репозитория. Изменения данных
хранятся внутри контейнера и при его удалении теряются. Для постоянного
хранения можно подключить существующий файл с правами записи через bind mount
по пути `/app/contacts.json`.

## Возможности

- добавление, поиск, изменение и удаление контактов через CLI;
- чтение списка контактов через JSON API;
- чтение отдельного контакта по ID;
- создание контакта через JSON API;
- поиск, частичное изменение и удаление контактов через JSON API;
- автоматическое назначение ID и дат создания и изменения;
- хранение данных в UTF-8 JSON;
- HTML-страницы с адаптивным интерфейсом Bootstrap 5;
- живой список контактов с загрузкой из API, поиском и ручным обновлением;
- светлая и тёмная темы с сохранением пользовательского выбора;
- выразительные адаптивные header и footer;
- интерактивная документация OpenAPI;
- автоматические тесты с полным покрытием рабочего пакета.

## Требования

- Python 3.10 или новее;
- `pip` для установки зависимостей.

Проверенная матрица прямых зависимостей находится в `requirements.txt` и
`requirements-dev.txt`.

## Установка

Клонируйте репозиторий и перейдите в его каталог:

```bash
git clone https://github.com/Aleksandr-A163/python-web-application-docker.git
cd python-web-application-docker
```

Создайте виртуальное окружение:

```bash
python -m venv .venv
```

Активируйте его в Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Для запуска приложения установите основные зависимости:

```bash
python -m pip install -r requirements.txt
```

Для разработки и запуска тестов установите полный набор:

```bash
python -m pip install -r requirements-dev.txt
```

`requirements-dev.txt` уже подключает `requirements.txt`, поэтому отдельно
устанавливать оба файла не требуется.

## Запуск веб-приложения

Из корня проекта выполните:

```bash
uvicorn app:app --reload
```

После запуска доступны:

- главная страница: <http://127.0.0.1:8000/>;
- информация о проекте: <http://127.0.0.1:8000/about/>;
- Swagger UI: <http://127.0.0.1:8000/docs>;
- OpenAPI-схема: <http://127.0.0.1:8000/openapi.json>.

Корневой `app.py` является стабильной ASGI-точкой входа. Сборка приложения
расположена в `phonebook/web/application.py`.

## Запуск консольного приложения

```bash
python main.py
```

Корневой `main.py` сохраняет прежнюю команду запуска, а реализация CLI
скомпонована в пакете `phonebook/cli`.

## HTML-маршруты

| Метод | URL | Назначение |
|---|---|---|
| `GET` | `/` | Главная страница |
| `GET` | `/about/` | Информация о сайте и разработчике |

Обе страницы используют общий Jinja2-шаблон, Bootstrap 5.0.2 и адаптивную
навигационную панель. Ссылки между страницами формируются через `url_for`.

### Возможности веб-интерфейса

На главной странице отображается актуальный список контактов из
`GET /api/contacts/`. Данные загружаются без перезагрузки страницы.

Интерфейс поддерживает:

- поиск по имени, номеру телефона и комментарию;
- счётчик найденных контактов;
- повторную загрузку списка кнопкой «Обновить»;
- светлую и тёмную цветовые темы;
- сохранение выбранной темы в браузере;
- адаптивное мобильное меню;
- состояния загрузки, пустого списка и ошибки API.

Пользовательские данные выводятся через безопасные DOM-операции с
`textContent`, а не через вставку HTML. Собственные стили и сценарии расположены
в `phonebook/web/static` и подключаются через именованный маршрут FastAPI
`static`.

## JSON API

| Метод | URL | Успешный статус | Назначение |
|---|---|---:|---|
| `GET` | `/api/contacts/` | `200` | Получить список контактов |
| `GET` | `/api/contacts/?query=...` | `200` | Найти контакты |
| `GET` | `/api/contacts/{contact_id}` | `200` | Получить контакт по ID |
| `POST` | `/api/contacts/` | `201` | Создать контакт |
| `PATCH` | `/api/contacts/{contact_id}` | `200` | Частично изменить контакт |
| `DELETE` | `/api/contacts/{contact_id}` | `204` | Удалить контакт |

### Получить список контактов

```bash
curl http://127.0.0.1:8000/api/contacts/
```

### Получить контакт

```bash
curl http://127.0.0.1:8000/api/contacts/1
```

Если контакт отсутствует, API возвращает `404 Not Found`:

```json
{
  "detail": "Контакт с ID 999 не найден."
}
```

### Найти контакты

```bash
curl "http://127.0.0.1:8000/api/contacts/?query=иван"
```

### Создать контакт

Linux и macOS:

```bash
curl -X POST http://127.0.0.1:8000/api/contacts/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Иван Иванов","phone":"+7 999 123-45-67","comment":"Коллега"}'
```

Windows PowerShell:

```powershell
$body = @{
    name = "Иван Иванов"
    phone = "+7 999 123-45-67"
    comment = "Коллега"
} | ConvertTo-Json

Invoke-RestMethod `
    -Method Post `
    -Uri "http://127.0.0.1:8000/api/contacts/" `
    -ContentType "application/json" `
    -Body $body
```

Пример ответа:

```json
{
  "id": 1,
  "name": "Иван Иванов",
  "phone": "+7 999 123-45-67",
  "comment": "Коллега",
  "created_at": "2026-09-06T12:00:00",
  "updated_at": "2026-09-06T12:00:00"
}
```

### Изменить контакт

```bash
curl -X PATCH http://127.0.0.1:8000/api/contacts/1 \
  -H "Content-Type: application/json" \
  -d '{"phone":"+7 900 555-12-34","comment":"Новый номер"}'
```

В запросе достаточно передать одно изменяемое поле: `name`, `phone` или
`comment`. Пустой объект и пустые обязательные поля возвращают `422`.

### Удалить контакт

```bash
curl -X DELETE http://127.0.0.1:8000/api/contacts/1
```

Успешное удаление возвращает `204 No Content` без тела ответа.

Пустые `name` и `phone`, неверные типы и неположительный ID возвращают
`422 Unprocessable Entity`.

## Структура проекта

```text
python-web-application/
├── phonebook/
│   ├── cli/
│   │   ├── application.py      # сборка CLI
│   │   ├── controller.py       # пользовательские сценарии CLI
│   │   └── view.py             # консольный ввод и вывод
│   ├── web/
│   │   ├── api/
│   │   │   ├── contacts.py     # API контактов
│   │   │   └── router.py       # роутер с префиксом /api
│   │   ├── schemas/
│   │   │   └── contacts.py     # Pydantic-схемы
│   │   ├── static/
│   │   │   ├── app.js          # переключение цветовой темы
│   │   │   ├── contacts.js     # загрузка, поиск и обновление контактов
│   │   │   └── styles.css      # собственная тема поверх Bootstrap
│   │   ├── templates/          # Jinja2-шаблоны
│   │   ├── application.py      # фабрика FastAPI-приложения
│   │   ├── dependencies.py     # зависимости PhoneBook и writer
│   │   └── pages.py            # HTML-представления
│   ├── exceptions.py           # доменные исключения
│   ├── generator.py            # генератор тестовых контактов
│   └── model.py                # Contact, PhoneBook и JSON-хранилище
├── tests/                      # автоматические тесты
├── docs/
│   ├── architecture.md         # архитектурные решения
│   └── http-contracts.md       # HTTP-контракты
├── app.py                      # ASGI-точка входа
├── main.py                     # точка запуска CLI
├── contacts.json               # рабочие данные
├── requirements.txt            # основные зависимости
├── requirements-dev.txt        # зависимости разработки
└── pyproject.toml               # настройки pytest
```

## Архитектура

Зависимости направлены от интерфейсов к предметной модели:

```text
CLI --------┐
            ├──> PhoneBook ──> Contact
FastAPI ----┘
```

Доменный код не импортирует FastAPI, Jinja2 или консольное представление.
Подробности приведены в [архитектурном документе](docs/architecture.md), а
публичные форматы — в [HTTP-контрактах](docs/http-contracts.md).

## Тестирование

Запуск полного набора:

```bash
python -m pytest
```

Подробный вывод:

```bash
python -m pytest -v
```

Строгая проверка предупреждений и покрытия:

```bash
python -m pytest -W error \
  --cov=phonebook \
  --cov-report=term-missing \
  --cov-fail-under=100
```

На Windows команду можно записать одной строкой или использовать символ
продолжения PowerShell — обратную кавычку.

## История проекта

Проект развивает консольный
[python-phonebook-tests](https://github.com/Aleksandr-A163/python-phonebook-tests),
основанный на
[python-phonebook-mvc](https://github.com/Aleksandr-A163/python-phonebook-mvc).
Git-история исходного приложения сохранена.
