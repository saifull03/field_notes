import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/customer/customer_bloc.dart';
import '../../blocs/customer/customer_event.dart';
import '../../models/customer_model.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerModel? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _contactController = TextEditingController(text: widget.customer?.contactInformation ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (isEditing) {
        final updated = widget.customer!.copyWith(
          name: _nameController.text.trim(),
          contactInformation: _contactController.text.trim(),
        );
        context.read<CustomerBloc>().add(UpdateCustomerEvent(updated));
      } else {
        context.read<CustomerBloc>().add(
              AddCustomerEvent(
                name: _nameController.text.trim(),
                contactInformation: _contactController.text.trim(),
              ),
            );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add New Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer / Company Name *',
                  hintText: 'e.g. Apex Energy Solutions',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _contactController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Contact Information',
                  hintText: 'Phone number, email, primary point of contact',
                  prefixIcon: Icon(Icons.contact_phone_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(isEditing ? 'Update Customer' : 'Create Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

