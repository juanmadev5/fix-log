import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/shimmer_list.dart';
import '../../domain/models/report.dart';
import '../providers/report_provider.dart';
import 'report_form_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.reports.isEmpty) {
          return const ShimmerList();
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: provider.loadReports,
            child: CustomScrollView(
              slivers: [
                if (provider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: ErrorBanner(message: provider.errorMessage!),
                    ),
                  ),
                if (provider.reports.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.bar_chart_outlined,
                      title: 'Sin reportes',
                      subtitle: 'Crea tu primer reporte con el botón +',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    sliver: SliverList.builder(
                      itemCount: provider.reports.length,
                      itemBuilder: (_, i) =>
                          _ReportCard(report: provider.reports[i]),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportFormScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'),
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final Report report;

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ReportProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReportFormScreen(report: report),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart_outlined,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.details,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(report.date),
                          style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${report.customerId}',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatusChip(
                          label: report.isCompleted ? 'Completado' : 'Pendiente',
                          color: report.isCompleted
                              ? AppColors.success
                              : AppColors.warning,
                          icon: report.isCompleted
                              ? Icons.check_circle_outline
                              : Icons.pending_outlined,
                        ),
                        const SizedBox(width: 6),
                        _StatusChip(
                          label: report.isPaid ? 'Pagado' : 'Sin pagar',
                          color: report.isPaid
                              ? AppColors.success
                              : AppColors.error,
                          icon: report.isPaid
                              ? Icons.payments_outlined
                              : Icons.money_off_outlined,
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
                        builder: (_) => ReportFormScreen(report: report),
                      ),
                    );
                  } else if (value == 'delete') {
                    final confirmed = await _confirmDelete(context);
                    if (confirmed) await provider.deleteReport(report.id);
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

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar reporte'),
            content: const Text('¿Eliminar este reporte? Esta acción no se puede deshacer.'),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
