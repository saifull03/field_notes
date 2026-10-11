import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/note/note_bloc.dart';
import '../../blocs/note/note_event.dart';
import '../../core/services/storage_service.dart';
import '../../models/field_note_model.dart';
import '../widgets/status_chip.dart';
import 'note_form_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final FieldNoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Field Note?'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<NoteBloc>().add(DeleteNoteEvent(note.id));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy  •  h:mm a');
    final storage = context.read<StorageService>();
    final baseUrl = storage.getBaseUrl();

    // Determine photo source
    Widget? photoWidget;
    if (note.localPhotoPath != null && File(note.localPhotoPath!).existsSync()) {
      photoWidget = Image.file(
        File(note.localPhotoPath!),
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (note.photoUrl != null && note.photoUrl!.isNotEmpty) {
      final fullUrl = note.photoUrl!.startsWith('http')
          ? note.photoUrl!
          : '$baseUrl${note.photoUrl}';
      photoWidget = Image.network(
        fullUrl,
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Note',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteFormScreen(note: note),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            tooltip: 'Delete Note',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (photoWidget != null)
              Container(
                color: Colors.black,
                child: photoWidget,
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Sync Badge Row
                  Row(
                    children: [
                      StatusChip(status: note.status),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: note.isSynced ? Colors.teal.shade50 : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: note.isSynced ? Colors.teal.shade200 : Colors.amber.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              note.isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                              size: 13,
                              color: note.isSynced ? Colors.teal.shade700 : Colors.amber.shade800,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              note.isSynced ? 'Synced' : 'Pending Sync',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: note.isSynced ? Colors.teal.shade700 : Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Customer & Site Info Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.place_rounded, size: 18, color: Color(0xFF0369A1)),
                            const SizedBox(width: 8),
                            const Text(
                              'Site: ',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                            ),
                            Expanded(
                              child: Text(
                                note.siteName ?? 'Unknown Site',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        if (note.customerName != null) ...[
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.business_rounded, size: 18, color: Color(0xFF0F766E)),
                              const SizedBox(width: 8),
                              const Text(
                                'Customer: ',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                              ),
                              Expanded(
                                child: Text(
                                  note.customerName!,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date & Time
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(note.dateTime.toLocal()),
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Location Info
                  if ((note.locationName != null && note.locationName!.isNotEmpty) ||
                      (note.latitude != null && note.longitude != null)) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.locationName ??
                                'GPS (${note.latitude?.toStringAsFixed(5)}, ${note.longitude?.toStringAsFixed(5)})',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description
                  const Text(
                    'Notes & Observations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      (note.description != null && note.description!.isNotEmpty)
                          ? note.description!
                          : 'No additional observations recorded.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
