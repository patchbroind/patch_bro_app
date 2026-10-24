import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patch_bro/features/employer/invitations/domain/repository/employer_invitations_repository.dart';
import 'package:patch_bro/features/employer/invitations/presentation/providers/employer_invitations_providers.dart';
import 'package:patch_bro/features/employer/jobs/domain/entities/employer_job_entity.dart';
import 'package:patch_bro/features/employer/post_job/domain/repositories/post_job_repository.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_controller.dart';
import 'package:patch_bro/features/employer/post_job/presentation/controllers/post_job_state.dart';
import 'package:patch_bro/features/employer/post_job/presentation/providers/post_job_providers.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_worker_card_stack.dart';
import 'package:patch_bro/features/employer/post_job/presentation/widgets/post_job_worker_selection_step.dart';
import 'package:patch_bro/features/employer/workers/domain/entity/employer_worker_entity.dart';
import 'package:patch_bro/features/employer/workers/domain/repository/employer_workers_repository.dart';
import 'package:patch_bro/features/employer/workers/presentation/providers/employer_workers_providers.dart';
import 'package:patch_bro/features/profile/domain/entities/profile_location.dart';
import 'package:patch_bro/shared/invitations/domain/entities/job_invitation_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (call) async => 'test-recorder-id',
      );

  group('PostJobController create wizard', () {
    late ProviderContainer container;
    late _FakePostJobRepository postJobRepository;
    late _FakeEmployerInvitationsRepository invitationRepository;
    late List<String> apiCalls;

    setUp(() {
      apiCalls = [];
      postJobRepository = _FakePostJobRepository(apiCalls);
      invitationRepository = _FakeEmployerInvitationsRepository(apiCalls);
      container = ProviderContainer(
        overrides: [
          postJobRepositoryProvider.overrideWithValue(postJobRepository),
          employerInvitationsRepositoryProvider.overrideWithValue(
            invitationRepository,
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test(
      'blocks incomplete steps and keeps entered data while moving back',
      () {
        final controller = container.read(postJobControllerProvider.notifier);

        controller.startCreateSession(category: 'Plumbing');
        expect(container.read(postJobControllerProvider).currentStep, 0);
        expect(controller.goToNextStep(), isFalse);
        expect(
          container.read(postJobControllerProvider).errorMessage,
          isNotNull,
        );

        controller.setSkill('Pipe repair');
        expect(controller.goToNextStep(), isTrue);
        controller.setDate(DateTime(2030, 1, 2));
        expect(
          controller.validateStep(1),
          'Please select at least one time slot.',
        );
        controller.toggleTimeSlot('morning_1');
        expect(controller.goToNextStep(), isTrue);
        controller.setLocation(
          const ProfileLocation(
            latitude: 10.0,
            longitude: 76.0,
            address: 'Saved address',
          ),
        );
        expect(controller.goToNextStep(), isTrue);

        controller.goToPreviousStep();
        final state = container.read(postJobControllerProvider);
        expect(state.currentStep, 2);
        expect(state.skill, 'Pipe repair');
        expect(state.locationAddress, 'Saved address');
      },
    );

    test('new create sessions discard the previous draft', () {
      final controller = container.read(postJobControllerProvider.notifier);
      controller.setSkill('Old skill');
      controller.setDescription('Old description');

      controller.startCreateSession(category: 'Electrical');
      final state = container.read(postJobControllerProvider);

      expect(state.currentStep, 0);
      expect(state.category, 'Electrical');
      expect(state.skill, isEmpty);
      expect(state.description, isEmpty);
      expect(state.status, PostJobStatus.initial);
    });

    test(
      'edit mode restores selected slots or derives a legacy slot from time',
      () {
        final controller = container.read(postJobControllerProvider.notifier);
        final job = EmployerJobEntity(
          id: 'job-1',
          category: 'Plumbing',
          skill: 'Pipe repair',
          date: DateTime(2030, 1, 2),
          time: DateTime(2030, 1, 2, 8),
          locationAddress: 'Saved address',
          description: 'Repair a leaking pipe.',
          status: EmployerJobStatus.active,
          createdAt: DateTime(2029, 12, 1),
          updatedAt: DateTime(2029, 12, 1),
          scheduledSlotIds: const ['afternoon_2', 'morning_1'],
        );

        controller.initializeForEdit(job);
        expect(container.read(postJobControllerProvider).selectedSlotIds, [
          'morning_1',
          'afternoon_2',
        ]);

        controller.initializeForEdit(
          EmployerJobEntity(
            id: 'legacy-job',
            category: 'Plumbing',
            skill: 'Pipe repair',
            date: DateTime(2030, 1, 2),
            time: DateTime(2030, 1, 2, 13),
            locationAddress: 'Saved address',
            description: 'Repair a leaking pipe.',
            status: EmployerJobStatus.active,
            createdAt: DateTime(2029, 12, 1),
            updatedAt: DateTime(2029, 12, 1),
          ),
        );
        expect(container.read(postJobControllerProvider).selectedSlotIds, [
          'afternoon_1',
        ]);
      },
    );

    test('worker selection is unique, limited to five, and can be changed', () {
      final controller = container.read(postJobControllerProvider.notifier);

      for (var index = 0; index < 5; index++) {
        expect(controller.toggleSelectedWorker('worker-$index'), isTrue);
      }
      expect(controller.toggleSelectedWorker('worker-5'), isFalse);
      expect(controller.toggleSelectedWorker('worker-0'), isTrue);
      expect(controller.toggleSelectedWorker('worker-5'), isTrue);
      expect(controller.toggleSelectedWorker('worker-6'), isFalse);
      expect(
        container.read(postJobControllerProvider).selectedWorkerIds,
        hasLength(5),
      );
    });

    test(
      'worker selections can be reconciled and the active card index persists',
      () {
        final controller = container.read(postJobControllerProvider.notifier);
        controller.toggleSelectedWorker('worker-1');
        controller.toggleSelectedWorker('worker-2');
        controller.setActiveWorkerCardIndex(3);

        controller.reconcileSelectedWorkers({'worker-2'});
        final state = container.read(postJobControllerProvider);

        expect(state.selectedWorkerIds, ['worker-2']);
        expect(state.activeWorkerCardIndex, 3);
      },
    );

    test('final step requires at least one selected worker', () {
      final controller = container.read(postJobControllerProvider.notifier);

      expect(controller.validateStep(5), 'Please select at least one worker.');
      controller.toggleSelectedWorker('worker-1');
      expect(controller.validateStep(5), isNull);
    });

    test('job creation failure never sends worker invitations', () async {
      postJobRepository.createdJobId = null;
      final controller = container.read(postJobControllerProvider.notifier);
      _fillJobForm(controller, ['worker-1']);

      final result = await controller.submitAndInviteWorkers([
        _worker('worker-1'),
      ]);

      expect(result.jobCreated, isFalse);
      expect(apiCalls, ['create-job']);
      expect(invitationRepository.invitedWorkerIds, isEmpty);
    });

    test(
      'invitations use the job ID returned by successful job creation',
      () async {
        postJobRepository.createdJobId = 'created-job';
        final controller = container.read(postJobControllerProvider.notifier);
        _fillJobForm(controller, ['worker-1']);

        final result = await controller.submitAndInviteWorkers([
          _worker('worker-1'),
        ]);

        expect(result.jobId, 'created-job');
        expect(result.failedWorkers, isEmpty);
        expect(apiCalls.take(2), ['create-job', 'invite:created-job:worker-1']);
        expect(invitationRepository.invitedWorkerIds, ['worker-1']);
      },
    );

    test(
      'invitation retry targets only workers from the failed result',
      () async {
        invitationRepository.failedWorkerIds.add('worker-2');
        final controller = container.read(postJobControllerProvider.notifier);
        _fillJobForm(controller, ['worker-1', 'worker-2']);

        final initial = await controller.submitAndInviteWorkers([
          _worker('worker-1'),
          _worker('worker-2'),
        ]);
        invitationRepository.failedWorkerIds.clear();
        final retried = await controller.retryFailedWorkerInvitations(
          jobId: initial.jobId!,
          failedWorkers: initial.failedWorkers,
        );

        expect(initial.failedWorkers.map((worker) => worker.id), ['worker-2']);
        expect(retried, isEmpty);
        expect(apiCalls.where((call) => call.startsWith('invite:')).toList(), [
          'invite:job-id:worker-1',
          'invite:job-id:worker-2',
          'invite:job-id:worker-2',
        ]);
      },
    );
  });

  testWidgets('worker card stack swipes without selecting and opens details', (
    tester,
  ) async {
    var activeIndex = 0;
    final selectedIds = <String>{};
    String? openedDetailsFor;
    final workers = [_worker('worker-1'), _worker('worker-2')];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Center(
              child: SizedBox(
                width: 360,
                height: 440,
                child: PostJobWorkerCardStack(
                  workers: workers,
                  activeIndex: activeIndex,
                  selectedWorkerIds: selectedIds,
                  eligibleWorkerIds: {'worker-1', 'worker-2'},
                  allowIneligibleSelection: false,
                  height: 440,
                  onIndexChanged: (index) =>
                      setState(() => activeIndex = index),
                  onToggleSelected: (id) {
                    setState(() {
                      if (!selectedIds.add(id)) selectedIds.remove(id);
                    });
                  },
                  onMoreDetails: (worker) => openedDetailsFor = worker.id,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 of 2'), findsOneWidget);
    expect(find.text('Minimum wage'), findsAtLeastNWidgets(1));
    expect(find.text('More Details'), findsAtLeastNWidgets(1));
    final workerOneCheckbox = tester.widget<Checkbox>(
      find.byKey(const ValueKey('post-job-worker-selection-worker-1')),
    );
    expect(workerOneCheckbox.value, isFalse);
    await tester.tap(find.text('Worker worker-1'));
    await tester.pumpAndSettle();
    expect(selectedIds, {'worker-1'});
    expect(
      tester
          .widget<Checkbox>(
            find.byKey(const ValueKey('post-job-worker-selection-worker-1')),
          )
          .value,
      isTrue,
    );
    await tester.tap(
      find.byKey(const ValueKey('post-job-worker-selection-worker-1')),
    );
    await tester.pumpAndSettle();
    expect(selectedIds, isEmpty);
    expect(
      tester
          .widget<Checkbox>(
            find.byKey(const ValueKey('post-job-worker-selection-worker-1')),
          )
          .value,
      isFalse,
    );
    await tester.drag(
      find.byType(PostJobWorkerCardStack),
      const Offset(-150, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 of 2'), findsOneWidget);
    expect(selectedIds, isEmpty);
    await tester.tap(
      find.byKey(const ValueKey('post-job-worker-selection-worker-2')),
    );
    await tester.pumpAndSettle();
    expect(selectedIds, {'worker-2'});
    expect(
      tester
          .widget<Checkbox>(
            find.byKey(const ValueKey('post-job-worker-selection-worker-2')),
          )
          .value,
      isTrue,
    );

    await tester.tap(find.byTooltip('Previous worker'));
    await tester.pumpAndSettle();
    expect(selectedIds, {'worker-2'});
    await tester.tap(find.text('More Details').last);
    await tester.pumpAndSettle();
    expect(openedDetailsFor, 'worker-1');
    expect(selectedIds, {'worker-2'});
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'worker step filters by category and date slots, then searches by name',
    (tester) async {
      final workers = [
        _worker('worker-1', skills: const ['Unrelated skill']),
        _worker('worker-2'),
        _worker('worker-3', profession: 'Electrical'),
      ];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            employerWorkersRepositoryProvider.overrideWithValue(
              _FakeEmployerWorkersRepository(workers),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: PostJobWorkerSelectionStep()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final controller = ProviderScope.containerOf(
        tester.element(find.byType(PostJobWorkerSelectionStep)),
      ).read(postJobControllerProvider.notifier);
      controller
        ..setCategory('Plumbing')
        ..setDate(DateTime(2030, 1, 2))
        ..toggleTimeSlot('morning_1');
      await tester.pumpAndSettle();

      expect(find.text('Show All Workers'), findsNothing);
      expect(find.text('Worker worker-1'), findsOneWidget);
      expect(find.text('Worker worker-2'), findsOneWidget);
      expect(find.text('Worker worker-3'), findsNothing);
      expect(find.text('Eligible workers'), findsNothing);

      controller.toggleTimeSlot('morning_2');
      await tester.pumpAndSettle();
      expect(find.text('No available workers'), findsOneWidget);
      controller.toggleTimeSlot('morning_2');
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('post-job-worker-selection-worker-1')),
      );
      await tester.pumpAndSettle();
      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(PostJobWorkerSelectionStep)),
        ).read(postJobControllerProvider).selectedWorkerIds,
        ['worker-1'],
      );

      await tester.enterText(find.byType(TextField), 'worker-2');
      await tester.pumpAndSettle();
      expect(find.text('Worker worker-2'), findsOneWidget);
      expect(find.text('Worker worker-1'), findsNothing);

      await tester.enterText(find.byType(TextField), 'missing');
      await tester.pumpAndSettle();
      expect(find.text('No workers found'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('image state never exposes more than two selectable slots', () {
    final state = PostJobState(images: [File('first.jpg'), File('second.jpg')]);

    expect(state.totalImageCount, 2);
    expect(state.remainingImageSlots, 0);
    expect(state.canAddImage, isFalse);
  });
}

void _fillJobForm(
  PostJobController controller,
  List<String> selectedWorkerIds,
) {
  controller.startCreateSession(category: 'Plumbing');
  controller.setSkill('Pipe repair');
  controller.setDate(DateTime(2030, 1, 2));
  controller.toggleTimeSlot('morning_1');
  controller.setLocation(
    const ProfileLocation(
      latitude: 10,
      longitude: 76,
      address: 'Saved address',
    ),
  );
  controller.setDescription('Repair a leaking pipe.');
  for (final id in selectedWorkerIds) {
    controller.toggleSelectedWorker(id);
  }
}

EmployerWorkerEntity _worker(
  String id, {
  String profession = 'Plumbing',
  List<String> skills = const ['Pipe repair'],
}) => EmployerWorkerEntity(
  id: id,
  name: 'Worker $id',
  profession: profession,
  rating: 4.5,
  reviewCount: 2,
  distanceKm: 1,
  isFavourite: false,
  isAvailableToday: true,
  availableTomorrow: true,
  skills: skills,
  availabilitySchedule: const {
    '2030-01-02': {'morning_1': 'available'},
  },
);

class _FakePostJobRepository implements PostJobRepository {
  _FakePostJobRepository(this.calls);

  final List<String> calls;
  String? createdJobId = 'job-id';

  @override
  Future<String?> createJob({
    required String category,
    required String skill,
    required DateTime date,
    required DateTime time,
    required List<String> slotIds,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required String description,
    required File? voiceRecording,
    required List<File> images,
  }) async {
    calls.add('create-job');
    return createdJobId;
  }

  @override
  Future<EmployerJobEntity> updateJob({
    required String jobId,
    required String category,
    required String skill,
    required DateTime date,
    required DateTime time,
    required List<String> slotIds,
    required double latitude,
    required double longitude,
    required String locationAddress,
    required String description,
    required List<String> keepImagePaths,
    required List<File> newImages,
    required String? existingAudioPath,
    required bool removeExistingAudio,
    required File? newAudio,
  }) => throw UnimplementedError();
}

class _FakeEmployerInvitationsRepository
    implements EmployerInvitationsRepository {
  _FakeEmployerInvitationsRepository(this.calls);

  final List<String> calls;
  final List<String> invitedWorkerIds = [];
  final Set<String> failedWorkerIds = {};

  @override
  Future<JobInvitationEntity> inviteWorker({
    required String jobId,
    required String workerId,
  }) async {
    calls.add('invite:$jobId:$workerId');
    invitedWorkerIds.add(workerId);
    if (failedWorkerIds.contains(workerId)) throw StateError('Invite failed');
    final now = DateTime.now();
    return JobInvitationEntity(
      id: 'invitation-$workerId',
      jobId: jobId,
      employerId: 'employer',
      workerId: workerId,
      status: JobInvitationStatus.pending,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 1)),
    );
  }

  @override
  Future<List<JobInvitationEntity>> getJobInvitations(String jobId) async =>
      const [];

  @override
  Future<List<JobInvitationEntity>> getWorkerInvitationStatuses(
    String workerId,
  ) async => const [];

  @override
  Stream<void> watchJobInvitations(String jobId) => const Stream.empty();
}

class _FakeEmployerWorkersRepository implements EmployerWorkersRepository {
  _FakeEmployerWorkersRepository(this.workers);

  final List<EmployerWorkerEntity> workers;

  @override
  Future<List<EmployerWorkerEntity>> getWorkers() async => workers;

  @override
  Future<void> toggleFavourite(String workerId) async {}
}
