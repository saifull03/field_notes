import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/note/note_bloc.dart';
import '../../blocs/note/note_event.dart';
import '../../blocs/note/note_state.dart';
import '../../blocs/site/site_bloc.dart';
import '../../blocs/site/site_state.dart';
import '../../core/services/storage_service.dart';
import '../../models/field_note_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_chip.dart';
import 'note_detail_screen.dart';
import 'note_form_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String? _selectedSiteId;

  static const List<String> statusFilterOptions = [
    'All',
    'Draft',
    'In Progress',
    'Completed',
    'Pending',
  ];

  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(const LoadNotesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter({String? query, String? status, String? siteId}) {
    context.read<NoteBloc>().add(
          SearchAndFilterNotesEvent(
            query: query ?? _searchController.text,
            status: (status ?? _selectedStatus) == 'All' ? null : (status ?? _selectedStatus),
            siteId: siteId ?? _selectedSiteId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final storage = context.read<StorageService>();
    final baseUrl = storage.getBaseUrl();

    return Scaffold(
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes by title, site, or customer...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilter(query: '');
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                _applyFilter(query: val);
                setState(() {});
              },
            ),
          ),

          // 2. Status Filters Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                ...statusFilterOptions.map((st) {
                  final isSelected = _selectedStatus == st;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(st),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedStatus = st);
                        _applyFilter(status: st);
                      },
                      selectedColor: const Color(0xFF0F766E).withValues(alpha: 0.18),
                      checkmarkColor: const Color(0xFF0F766E),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF475569),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }),

                // Site Filter Dropdown Chip
                BlocBuilder<SiteBloc, SiteState>(
                  builder: (context, siteState) {
                    final sites = siteState is SiteLoaded ? siteState.sites : [];
                    if (sites.isEmpty) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: _selectedSiteId != null ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedSiteId != null ? Colors.blue : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedSiteId,
                          hint: const Text('All Sites', style: TextStyle(fontSize: 13)),
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Sites', style: TextStyle(fontSize: 13)),
                            ),
                            ...sites.map((s) => DropdownMenuItem<String?>(
                                  value: s.id,
                                  child: Text(s.name, style: const TextStyle(fontSize: 13)),
                                )),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedSiteId = val);
                            _applyFilter(siteId: val);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. Notes List
          Expanded(
            child: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NoteLoaded) {
                  final notes = state.notes;

                  if (notes.isEmpty) {
                    final isFiltering = _searchController.text.isNotEmpty ||
                        _selectedStatus != 'All' ||
                        _selectedSiteId != null;

                    return EmptyState(
                      icon: Icons.note_alt_outlined,
                      title: isFiltering ? 'No Matching Field Notes' : 'No Field Notes Yet',
                      message: isFiltering
                          ? 'Try changing your search terms or filters.'
                          : 'Tap the button below to record your first field inspection note.',
                      actionLabel: isFiltering ? null : 'Create Field Note',
                      onAction: isFiltering
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NoteFormScreen(),
                                ),
                              );
                            },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return _buildNoteCard(context, note, dateFormat, baseUrl);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NoteFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Field Note'),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    FieldNoteModel note,
    DateFormat dateFormat,
    String baseUrl,
  ) {
    // Check if thumbnail photo available
    Widget? thumbnail;
    if (note.localPhotoPath != null && File(note.localPhotoPath!).existsSync()) {
      thumbnail = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(note.localPhotoPath!),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    } else if (note.photoUrl != null && note.photoUrl!.isNotEmpty) {
      final fullUrl = note.photoUrl!.startsWith('http')
          ? note.photoUrl!
          : '$baseUrl${note.photoUrl}';
      thumbnail = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          fullUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_rounded, size: 36),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteDetailScreen(note: note),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Status Chip + Sync Status + Date
              Row(
                children: [
                  StatusChip(status: note.status),
                  const SizedBox(width: 8),
                  if (!note.isSynced)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sync_problem_rounded, size: 12, color: Colors.amber.shade800),
                          const SizedBox(width: 4),
                          Text(
                            'Offline',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    dateFormat.format(note.dateTime.toLocal()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title and Thumbnail
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (note.description != null && note.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            note.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (thumbnail != null) ...[
                    const SizedBox(width: 12),
                    thumbnail,
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Site and Customer Badges
              Row(
                children: [
                  if (note.siteName != null) ...[
                    const Icon(Icons.place_rounded, size: 14, color: Color(0xFF0369A1)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        note.siteName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                  if (note.customerName != null) ...[
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    const Icon(Icons.business_rounded, size: 14, color: Color(0xFF0F766E)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        note.customerName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
