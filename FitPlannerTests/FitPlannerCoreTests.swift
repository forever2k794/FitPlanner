import XCTest

final class FitPlannerCoreTests: XCTestCase {
    func testJSONRepositoryDeleteRemovesOnlyUserRecordAndKeepsMockHistoryOutOfJSON() throws {
        let documentsDirectory = try makeTemporaryDirectory()
        let store = LocalJSONWorkoutRecordStore(documentsDirectory: documentsDirectory)
        let repository = JSONFitnessRepository(workoutRecordStore: store)
        let deletedRecord = makeRecord(title: "Delete Me")
        let remainingRecord = makeRecord(title: "Keep Me")

        store.saveRecords([deletedRecord, remainingRecord])

        repository.deleteWorkoutRecord(id: deletedRecord.id)

        let storedRecords = store.loadRecords()
        XCTAssertFalse(storedRecords.contains { $0.id == deletedRecord.id })
        XCTAssertTrue(storedRecords.contains { $0.id == remainingRecord.id })

        let storedIDs = Set(storedRecords.map(\.id))
        let mockIDs = Set(MockWorkoutRecords.history.map(\.id))
        XCTAssertTrue(storedIDs.isDisjoint(with: mockIDs))

        let mergedRecords = repository.fetchWorkoutRecords()
        XCTAssertTrue(mergedRecords.contains { $0.id == remainingRecord.id })
        for mockRecord in MockWorkoutRecords.history {
            XCTAssertTrue(mergedRecords.contains { $0.id == mockRecord.id })
        }
    }

    func testFitnessServiceDeleteForwardsToRepositoryAndReloadsWithoutRecord() {
        let record = makeRecord(title: "Service Delete")
        let repository = SpyFitnessRepository(records: [record])
        let service = FitnessService(repository: repository)

        service.deleteWorkoutRecord(id: record.id)

        XCTAssertEqual(repository.deletedIDs, [record.id])
        XCTAssertFalse(service.workoutRecords().contains { $0.id == record.id })
    }

    @MainActor
    func testWorkoutHistoryViewModelDeleteRefreshesRecordsImmediately() {
        let record = makeRecord(title: "Visible User Record")
        let repository = InMemoryFitnessRepository(workoutRecords: [record])
        let service = FitnessService(repository: repository)
        let viewModel = WorkoutHistoryViewModel(fitnessService: service)

        XCTAssertTrue(viewModel.records.contains { $0.id == record.id })

        viewModel.delete(record: record)

        XCTAssertFalse(viewModel.records.contains { $0.id == record.id })
    }

    @MainActor
    func testWorkoutHistoryDetailViewModelSavePersistsEditedRecord() throws {
        let documentsDirectory = try makeTemporaryDirectory()
        let store = LocalJSONWorkoutRecordStore(documentsDirectory: documentsDirectory)
        let repository = JSONFitnessRepository(workoutRecordStore: store)
        let service = FitnessService(repository: repository)
        let record = makeRecord(title: "Original Title", note: "Original Note")
        repository.saveWorkoutRecord(record)
        let viewModel = WorkoutHistoryDetailViewModel(session: record, fitnessService: service)
        let updatedRecord = WorkoutSessionRecord(
            id: record.id,
            title: "Updated Title",
            date: record.date,
            exerciseLogs: record.exerciseLogs,
            isCompleted: record.isCompleted,
            note: "Updated Note"
        )

        viewModel.save(updatedRecord)

        XCTAssertTrue(viewModel.didSaveSuccessfully)
        XCTAssertEqual(viewModel.session.title, "Updated Title")
        XCTAssertEqual(viewModel.session.note, "Updated Note")

        let reloadedRecord = try XCTUnwrap(service.workoutRecords().first { $0.id == record.id })
        XCTAssertEqual(reloadedRecord.title, "Updated Title")
        XCTAssertEqual(reloadedRecord.note, "Updated Note")
    }

    func testExerciseDecodesFromLegacyJSONWithFallbackValues() throws {
        let exerciseID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let json = """
        {
          "id": "\(exerciseID.uuidString)",
          "name": "Legacy Bench Press",
          "primaryMuscleGroup": "Chest",
          "equipment": "Barbell",
          "note": "Imported from legacy schema"
        }
        """

        let exercise = try JSONDecoder().decode(Exercise.self, from: Data(json.utf8))

        XCTAssertEqual(exercise.id, exerciseID)
        XCTAssertEqual(exercise.name, "Legacy Bench Press")
        XCTAssertEqual(exercise.primaryMuscleGroup, "Chest")
        XCTAssertEqual(exercise.equipment, "Barbell")
        XCTAssertEqual(exercise.note, "Imported from legacy schema")
        XCTAssertEqual(exercise.defaultSets, 3)
        XCTAssertEqual(exercise.defaultReps, 10)
        XCTAssertFalse(exercise.equipmentTypes.isEmpty)
        XCTAssertFalse(exercise.supportedFocusTypes.isEmpty)
        XCTAssertEqual(Set(exercise.supportedTrainingStyles), [.strength, .hypertrophy, .endurance])
    }

    private func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("FitPlannerTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: url)
        }
        return url
    }

    private func makeRecord(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(timeIntervalSince1970: 1_700_000_000),
        note: String = "Test note"
    ) -> WorkoutSessionRecord {
        WorkoutSessionRecord(
            id: id,
            title: title,
            date: date,
            exerciseLogs: [
                ExerciseLog(
                    exercise: Exercise(
                        name: "Bench Press",
                        primaryMuscleGroup: "Chest",
                        equipment: "Barbell"
                    ),
                    sets: [
                        SetLog(
                            setNumber: 1,
                            weightInKilograms: 60,
                            reps: 8,
                            isCompleted: true
                        )
                    ]
                )
            ],
            isCompleted: true,
            note: note
        )
    }
}

private final class SpyFitnessRepository: FitnessRepository {
    private var records: [WorkoutSessionRecord]
    private(set) var deletedIDs: [UUID]

    init(records: [WorkoutSessionRecord]) {
        self.records = records
        self.deletedIDs = []
    }

    func fetchUserProfile() -> UserProfile {
        MockUserProfile.current
    }

    func fetchExercises() -> [Exercise] {
        MockExercises.all
    }

    func fetchWorkoutRecords() -> [WorkoutSessionRecord] {
        records
    }

    func fetchGeneratedPlan() -> GeneratedPlan {
        MockGeneratedPlan.nextWeekPlan
    }

    func saveUserProfile(_ profile: UserProfile) {}

    func saveWorkoutRecord(_ record: WorkoutSessionRecord) {
        records.append(record)
    }

    func upsertWorkoutRecords(_ records: [WorkoutSessionRecord]) {
        for record in records {
            updateWorkoutRecord(record)
        }
    }

    func updateWorkoutRecord(_ record: WorkoutSessionRecord) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else {
            records.append(record)
            return
        }
        records[index] = record
    }

    func deleteWorkoutRecord(id: UUID) {
        deletedIDs.append(id)
        records.removeAll { $0.id == id }
    }

    func canDeleteWorkoutRecord(id: UUID) -> Bool {
        records.contains { $0.id == id }
    }

    func canEditWorkoutRecord(id: UUID) -> Bool {
        records.contains { $0.id == id }
    }

    func plannedWorkout(on date: Date) -> PlannedWorkoutDay? {
        nil
    }

    func nextPlannedWorkout(from date: Date) -> PlannedWorkoutDay? {
        nil
    }
}