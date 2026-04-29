import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/shimmer_list.dart';
import '../../domain/models/expense.dart';
import '../providers/expense_provider.dart';
import 'expense_form_screen.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.expenses.isEmpty) {
          return const ShimmerList();
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: provider.loadExpenses,
            child: CustomScrollView(
              slivers: [
                if (provider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: ErrorBanner(message: provider.errorMessage!),
                    ),
                  ),
                if (provider.expenses.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Sin gastos',
                      subtitle: 'Registra tu primer gasto con el botón +',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    sliver: SliverList.builder(
                      itemCount: provider.expenses.length,
                      itemBuilder: (_, i) =>
                          _ExpenseCard(expense: provider.expenses[i]),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'),
          ),
        );
      },
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final total = expense.price * expense.quantity;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExpenseFormScreen(expense: expense),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title, style: textTheme.titleMedium),
                    if (expense.details.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        expense.details,
                        style: textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Chip(
                          label: '\$${expense.price.toStringAsFixed(2)}',
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        _Chip(
                          label: 'x${expense.quantity}',
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        _Chip(
                          label: 'Total: \$${total.toStringAsFixed(2)}',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExpenseFormScreen(expense: expense),
                      ),
                    );
                  } else if (value == 'delete') {
                    final confirmed = await _confirmDelete(context, expense.title);
                    if (confirmed) await provider.deleteExpense(expense.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 10),
                        Text('Eliminar', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar gasto'),
            content: Text('¿Eliminar "$title"? Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
