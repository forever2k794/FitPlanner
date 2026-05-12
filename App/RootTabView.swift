import SwiftUI

struct RootTabView: View {
    @ObservedObject var container: AppContainer

    var body: some View {
        TabView {
            DashboardView(
                viewModel: DashboardViewModel(
                    progressSummaryService: container.progressSummaryService
                )
            )
            .tabItem {
                Label("首頁", systemImage: "house.fill")
            }

            WorkoutView(
                viewModel: WorkoutViewModel(
                    fitnessService: container.fitnessService,
                    planGenerationService: container.planGenerationService
                )
            )
            .tabItem {
                Label("今日訓練", systemImage: "figure.strengthtraining.traditional")
            }

            PlanCalendarView(
                viewModel: PlanCalendarViewModel(
                    planGenerationService: container.planGenerationService,
                    fitnessService: container.fitnessService
                )
            )
            .tabItem {
                Label("課表", systemImage: "calendar")
            }

            ProgressView(
                viewModel: ProgressViewModel(
                    progressSummaryService: container.progressSummaryService,
                    fitnessService: container.fitnessService
                ),
                fitnessService: container.fitnessService
            )
            .tabItem {
                Label("進度", systemImage: "chart.bar.fill")
            }

            SettingsView(
                viewModel: SettingsViewModel(
                    fitnessService: container.fitnessService,
                    backupExportService: container.backupExportService,
                    backupImportService: container.backupImportService
                )
            )
            .tabItem {
                Label("設定", systemImage: "gearshape.fill")
            }
        }
    }
}

#Preview {
    RootTabView(container: .preview())
}
