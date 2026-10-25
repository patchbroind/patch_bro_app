import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patch_bro/features/employer/jobs/data/models/employer_job_model.dart';
import 'package:patch_bro/features/employer/jobs/presentation/widgets/job_detail_schedule_card.dart';

void main() {
  test('parses scheduled slots from API arrays and encoded JSON strings', () {
    final fromList = EmployerJobModel.fromJson(
      _jobJson(['morning_1', 'afternoon_2']),
    );
    final fromJsonString = EmployerJobModel.fromJson(
      _jobJson('["morning_1","afternoon_2"]'),
    );

    expect(fromList.scheduledSlotIds, ['morning_1', 'afternoon_2']);
    expect(fromJsonString.scheduledSlotIds, ['morning_1', 'afternoon_2']);
  });

  testWidgets('job schedule card displays every selected slot', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final job = EmployerJobModel.fromJson(
      _jobJson(['morning_1', 'afternoon_2']),
    ).toEntity();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JobDetailScheduleCard(job: job)),
      ),
    );

    expect(find.text('8:00 AM – 10:00 AM'), findsOneWidget);
    expect(find.text('3:00 PM – 5:00 PM'), findsOneWidget);
    expect(find.text('Time'), findsNothing);
    final slotCards = find.byType(InkWell);
    expect(slotCards, findsNWidgets(4));
    expect(
      tester.getTopLeft(slotCards.at(0)).dy,
      tester.getTopLeft(slotCards.at(1)).dy,
    );
    expect(
      tester.getTopLeft(slotCards.at(1)).dx,
      greaterThan(tester.getTopLeft(slotCards.at(0)).dx),
    );
  });
}

Map<String, dynamic> _jobJson(dynamic slots) => {
  'id': 'job-1',
  'category': 'Plumbing',
  'skill': 'Pipe repair',
  'scheduled_date': '2030-01-02',
  'scheduled_time': '08:00:00',
  'scheduled_slots': slots,
  'location_address': 'Saved address',
  'description': 'Repair a leaking pipe.',
  'status': 'open',
  'created_at': '2029-12-01T00:00:00Z',
  'updated_at': '2029-12-01T00:00:00Z',
};
