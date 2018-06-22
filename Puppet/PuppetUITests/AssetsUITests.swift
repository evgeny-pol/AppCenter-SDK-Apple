import XCTest

class AssetsUITests: XCTestCase {
  private var app : XCUIApplication?

  override func setUp() {
    super.setUp()

    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    app = XCUIApplication()
    app?.launch()
    guard let `app` = app else {
      return;
    }
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    handleSystemAlert()

    // Enable SDK (we need it in case SDK was disabled by the test, which then failed and didn't enabled SDK back).
    let appCenterButton = app.tables["App Center"].switches["Set Enabled"]
    if (!appCenterButton.boolValue) {
      appCenterButton.tap()
    }
  }

  func testAssets() {
    guard let `app` = app else {
      XCTFail();
      return
    }

    // Go to assets page and find "Set Enabled" button.
    app.tables["App Center"].staticTexts["Assets"].tap()

    let table = app.tables["Assets"]
    XCTAssertTrue(table.exists)

    let assetsButton = table.switches["Set Enabled"]
    XCTAssertTrue(table.exists)

    // Service should be enabled by default.
    XCTAssertTrue(assetsButton.boolValue)

    // Disable service.
    assetsButton.tap()

    // Button is disabled.
    XCTAssertFalse(assetsButton.boolValue)

    // Go back to start page.
    app.buttons["App Center"].tap()
    let appCenterButton = app.switches.element(boundBy: 0)

    // SDK should be enabled.
    XCTAssertTrue(appCenterButton.boolValue)

    // Disable SDK.
    appCenterButton.tap()

    // Go to assets page again.
    app.tables["App Center"].staticTexts["Assets"].tap()

    // Button should be disabled.
    XCTAssertFalse(assetsButton.boolValue)

    // Go back and enable SDK.
    app.buttons["App Center"].tap()

    // Enable SDK.
    appCenterButton.tap()

    // Go to assets page.
    app.tables["App Center"].staticTexts["Assets"].tap()

    // Service should be enabled.
    XCTAssertTrue(assetsButton.boolValue)
  }
}
