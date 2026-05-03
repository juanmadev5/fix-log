using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Common;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;

namespace fix_log_api.Application.Services
{
    public class ReportService(IReportRepository repository) : IReportService
    {
        private readonly IReportRepository _repository = repository;

        public async Task<ActionResponse<ResponseReportDto>> Create(CreateReportDto dto, int userId)
        {
            var reportEntity = new Report
            {
                UserId = userId,
                CustomerId = dto.CustomerId,
                Date = DateTime.SpecifyKind(dto.Date, DateTimeKind.Utc),
                Details = dto.Details,
                IsCompleted = dto.IsCompleted,
                IsPaid = dto.IsPaid,
                Cost = dto.Cost,
            };

            bool success = await _repository.Create(reportEntity);

            if (!success)
            {
                return new ActionResponse<ResponseReportDto>(
                    null,
                    "No se pudo guardar el reporte en la base de datos",
                    Status.FAILED
                );
            }

            var reportDto = new ResponseReportDto(
                reportEntity.Id,
                reportEntity.CustomerId,
                reportEntity.Date,
                reportEntity.Details,
                reportEntity.IsCompleted,
                reportEntity.IsPaid,
                reportEntity.Cost
            );

            return new ActionResponse<ResponseReportDto>(
                reportDto,
                "Reporte registrado con éxito",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<bool>> Delete(int id, int userId)
        {
            var report = await _repository.GetById(id);

            if (report == null || report.UserId != userId)
            {
                return new ActionResponse<bool>(
                    false,
                    $"No se pudo eliminar el reporte. El ID {id} no fue encontrado.",
                    Status.NOT_FOUND
                );
            }

            bool success = await _repository.Delete(id);

            if (!success)
            {
                return new ActionResponse<bool>(
                    false,
                    $"No se pudo eliminar el reporte. El ID {id} no fue encontrado.",
                    Status.NOT_FOUND
                );
            }

            return new ActionResponse<bool>(
                true,
                "Reporte eliminado correctamente",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<ResponseReportDto>> Edit(ResponseReportDto dto, int userId)
        {
            var existing = await _repository.GetById(dto.Id);

            if (existing == null || existing.UserId != userId)
            {
                return new ActionResponse<ResponseReportDto>(
                    dto,
                    "No se pudo actualizar el reporte. Es posible que el ID no exista.",
                    Status.NOT_FOUND
                );
            }

            var reportEntity = new Report
            {
                Id = dto.Id,
                UserId = userId,
                CustomerId = dto.CustomerId,
                Date = DateTime.SpecifyKind(dto.Date, DateTimeKind.Utc),
                Details = dto.Details,
                IsCompleted = dto.IsCompleted,
                IsPaid = dto.IsPaid,
                Cost = dto.Cost,
            };

            bool success = await _repository.Edit(reportEntity);

            if (!success)
            {
                return new ActionResponse<ResponseReportDto>(
                    dto,
                    "No se pudo actualizar el reporte. Es posible que el ID no exista.",
                    Status.NOT_FOUND
                );
            }

            return new ActionResponse<ResponseReportDto>(
                dto,
                "Reporte actualizado correctamente",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<List<ResponseReportDto>?>> GetAll(int userId)
        {
            var reports = await _repository.GetAll(userId);

            if (reports == null || reports.Count == 0)
            {
                return new ActionResponse<List<ResponseReportDto>?>(
                    null,
                    "No hay reportes registrados",
                    Status.NOT_FOUND
                );
            }

            var responseDto = reports
                .Select(e => new ResponseReportDto(
                    e.Id,
                    e.CustomerId,
                    e.Date,
                    e.Details,
                    e.IsCompleted,
                    e.IsPaid,
                    e.Cost
                ))
                .ToList();

            return new ActionResponse<List<ResponseReportDto>?>(
                responseDto,
                "Listado de reportes obtenido con éxito",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<ResponseReportDto?>> GetById(int id, int userId)
        {
            var report = await _repository.GetById(id);

            if (report == null || report.UserId != userId)
            {
                return new ActionResponse<ResponseReportDto?>(
                    null,
                    $"El reporte con ID {id} no existe.",
                    Status.NOT_FOUND
                );
            }

            var responseDto = new ResponseReportDto(
                report.Id,
                report.CustomerId,
                report.Date,
                report.Details,
                report.IsCompleted,
                report.IsPaid,
                report.Cost
            );

            return new ActionResponse<ResponseReportDto?>(
                responseDto,
                "Reporte encontrado con éxito",
                Status.FOUND
            );
        }
    }
}
