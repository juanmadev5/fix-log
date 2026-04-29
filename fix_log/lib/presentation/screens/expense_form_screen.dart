import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../domain/models/expense.dart';
import '../providers/expense_provider.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});

  final Expense? expense;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _detailsController = TextEditingController(text: widget.expense?.details ?? '');
    _priceController = TextEditingController(
      text: widget.expense != null ? widget.expense!.price.toString() : '',
    );
    _quantityController = TextEditingController(
      text: widget.expense != null ? widget.expense!.quantity.toString() : '1',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExpenseProvider>();
    final title = _titleController.text.trim();
    final details = _detailsController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;

    if (!_isEditing) {
      await provider.addExpense(title, details, price, quantity);
    } else {
      await provider.updateExpense(Expense(
        id: widget.expense!.id,
        title: title,
        details: details,
        price: price,
        quantity: quantity,
      ));
    }

    if (provider.errorMessage == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar gasto' : 'Nuevo gasto'),
      ),
      body: SafeArea(
        child: Consumer<ExpenseProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _titleController,
                      label: 'Título',
                      prefixIcon: Icons.title,
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: !_isEditing,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa el título' : null,
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
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppTextField(
                            controller: _priceController,
                            label: 'Precio',
                            prefixIcon: Icons.attach_money,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            controller: _quantityController,
                            label: 'Cantidad',
                            prefixIcon: Icons.numbers,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (provider.errorMessage != null) ...[
                      ErrorBanner(message: provider.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    AppButton(
                      label: _isEditing ? 'Actualizar' : 'Guardar gasto',
                      onPressed: _submit,
                      isLoading: provider.isLoading,
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
