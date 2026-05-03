# Fix Log

Aplicación de gestión para técnicos y prestadores de servicios. Permite registrar clientes, reportes de trabajo y gastos operativos del negocio.

## Stack

| Capa     | Tecnología                            |
| -------- | ------------------------------------- |
| Backend  | ASP.NET Core 10, EF Core, PostgreSQL  |
| Frontend | Flutter 3, Provider                   |
| Auth     | JWT + BCrypt                          |
| Docs     | Scalar UI                             |

## Funcionalidades

- Registro e inicio de sesión con JWT
- CRUD de clientes con historial de reportes
- CRUD de reportes con estado de completado y pago
- CRUD de gastos operativos del negocio
- Modo oscuro / claro
- Datos completamente aislados por usuario

## Estructura del proyecto

```text
fix-log/
├── fix-log-api/     # Backend ASP.NET Core
└── fix_log/         # App móvil Flutter
```

## Levantar el proyecto

### Backend

**Requisitos:** .NET 10 SDK, Docker, `dotnet-ef`

```bash
# 1. Base de datos
docker run --name postgres -e POSTGRES_PASSWORD=admin -p 5432:5432 -d postgres:16

# 2. Aplicar migraciones
cd fix-log-api
dotnet ef database update

# 3. Correr la API
dotnet run
```

La API queda disponible en `http://localhost:5167`.
La documentación interactiva (Scalar) en `http://localhost:5167/scalar/v1`.

> Configurá el JWT Secret en `appsettings.json` con una clave de al menos 32 caracteres.

### Frontend

**Requisitos:** Flutter 3.x SDK

```bash
cd fix_log
flutter pub get
flutter run
```

Para apuntar a una API en otro host:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:5167/api
```

> En emulador Android, la app usa `10.0.2.2` por defecto para alcanzar `localhost` del host.

## Endpoints

| Método              | Ruta                  | Auth |
| ------------------- | --------------------- | ---- |
| POST                | `/api/auth/register`  | No   |
| POST                | `/api/auth/login`     | No   |
| GET/POST/PUT/DELETE | `/api/customer`       | Sí   |
| GET/POST/PUT/DELETE | `/api/expense`        | Sí   |
| GET/POST/PUT/DELETE | `/api/report`         | Sí   |

Todos los endpoints protegidos requieren `Authorization: Bearer <token>`.
