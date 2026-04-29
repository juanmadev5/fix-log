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

        public async Task<ActionResponse<ResponseReportDto>> Create(CreateReportDto dto)
        {
            var reportEntity = new Report
            {
                CustomerId = dto.CustomerId,
                Date = dto.Date,
                Details = dto.Details,
                IsCompleted = dto.IsCompleted,
                IsPaid = dto.IsPaid,
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
                reportEntity.IsPaid
            );

            return new ActionResponse<ResponseReportDto>(
                reportDto,
                "Reporte registrado con éxito",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<bool>> Delete(int id)
        {
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

        public async Task<ActionResponse<ResponseReportDto>> Edit(ResponseReportDto dto)
        {
            var reportEntity = new Report
            {
                Id = dto.Id,
                CustomerId = dto.CustomerId,
                Date = dto.Date,
                Details = dto.Details,
                IsCompleted = dto.IsCompleted,
                IsPaid = dto.IsPaid,
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

        public async Task<ActionResponse<List<ResponseReportDto>?>> GetAll()
        {
            var reports = await _repository.GetAll();

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
                    e.IsPaid
                ))
                .ToList();

            return new ActionResponse<List<ResponseReportDto>?>(
                responseDto,
                "Listado de reportes obtenido con éxito",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<ResponseReportDto?>> GetById(int id)
        {
            var report = await _repository.GetById(id);

            if (report == null)
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
                report.IsPaid
            );

            return new ActionResponse<ResponseReportDto?>(
                responseDto,
                "Reporte encontrado con éxito",
                Status.SUCCESS
            );
        }
    }
}
