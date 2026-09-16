import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/customer.dart';
import '../../core/strings.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/responsive_body.dart';
import '../view_models/customer_cubit.dart';
import '../view_models/customer_state.dart';

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
    _emailController = TextEditingController(
      text: widget.customer?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.customer?.phoneNumber ?? '',
    );
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

    final cubit = context.read<CustomerCubit>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_isEditing) {
      await cubit.addCustomer(name, email, phone);
    } else {
      await cubit.updateCustomer(
        Customer(
          id: widget.customer!.id,
          name: name,
          email: email,
          phoneNumber: phone,
          reports: widget.customer!.reports,
        ),
      );
    }

    if (cubit.state.errorMessage == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? AppStrings.editCustomer : AppStrings.newCustomer,
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<CustomerCubit, CustomerState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ResponsiveBody(
                maxWidth: 500,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: AppStrings.fullName,
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        autofocus: !_isEditing,
                        validator: (value) => (value == null || value.isEmpty)
                            ? AppStrings.enterName
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value == null || value.isEmpty)
                            ? AppStrings.enterEmail
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneController,
                        label: AppStrings.phoneNumber,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) => (value == null || value.isEmpty)
                            ? AppStrings.enterPhoneNumber
                            : null,
                      ),
                      const SizedBox(height: 24),
                      if (state.errorMessage != null) ...[
                        ErrorBanner(message: state.errorMessage!),
                        const SizedBox(height: 16),
                      ],
                      AppButton(
                        label: _isEditing
                            ? AppStrings.update
                            : AppStrings.saveCustomer,
                        onPressed: _submit,
                        isLoading: state.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
