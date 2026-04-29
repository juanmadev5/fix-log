using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Common;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;

namespace fix_log_api.Application.Services
{
    public class CustomerService(ICustomerRepository repository) : ICustomerService
    {
        private readonly ICustomerRepository _repository = repository;

        public async Task<ActionResponse<ResponseCustomerDto>> Create(CreateCustomerDto dto)
        {
            var customerEntity = new Customer
            {
                Id = 0,
                Name = dto.Name,
                Email = dto.Email,
                PhoneNumber = dto.PhoneNumber,
                Reports = []
            };

            bool success = await _repository.Create(customerEntity);

            if (!success)
            {
                return new ActionResponse<ResponseCustomerDto>(
                    null,
                    "No se pudo guardar el cliente en la base de datos",
                    Status.FAILED
                );
            }

            var responseDto = new ResponseCustomerDto(
                customerEntity.Id,
                customerEntity.Name,
                customerEntity.Email,
                customerEntity.PhoneNumber,
                []
            );

            return new ActionResponse<ResponseCustomerDto>(
                responseDto,
                "Cliente registrado con éxito",
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
                    $"No se pudo eliminar el cliente. El ID {id} no fue encontrado.",
                    Status.NOT_FOUND
                );
            }

            return new ActionResponse<bool>(true, "Cliente eliminado correctamente", Status.SUCCESS);
        }

        public async Task<ActionResponse<ResponseCustomerDto>> Edit(ResponseCustomerDto dto)
        {
            var customerEntity = new Customer
            {
                Id = dto.Id,
                Name = dto.Name,
                Email = dto.Email,
                PhoneNumber = dto.PhoneNumber,
                Reports = []
            };

            bool success = await _repository.Edit(customerEntity);

            if (!success)
            {
                return new ActionResponse<ResponseCustomerDto>(
                    dto,
                    "No se pudo actualizar el cliente. Es posible que el ID no exista.",
                    Status.NOT_FOUND
                );
            }

            return new ActionResponse<ResponseCustomerDto>(
                dto,
                "Cliente actualizado correctamente",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<List<ResponseCustomerDto>?>> GetAll()
        {
            var customers = await _repository.GetAll();

            if (customers == null || customers.Count == 0)
            {
                return new ActionResponse<List<ResponseCustomerDto>?>(
                    null,
                    "No hay clientes registrados",
                    Status.NOT_FOUND
                );
            }

            var responseDto = customers
                .Select(c => new ResponseCustomerDto(
                    c.Id,
                    c.Name,
                    c.Email,
                    c.PhoneNumber,
                    c.Reports?.Select(r => new ResponseReportDto(r.Id, r.CustomerId, r.Date, r.Details, r.IsCompleted, r.IsPaid)).ToList() ?? []
                ))
                .ToList();

            return new ActionResponse<List<ResponseCustomerDto>?>(
                responseDto,
                "Listado de clientes obtenido con éxito",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<ResponseCustomerDto?>> GetById(int id)
        {
            var customer = await _repository.GetById(id);

            if (customer == null)
            {
                return new ActionResponse<ResponseCustomerDto?>(
                    null,
                    $"El cliente con ID {id} no existe.",
                    Status.NOT_FOUND
                );
            }

            var responseDto = new ResponseCustomerDto(
                customer.Id,
                customer.Name,
                customer.Email,
                customer.PhoneNumber,
                customer.Reports?.Select(r => new ResponseReportDto(r.Id, r.CustomerId, r.Date, r.Details, r.IsCompleted, r.IsPaid)).ToList() ?? []
            );

            return new ActionResponse<ResponseCustomerDto?>(responseDto, "Cliente encontrado con éxito", Status.FOUND);
        }
    }
}
