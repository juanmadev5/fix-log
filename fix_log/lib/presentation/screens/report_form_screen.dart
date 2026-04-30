import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../domain/models/customer.dart';
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
  late final TextEditingController _costController;
  Customer? _selectedCustomer;
  bool _isCompleted = false;
  bool _isPaid = false;
  DateTime _selectedDate = DateTime.now();
  bool _customerTouched = false;

  bool get _isEditing => widget.report != null;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController(text: widget.report?.details ?? '');
    _selectedDate = widget.report?.date ?? DateTime.now();
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
    _costController = TextEditingController(
      text: widget.report != null && widget.report!.cost > 0
          ? widget.report!.cost.round().toString()
          : '',
    );
    _isCompleted = widget.report?.isCompleted ?? false;
    _isPaid = widget.report?.isPaid ?? false;

    // When editing, resolve customer from provider after first frame
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final customers = context.read<CustomerProvider>().customers;
        final match = customers.where((c) => c.id == widget.report!.customerId);
        if (match.isNotEmpty) {
          setState(() => _selectedCustomer = match.first);
        }
      });
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _dateController.dispose();
    _costController.dispose();
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

  Future<void> _openCustomerPicker(List<Customer> customers) async {
    final result = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomerPickerSheet(
        customers: customers,
        selected: _selectedCustomer,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCustomer = result;
        _customerTouched = true;
      });
    } else {
      setState(() => _customerTouched = true);
    }
  }

  Future<void> _submit() async {
    setState(() => _customerTouched = true);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) return;

    final provider = context.read<ReportProvider>();
    final details = _detailsController.text.trim();
    final cost = double.tryParse(_costController.text.trim()) ?? 0;

    if (!_isEditing) {
      await provider.addReport(
        _selectedCustomer!.id,
        _selectedDate,
        details,
        _isCompleted,
        _isPaid,
        cost,
      );
    } else {
      await provider.updateReport(Report(
        id: widget.report!.id,
        customerId: _selectedCustomer!.id,
        date: _selectedDate,
        details: details,
        isCompleted: _isCompleted,
        isPaid: _isPaid,
        cost: cost,
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
            final hasError = _customerTouched && _selectedCustomer == null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer picker field
                    GestureDetector(
                      onTap: () => _openCustomerPicker(customers),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasError
                                ? colorScheme.error
                                : _selectedCustomer != null
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                            width: _selectedCustomer != null ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_search_outlined,
                              size: 20,
                              color: hasError
                                  ? colorScheme.error
                                  : _selectedCustomer != null
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _selectedCustomer == null
                                  ? Text(
                                      'Seleccionar cliente',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: hasError
                                            ? colorScheme.error
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedCustomer!.name,
                                          style: textTheme.titleMedium,
                                        ),
                                        if (_selectedCustomer!.email.isNotEmpty ||
                                            _selectedCustomer!
                                                .phoneNumber.isNotEmpty)
                                          Text(
                                            [
                                              if (_selectedCustomer!
                                                  .email.isNotEmpty)
                                                _selectedCustomer!.email,
                                              if (_selectedCustomer!
                                                  .phoneNumber.isNotEmpty)
                                                _selectedCustomer!.phoneNumber,
                                            ].join('  ·  '),
                                            style: textTheme.bodyMedium
                                                ?.copyWith(fontSize: 12),
                                          ),
                                      ],
                                    ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hasError) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          'Selecciona un cliente',
                          style: TextStyle(
                              color: colorScheme.error, fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _detailsController,
                      label: 'Detalles del trabajo',
                      prefixIcon: Icons.notes,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa los detalles' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _costController,
                      label: 'Costo del trabajo (Gs.)',
                      prefixIcon: Icons.monetization_on_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa el costo' : null,
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
                    Text('Estado', style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _ToggleRow(
                      label: 'Completado',
                      subtitle: _isCompleted
                          ? 'El servicio fue completado'
                          : 'Pendiente de completar',
                      value: _isCompleted,
                      activeColor: AppColors.success,
                      icon: Icons.check_circle_outline,
                      onChanged: (v) => setState(() => _isCompleted = v),
                    ),
                    const SizedBox(height: 8),
                    _ToggleRow(
                      label: 'Pagado',
                      subtitle: _isPaid
                          ? 'El servicio fue pagado'
                          : 'Pendiente de pago',
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

// ─── Customer picker bottom sheet ───────────────────────────────────────────

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet({required this.customers, this.selected});

  final List<Customer> customers;
  final Customer? selected;

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _searchController = TextEditingController();
  List<Customer> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.customers;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.customers
          : widget.customers.where((c) {
              return c.name.toLowerCase().contains(q) ||
                  c.email.toLowerCase().contains(q) ||
                  c.phoneNumber.toLowerCase().contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text('Seleccionar cliente',
                        style: textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Search field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, email o teléfono…',
                    prefixIcon:
                        const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Results
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Sin resultados',
                          style: textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final c = _filtered[i];
                          final isSelected = widget.selected?.id == c.id;
                          final initials = c.name.trim().isNotEmpty
                              ? c.name.trim().split(' ').take(2).map((w) => w[0]).join()
                              : '?';

                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).pop(c),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: isSelected
                                          ? colorScheme.primary.withValues(alpha: 0.15)
                                          : colorScheme.primary.withValues(alpha: 0.08),
                                      child: Text(
                                        initials.toUpperCase(),
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(c.name,
                                              style: textTheme.titleMedium),
                                          if (c.email.isNotEmpty) ...[
                                            const SizedBox(height: 1),
                                            Row(
                                              children: [
                                                Icon(Icons.email_outlined,
                                                    size: 12,
                                                    color: colorScheme
                                                        .onSurfaceVariant),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    c.email,
                                                    style: textTheme.bodyMedium
                                                        ?.copyWith(fontSize: 12),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (c.phoneNumber.isNotEmpty) ...[
                                            const SizedBox(height: 1),
                                            Row(
                                              children: [
                                                Icon(Icons.phone_outlined,
                                                    size: 12,
                                                    color: colorScheme
                                                        .onSurfaceVariant),
                                                const SizedBox(width: 4),
                                                Text(
                                                  c.phoneNumber,
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle,
                                          color: colorScheme.primary, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Toggle row ──────────────────────────────────────────────────────────────

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
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
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
