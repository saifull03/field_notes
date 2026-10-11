import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field_notes/models/customer_model.dart';
import 'package:field_notes/models/site_model.dart';
import 'package:field_notes/models/field_note_model.dart';
import 'package:field_notes/views/widgets/status_chip.dart';

void main() {
  group('Model Serialization & Offline Integrity Tests', () {
    test('CustomerModel toMap and fromMap preserve offline attributes', () {
      final customer = CustomerModel(
        id: 'cust-123',
        name: 'Metro Water Utility',
        contactInformation: 'ops@metrowater.com',
        siteCount: 4,
        noteCount: 12,
        isSynced: false,
      );

      final map = customer.toMap();
      final revived = CustomerModel.fromMap(map);

      expect(revived.id, 'cust-123');
      expect(revived.name, 'Metro Water Utility');
      expect(revived.contactInformation, 'ops@metrowater.com');
      expect(revived.siteCount, 4);
      expect(revived.noteCount, 12);
      expect(revived.isSynced, false);
      expect(revived.deleted, false);
    });

    test('SiteModel toMap and fromMap preserve relations', () {
      final site = SiteModel(
        id: 'site-456',
        customerId: 'cust-123',
        customerName: 'Metro Water Utility',
        name: 'Pump Station Bravo',
        address: '789 Aqueduct Rd',
        isSynced: true,
      );

      final map = site.toMap();
      final revived = SiteModel.fromMap(map);

      expect(revived.id, 'site-456');
      expect(revived.customerId, 'cust-123');
      expect(revived.customerName, 'Metro Water Utility');
      expect(revived.name, 'Pump Station Bravo');
      expect(revived.address, '789 Aqueduct Rd');
      expect(revived.isSynced, true);
    });

    test('FieldNoteModel serialization handles GPS, photo, and status', () {
      final note = FieldNoteModel(
        id: 'note-789',
        siteId: 'site-456',
        siteName: 'Pump Station Bravo',
        customerId: 'cust-123',
        customerName: 'Metro Water Utility',
        title: 'Main Valve Lubrication',
        description: 'Applied high-temperature grease. Valve operational.',
        latitude: 34.0522,
        longitude: -118.2437,
        locationName: 'Valve Pit #3',
        status: 'In Progress',
        localPhotoPath: '/data/user/0/cache/photo_1.jpg',
        isSynced: false,
      );

      final map = note.toMap();
      final revived = FieldNoteModel.fromMap(map);

      expect(revived.id, 'note-789');
      expect(revived.siteId, 'site-456');
      expect(revived.title, 'Main Valve Lubrication');
      expect(revived.latitude, 34.0522);
      expect(revived.longitude, -118.2437);
      expect(revived.locationName, 'Valve Pit #3');
      expect(revived.status, 'In Progress');
      expect(revived.localPhotoPath, '/data/user/0/cache/photo_1.jpg');
      expect(revived.isSynced, false);
    });
  });

  group('Widget Tests', () {
    testWidgets('StatusChip renders status and reacts to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusChip(
              status: 'Completed',
              isSelected: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);

      await tester.tap(find.text('Completed'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
