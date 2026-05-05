import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var userProfile: UserProfile

    private let fitnessService: FitnessService

    init(fitnessService: FitnessService) {
        self.fitnessService = fitnessService
        self.userProfile = fitnessService.userProfile()
    }

    func refresh() {
        userProfile = fitnessService.userProfile()
    }
}
