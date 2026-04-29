import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../domain/models/customer.dart';
import '../providers/customer_provider.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key, this.customer});

  final Customer? customer;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerProvider>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_isEditing) {
      await provider.addCustomer(name, email, phone);
    } else {
      await provider.updateCustomer(Customer(
        id: widget.customer!.id,
        name: name,
        email: email,
        phoneNumber: phone,
        reports: widget.customer!.reports,
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
        title: Text(_isEditing ? 'Editar cliente' : 'Nuevo cliente'),
      ),
      body: SafeArea(
        child: Consumer<CustomerProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _nameController,
                      label: 'Nombre completo',
                      prefixIcon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      autofocus: !_isEditing,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa el nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa el correo' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa el teléfono' : null,
                    ),
                    const SizedBox(height: 24),
                    if (provider.errorMessage != null) ...[
                      ErrorBanner(message: provider.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    AppButton(
                      label: _isEditing ? 'Actualizar' : 'Guardar cliente',
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
