import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../domain/models/report.dart';
import '../providers/customer_provider.dart';
import '../providers/report_provider.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key, this.report});

  final Report? report;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _detailsController;
  late final TextEditingController _dateController;
  int? _selectedCustomerId;
  bool _isCompleted = false;
  bool _isPaid = false;
  DateTime _selectedDate = DateTime.now();

  bool get _isEditing => widget.report != null;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController(text: widget.report?.details ?? '');
    _selectedDate = widget.report?.date ?? DateTime.now();
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
    _isCompleted = widget.report?.isCompleted ?? false;
    _isPaid = widget.report?.isPaid ?? false;
    _selectedCustomerId = widget.report?.customerId;
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un cliente')),
      );
      return;
    }

    final provider = context.read<ReportProvider>();
    final details = _detailsController.text.trim();

    if (!_isEditing) {
      await provider.addReport(
        _selectedCustomerId!,
        _selectedDate,
        details,
        _isCompleted,
        _isPaid,
      );
    } else {
      await provider.updateReport(Report(
        id: widget.report!.id,
        customerId: _selectedCustomerId!,
        date: _selectedDate,
        details: details,
        isCompleted: _isCompleted,
        isPaid: _isPaid,
      ));
    }

    if (provider.errorMessage == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar reporte' : 'Nuevo reporte'),
      ),
      body: SafeArea(
        child: Consumer2<ReportProvider, CustomerProvider>(
          builder: (context, reportProvider, customerProvider, _) {
            final customers = customerProvider.customers;
            if (_selectedCustomerId == null && customers.isNotEmpty) {
              _selectedCustomerId = customers.first.id;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCustomerId,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                      items: customers
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCustomerId = v),
                      validator: (v) =>
                          v == null ? 'Selecciona un cliente' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _detailsController,
                      label: 'Detalles',
                      prefixIcon: Icons.notes,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa los detalles' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _dateController,
                      label: 'Fecha',
                      prefixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
                    ),
                    const SizedBox(height: 20),
                    // Status toggles
                    Text('Estado', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _ToggleRow(
                      label: 'Completado',
                      subtitle: _isCompleted ? 'El servicio fue completado' : 'Pendiente de completar',
                      value: _isCompleted,
                      activeColor: AppColors.success,
                      icon: Icons.check_circle_outline,
                      onChanged: (v) => setState(() => _isCompleted = v),
                    ),
                    const SizedBox(height: 8),
                    _ToggleRow(
                      label: 'Pagado',
                      subtitle: _isPaid ? 'El servicio fue pagado' : 'Pendiente de pago',
                      value: _isPaid,
                      activeColor: colorScheme.primary,
                      icon: Icons.payments_outlined,
                      onChanged: (v) => setState(() => _isPaid = v),
                    ),
                    const SizedBox(height: 24),
                    if (reportProvider.errorMessage != null) ...[
                      ErrorBanner(message: reportProvider.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    AppButton(
                      label: _isEditing ? 'Actualizar' : 'Guardar reporte',
                      onPressed: _submit,
                      isLoading: reportProvider.isLoading,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.07)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? activeColor.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: value ? activeColor : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: textTheme.titleMedium),
                    Text(subtitle, style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: activeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
