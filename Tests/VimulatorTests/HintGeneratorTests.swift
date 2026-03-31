#if targetEnvironment(simulator)
import XCTest
@testable import Vimulator

final class HintGeneratorTests: XCTestCase {
  func testGeneratesCorrectCount() {
    let hints = HintGenerator.generate(count: 100)
    XCTAssertEqual(hints.count, 100)
  }

  func testAllUnique() {
    let hints = HintGenerator.generate(count: 1000)
    XCTAssertEqual(Set(hints).count, 1000)
  }

  func testFirstHints() {
    let hints = HintGenerator.generate(count: 3)
    XCTAssertEqual(hints[0], "a")
    XCTAssertEqual(hints[1], "s")
    XCTAssertEqual(hints[2], "d")
  }

  func testUniformLength() {
    // When count > 26, all hints should be 2 characters
    let hints = HintGenerator.generate(count: 30)
    XCTAssertTrue(hints.allSatisfy { $0.count == 2 })
    XCTAssertEqual(hints[0], "aa")
    XCTAssertEqual(hints[1], "as")
    XCTAssertEqual(hints[26], "sa")
  }

  func testPerformance() {
    measure(metrics: [XCTClockMetric()]) {
      _ = HintGenerator.generate(count: 500)
    }
  }
}
#endif
