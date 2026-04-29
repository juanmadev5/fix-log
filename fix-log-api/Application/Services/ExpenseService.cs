using fix_log_api.Application.DTOs;
using fix_log_api.Application.Interfaces;
using fix_log_api.Domain.Common;
using fix_log_api.Domain.Entities;
using fix_log_api.Domain.Interfaces;

namespace fix_log_api.Application.Services
{
    public class ExpenseService(IExpenseRepository repository) : IExpenseService
    {
        private readonly IExpenseRepository _repository = repository;

        public async Task<ActionResponse<ResponseExpenseDto>> Create(CreateExpenseDto dto)
        {
            var expenseEntity = new Expense
            {
                Title = dto.Title,
                Details = dto.Details,
                Price = dto.Price,
                Quantity = dto.Quantity,
            };

            bool success = await _repository.Create(expenseEntity);

            if (!success)
            {
                return new ActionResponse<ResponseExpenseDto>(
                    null,
                    "No se pudo guardar el gasto en la base de datos",
                    Status.FAILED
                );
            }

            var responseDto = new ResponseExpenseDto(
                expenseEntity.Id,
                expenseEntity.Title,
                expenseEntity.Details,
                expenseEntity.Price,
                expenseEntity.Quantity
            );

            return new ActionResponse<ResponseExpenseDto>(
                responseDto,
                "Gasto registrado con éxito",
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
                    $"No se pudo eliminar el gasto. El ID {id} no fue encontrado.",
                    Status.NOT_FOUND
                );
            }

            return new ActionResponse<bool>(true, "Gasto eliminado correctamente", Status.SUCCESS);
        }

        public async Task<ActionResponse<ResponseExpenseDto>> Edit(ResponseExpenseDto dto)
        {
            var expenseEntity = new Expense
            {
                Id = dto.Id,
                Title = dto.Title,
                Details = dto.Details,
                Price = dto.Price,
                Quantity = dto.Quantity,
            };

            bool success = await _repository.Edit(expenseEntity);

            if (!success)
            {
                return new ActionResponse<ResponseExpenseDto>(
                    dto,
                    "No se pudo actualizar el gasto. Es posible que el ID no exista.",
                    Status.NOT_FOUND
                );
            }

            return new ActionResponse<ResponseExpenseDto>(
                dto,
                "Gasto actualizado correctamente",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<List<ResponseExpenseDto>?>> GetAll()
        {
            var expenses = await _repository.GetAll();

            if (expenses == null || expenses.Count == 0)
            {
                return new ActionResponse<List<ResponseExpenseDto>?>(
                    null,
                    "No hay gastos registrados",
                    Status.NOT_FOUND
                );
            }

            var responseDto = expenses
                .Select(e => new ResponseExpenseDto(e.Id, e.Title, e.Details, e.Price, e.Quantity))
                .ToList();

            return new ActionResponse<List<ResponseExpenseDto>?>(
                responseDto,
                "Listado de gastos obtenido con éxito",
                Status.SUCCESS
            );
        }

        public async Task<ActionResponse<ResponseExpenseDto?>> GetById(int id)
        {
            var expense = await _repository.GetById(id);

            if (expense == null)
            {
                return new ActionResponse<ResponseExpenseDto?>(
                    null,
                    $"El Gasto con ID {id} no existe.",
                    Status.NOT_FOUND
                );
            }

            var responseDto = new ResponseExpenseDto(
                expense.Id,
                expense.Title,
                expense.Details,
                expense.Price,
                expense.Quantity
            );

            return new ActionResponse<ResponseExpenseDto?>(responseDto, "Gasto encontrado con éxito", Status.FOUND);
        }
    }
}
