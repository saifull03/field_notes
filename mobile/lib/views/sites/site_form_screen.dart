import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/customer/customer_bloc.dart';
import '../../blocs/customer/customer_state.dart';
import '../../blocs/site/site_bloc.dart';
import '../../blocs/site/site_event.dart';
import '../../models/site_model.dart';

class SiteFormScreen extends StatefulWidget {
  final SiteModel? site;
  final String? preselectedCustomerId;

  const SiteFormScreen({super.key, this.site, this.preselectedCustomerId});

  @override
  State<SiteFormScreen> createState() => _SiteFormScreenState();
}

class _SiteFormScreenState extends State<SiteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  String? _selectedCustomerId;

  bool get isEditing => widget.site != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.site?.name ?? '');
    _addressController = TextEditingController(text: widget.site?.address ?? '');
    _selectedCustomerId = widget.site?.customerId ?? widget.preselectedCustomerId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer for this site')),
        );
        return;
      }

      if (isEditing) {
        final updated = widget.site!.copyWith(
          customerId: _selectedCustomerId,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
        );
        context.read<SiteBloc>().add(UpdateSiteEvent(updated));
      } else {
        context.read<SiteBloc>().add(
              AddSiteEvent(
                customerId: _selectedCustomerId!,
                name: _nameController.text.trim(),
                address: _addressController.text.trim(),
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
        title: Text(isEditing ? 'Edit Site' : 'Add New Site'),
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
              // Customer Dropdown
              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  final customers = state is CustomerLoaded ? state.customers : [];

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCustomerId,
                    decoration: const InputDecoration(
                      labelText: 'Customer *',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                    items: customers.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: isEditing
                        ? null // Lock customer when editing existing site
                        : (val) {
                            setState(() => _selectedCustomerId = val);
                          },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please choose a customer';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Site Name *',
                  hintText: 'e.g. North Substation Unit B',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter site name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Site Address / Directions',
                  hintText: 'Physical location, gate code, landmarks',
                  prefixIcon: Icon(Icons.map_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(isEditing ? 'Update Site' : 'Create Site'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
