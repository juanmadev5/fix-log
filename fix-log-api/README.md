# fix-log-api

API REST construida con ASP.NET Core 10 y PostgreSQL.

## Requisitos

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Docker](https://www.docker.com/) (para la base de datos)
- `dotnet-ef` (herramienta de migraciones)

## Configuración

### 1. Base de datos (Docker)

```bash
docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5433:5432 -d postgres:16
```

### 2. Connection string

Editá `appsettings.Development.json` con tus credenciales:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5433;Database=postgres;Username=postgres;Password=postgres"
  }
}
```

### 3. JWT y BCrypt

En `appsettings.json` podés configurar:

```json
{
  "JwtSettings": {
    "Secret": "TU_CLAVE_SECRETA_DE_AL_MENOS_32_CHARS",
    "Issuer": "fix-log-api",
    "Audience": "fix-log-api-clients",
    "ExpiryMinutes": 60
  },
  "BcryptSettings": {
    "WorkFactor": 12
  }
}
```

> El `Secret` debe tener al menos 32 caracteres. No lo commiteés en producción — usá variables de entorno o User Secrets.

## Migraciones

### Instalar dotnet-ef (solo la primera vez)

```bash
dotnet tool install --global dotnet-ef
```

### Crear una nueva migración

```bash
ASPNETCORE_ENVIRONMENT=Development dotnet ef migrations add <NombreMigracion>
```

### Aplicar migraciones a la base de datos

```bash
ASPNETCORE_ENVIRONMENT=Development dotnet ef database update
```

### Revertir la última migración

```bash
ASPNETCORE_ENVIRONMENT=Development dotnet ef migrations remove
```

## Levantar el proyecto

```bash
dotnet run
```

O con perfil HTTPS:

```bash
dotnet run --launch-profile https
```

## Documentación de la API

Con el proyecto corriendo en modo Development, la UI de Scalar está disponible en:

```
http://localhost:5167/scalar/v1
```

## Endpoints

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| POST | `/api/auth/register` | No | Registrar usuario |
| POST | `/api/auth/login` | No | Iniciar sesión |
| GET | `/api/customer` | Sí | Listar clientes |
| GET | `/api/customer/{id}` | Sí | Obtener cliente |
| POST | `/api/customer` | Sí | Crear cliente |
| PUT | `/api/customer` | Sí | Editar cliente |
| DELETE | `/api/customer/{id}` | Sí | Eliminar cliente |
| GET | `/api/expense` | Sí | Listar gastos |
| GET | `/api/expense/{id}` | Sí | Obtener gasto |
| POST | `/api/expense` | Sí | Crear gasto |
| PUT | `/api/expense` | Sí | Editar gasto |
| DELETE | `/api/expense/{id}` | Sí | Eliminar gasto |
| GET | `/api/report` | Sí | Listar reportes |
| GET | `/api/report/{id}` | Sí | Obtener reporte |
| POST | `/api/report` | Sí | Crear reporte |
| PUT | `/api/report` | Sí | Editar reporte |
| DELETE | `/api/report/{id}` | Sí | Eliminar reporte |

Los endpoints marcados con **Sí** requieren el header:

```
Authorization: Bearer <token>
```

El token se obtiene en `/api/auth/login`.
