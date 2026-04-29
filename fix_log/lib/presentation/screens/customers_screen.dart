import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/shimmer_list.dart';
import '../../domain/models/customer.dart';
import '../providers/customer_provider.dart';
import 'customer_form_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.customers.isEmpty) {
          return const ShimmerList();
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: provider.loadCustomers,
            child: CustomScrollView(
              slivers: [
                if (provider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: ErrorBanner(message: provider.errorMessage!),
                    ),
                  ),
                if (provider.customers.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.people_outline,
                      title: 'Sin clientes',
                      subtitle: 'Agrega tu primer cliente con el botón +',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    sliver: SliverList.separated(
                      itemCount: provider.customers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 0),
                      itemBuilder: (_, i) =>
                          _CustomerCard(customer: provider.customers[i]),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'),
          ),
        );
      },
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CustomerProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initials = customer.name.isNotEmpty
        ? customer.name.trim().split(' ').take(2).map((w) => w[0]).join()
        : '?';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CustomerFormScreen(customer: customer),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(customer.email, style: textTheme.bodyMedium),
                    if (customer.phoneNumber.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer.phoneNumber,
                            style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CustomerFormScreen(customer: customer),
                      ),
                    );
                  } else if (value == 'delete') {
                    final confirmed = await _confirmDelete(context, customer.name);
                    if (confirmed) await provider.deleteCustomer(customer.id);
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

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar cliente'),
            content: Text('¿Eliminar a "$name"? Esta acción no se puede deshacer.'),
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
