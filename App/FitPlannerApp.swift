import SwiftUI

@main
struct FitPlannerApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView(container: container)
        }
    }
}
