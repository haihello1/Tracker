import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackersViewControllerLight() {
        let vc = makeTrackersViewController()

        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .light))
        )
    }

    func testTrackersViewControllerDark() {
        let vc = makeTrackersViewController()

        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .dark))
        )
    }

    // MARK: - Private

    private func makeTrackersViewController() -> UIViewController {
        let coreDataStack = CoreDataStack()
        let categoryStore = TrackerCategoryStore(context: coreDataStack.context)
        let recordStore = TrackerRecordStore(context: coreDataStack.context)

        let params = GeometricParams(
            cellCount: 2,
            leftInset: 16,
            rightInset: 16,
            cellSpacing: 9
        )

        let viewModel = TrackersViewModel(
            categoryStore: categoryStore,
            recordStore: recordStore
        )

        let vc = TrackersViewController(viewModel: viewModel, using: params)
        return vc
    }
}
