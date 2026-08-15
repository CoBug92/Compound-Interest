import SwiftUI

struct MainView: View {

    // MARK: - Observable properties

    @ObservedObject private var viewModel: MainViewModel
    @FocusState private var focusedParameter: MainParameter?

    // MARK: - Init/Deinit

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Layout

    var body: some View {
        ScrollView(showsIndicators: false) {
            contentView
                .padding(.horizontal, Margin.x5)
                .padding(.top, Margin.x4)
        }
        .background(Color(.Background.primary))
        .scrollDismissesKeyboard(.immediately)
        .animation(.keyMetricsAppearance, value: viewModel.result)
        .toolbar {
            if viewModel.isHistoryAvailable {
                ToolbarItem(placement: .topBarTrailing) {
                    historyNavigationLink
                }
            }
        }
        .alert(
            Localizations.History.Error.title,
            isPresented: historyErrorBinding
        ) {
            Button(Localizations.Common.Ok.buttonTitle) {
                viewModel.clearHistoryError()
            }
        } message: {
            Text(Localizations.History.Error.message)
        }
    }

    private var contentView: some View {
        VStack(spacing: Margin.x10) {
            MainParametersView(
                viewModel: viewModel,
                focusedParameter: $focusedParameter
            )
            calculateButton
            if let result = viewModel.result {
                MainResultView(
                    result: result,
                    keyIndicators: viewModel.keyIndicators,
                    onExportStarted: viewModel.startResultExport
                )
            }
        }
    }

    private var calculateButton: some View {
        GradientButton(
            title: Localizations.Main.Calculate.Button.title,
            action: calculateResult
        )
        .padding(.top, Margin.x8)
    }

    private var historyNavigationLink: some View {
        NavigationLink {
            HistoryView(viewModel: viewModel.makeHistoryViewModel())
        } label: {
            Image(systemName: SFSymbols.clockArrowCirclepath)
                .foregroundStyle(Color(.Button.primary))
        }
        .simultaneousGesture(
            TapGesture().onEnded(viewModel.openHistory)
        )
        .accessibilityLabel(Localizations.History.Open.buttonTitle)
    }

    // MARK: - Private methods

    private func calculateResult() {
        focusedParameter = nil
        viewModel.calculateResult()
    }

    private var historyErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.historyErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearHistoryError()
                }
            }
        )
    }
}

// MARK: - Animation

private extension Animation {
    static let keyMetricsAppearance = easeOut(duration: .keyMetricsAnimationDuration)
}

// MARK: - Constants

private extension Double {
    static let keyMetricsAnimationDuration: Double = 0.25
}

// MARK: - Preview

#Preview {
    MainView(
        viewModel: MainViewModel(
            historyRepository: InMemoryHistoryRepository(),
            analyticsClient: NoopAnalyticsClient()
        )
    )
}
