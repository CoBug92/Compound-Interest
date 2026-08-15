@testable import CompoundInterest
import XCTest

@MainActor
final class MainViewModelHistoryTests: XCTestCase {

    // MARK: - Tests

    func testSuccessfulCalculationSavesHistory() throws {
        let repository = InMemoryHistoryRepository()
        let viewModel = MainViewModel(
            historyRepository: repository,
            analyticsClient: AnalyticsClientSpy()
        )
        configureValidInput(viewModel)

        viewModel.calculateResult()

        XCTAssertNotNil(viewModel.result)
        XCTAssertEqual(try repository.loadAll().count, 1)
    }

    func testInvalidCalculationDoesNotSaveHistory() throws {
        let repository = InMemoryHistoryRepository()
        let viewModel = MainViewModel(
            historyRepository: repository,
            analyticsClient: AnalyticsClientSpy()
        )

        viewModel.calculateResult()

        XCTAssertNil(viewModel.result)
        XCTAssertTrue(try repository.loadAll().isEmpty)
    }

    func testAvailableRepositoryMakesHistoryAvailable() {
        let viewModel = MainViewModel(
            historyRepository: InMemoryHistoryRepository(),
            analyticsClient: AnalyticsClientSpy()
        )

        XCTAssertTrue(viewModel.isHistoryAvailable)
    }

    func testUnavailableRepositoryHidesHistoryAndPreservesInitialError() {
        let repository = UnavailableHistoryRepository(
            underlyingError: NSError(domain: "History", code: .zero)
        )
        let viewModel = MainViewModel(
            historyRepository: repository,
            analyticsClient: AnalyticsClientSpy()
        )

        XCTAssertFalse(viewModel.isHistoryAvailable)
        XCTAssertEqual(viewModel.historyErrorMessage, Localizations.History.Error.message)
    }

    func testApplyingHistoryEntryRestoresInputAndClearsResult() {
        let viewModel = MainViewModel(
            historyRepository: InMemoryHistoryRepository(),
            analyticsClient: AnalyticsClientSpy()
        )
        configureValidInput(viewModel)
        viewModel.calculateResult()
        let entry = HistoryEntry(
            id: UUID(),
            calculatedAt: Date(),
                calculatedDay: HistoryDay(
                    date: Date(),
                    calendar: .history
                ),
            input: CalculationInput(
                initialInvestment: 250_000,
                monthlyContribution: 5_000,
                contributionFrequency: .quarterly,
                investmentDuration: 24,
                investmentDurationUnit: .months,
                annualInterestRate: 8
            )
        )

        viewModel.applyHistoryEntry(entry)

        XCTAssertEqual(viewModel.initialInvestment, 250_000)
        XCTAssertEqual(viewModel.monthlyContribution, 5_000)
        XCTAssertEqual(viewModel.contributionFrequency, .quarterly)
        XCTAssertEqual(viewModel.investmentDuration, 24)
        XCTAssertEqual(viewModel.investmentDurationUnit, .months)
        XCTAssertEqual(viewModel.annualInterestRate, 8)
        XCTAssertNil(viewModel.result)
    }

    // MARK: - Private methods

    private func configureValidInput(_ viewModel: MainViewModel) {
        viewModel.initialInvestment = 100_000
        viewModel.monthlyContribution = 10_000
        viewModel.contributionFrequency = .monthly
        viewModel.investmentDuration = 10
        viewModel.investmentDurationUnit = .years
        viewModel.annualInterestRate = 12
    }
}
