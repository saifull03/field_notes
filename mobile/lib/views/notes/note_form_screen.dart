import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../blocs/customer/customer_bloc.dart';
import '../../blocs/customer/customer_state.dart';
import '../../blocs/note/note_bloc.dart';
import '../../blocs/note/note_event.dart';
import '../../blocs/site/site_bloc.dart';
import '../../blocs/site/site_state.dart';
import '../../core/services/location_service.dart';
import '../../core/services/media_service.dart';
import '../../core/services/storage_service.dart';
import '../../models/field_note_model.dart';
import '../../models/site_model.dart';

class NoteFormScreen extends StatefulWidget {
  final FieldNoteModel? note;
  final String? preselectedSiteId;

  const NoteFormScreen({super.key, this.note, this.preselectedSiteId});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mediaService = MediaService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationNameController;

  String? _selectedCustomerId;
  String? _selectedSiteId;
  DateTime _selectedDateTime = DateTime.now();
  late String _selectedStatus;
  double? _latitude;
  double? _longitude;
  String? _localPhotoPath;
  String? _photoUrl;
  bool _isFetchingLocation = false;

  bool get isEditing => widget.note != null;

  static const List<String> availableStatuses = [
    'Draft',
    'In Progress',
    'Completed',
    'Pending',
  ];

  @override
  void initState() {
    super.initState();
    final storage = context.read<StorageService>();
    final defaultStatus = storage.getDefaultNoteStatus();

    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController = TextEditingController(text: widget.note?.description ?? '');
    _locationNameController = TextEditingController(text: widget.note?.locationName ?? '');

    if (isEditing) {
      _selectedSiteId = widget.note!.siteId;
      _selectedCustomerId = widget.note!.customerId;
      _selectedDateTime = widget.note!.dateTime.toLocal();
      _selectedStatus = widget.note!.status;
      _latitude = widget.note!.latitude;
      _longitude = widget.note!.longitude;
      _localPhotoPath = widget.note!.localPhotoPath;
      _photoUrl = widget.note!.photoUrl;
    } else {
      _selectedSiteId = widget.preselectedSiteId;
      if (_selectedSiteId != null) {
        final site = storage.getSiteById(_selectedSiteId!);
        _selectedCustomerId = site?.customerId;
      }
      _selectedStatus = availableStatuses.contains(defaultStatus) ? defaultStatus : 'Draft';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    setState(() => _isFetchingLocation = true);
    final result = await LocationService.getCurrentLocation();
    setState(() => _isFetchingLocation = false);
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        if (_locationNameController.text.trim().isEmpty) {
          _locationNameController.text = 'GPS (${result.locationString})';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS coordinates captured: ${result.locationString}'),
          backgroundColor: Colors.teal.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not obtain GPS location. Please check location permissions.'),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? _selectedDateTime.hour,
          pickedTime?.minute ?? _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickPhoto(bool fromCamera) async {
    final path = fromCamera
        ? await _mediaService.pickImageFromCamera()
        : await _mediaService.pickImageFromGallery();

    if (path != null) {
      setState(() {
        _localPhotoPath = path;
      });
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSiteId == null || _selectedSiteId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a site for this field note')),
        );
        return;
      }

      final storage = context.read<StorageService>();
      final site = storage.getSiteById(_selectedSiteId!);

      if (isEditing) {
        final updated = widget.note!.copyWith(
          siteId: _selectedSiteId,
          siteName: site?.name,
          customerId: site?.customerId,
          customerName: site?.customerName,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          locationName: _locationNameController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          dateTime: _selectedDateTime.toUtc(),
          status: _selectedStatus,
          localPhotoPath: _localPhotoPath,
          photoUrl: _photoUrl,
          isSynced: false,
          updatedAt: DateTime.now(),
        );
        context.read<NoteBloc>().add(UpdateNoteEvent(updated));
      } else {
        final newNote = FieldNoteModel(
          id: const Uuid().v4(),
          siteId: _selectedSiteId!,
          siteName: site?.name,
          customerId: site?.customerId,
          customerName: site?.customerName,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          locationName: _locationNameController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          dateTime: _selectedDateTime.toUtc(),
          status: _selectedStatus,
          localPhotoPath: _localPhotoPath,
          photoUrl: _photoUrl,
          isSynced: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        context.read<NoteBloc>().add(AddNoteEvent(newNote));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy  h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Field Note' : 'New Field Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _save,
            tooltip: 'Save Field Note',
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
              // 1. Customer & Site Selection
              BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, custState) {
                  final customers = custState is CustomerLoaded ? custState.customers : [];

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
                    onChanged: (val) {
                      setState(() {
                        _selectedCustomerId = val;
                        _selectedSiteId = null; // Reset site when customer changes
                      });
                    },
                    validator: (val) {
                      if (_selectedSiteId == null && (val == null || val.isEmpty)) {
                        return 'Please choose a customer';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              BlocBuilder<SiteBloc, SiteState>(
                builder: (context, siteState) {
                  var sites = <SiteModel>[];
                  if (siteState is SiteLoaded) {
                    if (_selectedCustomerId != null && _selectedCustomerId!.isNotEmpty) {
                      sites = siteState.sites.where((s) => s.customerId == _selectedCustomerId).toList();
                    } else {
                      sites = siteState.sites;
                    }
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedSiteId,
                    decoration: const InputDecoration(
                      labelText: 'Site *',
                      prefixIcon: Icon(Icons.place_rounded),
                    ),
                    items: sites.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSiteId = val;
                        if (val != null) {
                          final matching = sites.firstWhere((s) => s.id == val);
                          _selectedCustomerId = matching.customerId;
                        }
                      });
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please choose a site';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 18),

              // 2. Title & Description
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Note Title *',
                  hintText: 'e.g. Monthly Inverter & Battery Inspection',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter note title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description / Observations',
                  hintText: 'Record details of the inspection, issues found, repairs done...',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // 3. Status and Date & Time
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag_rounded),
                      ),
                      items: availableStatuses.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date & Time',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        child: Text(
                          dateFormat.format(_selectedDateTime),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Location Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on_rounded, color: Color(0xFF0F766E)),
                              SizedBox(width: 8),
                              Text(
                                'Location Coordinates',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _isFetchingLocation ? null : _pickLocation,
                            icon: _isFetchingLocation
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location_rounded, size: 18),
                            label: Text(_isFetchingLocation ? 'Fetching...' : 'Get GPS'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _locationNameController,
                        decoration: InputDecoration(
                          hintText: 'Building, roof level, or GPS coordinates',
                          helperText: _latitude != null && _longitude != null
                              ? 'Captured: Lat ${_latitude!.toStringAsFixed(5)}, Lng ${_longitude!.toStringAsFixed(5)}'
                              : 'No GPS coordinates attached',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Optional Photo Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.camera_alt_rounded, color: Color(0xFF0F766E)),
                          SizedBox(width: 8),
                          Text(
                            'Attach Inspection Photo (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_localPhotoPath != null && File(_localPhotoPath!).existsSync()) ...[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_localPhotoPath!),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _localPhotoPath = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickPhoto(true),
                                icon: const Icon(Icons.camera_alt_rounded),
                                label: const Text('Take Photo'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickPhoto(false),
                                icon: const Icon(Icons.photo_library_rounded),
                                label: const Text('From Gallery'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(isEditing ? 'Update Field Note' : 'Save Field Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
