//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class ViewsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars.staticTexts["Targets"].waitForExistence(timeout: 6.0))
        XCTAssertTrue(app.buttons["SpeziViews"].waitForExistence(timeout: 0.5))
        app.buttons["SpeziViews"].tap()
    }

    func testCanvas() throws {
#if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
        throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
#endif
        
        let app = XCUIApplication()
        
        XCTAssert(app.collectionViews.buttons["Canvas"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Canvas"].tap()
        
        XCTAssert(app.staticTexts["Did Draw Anything: false"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.scrollViews.otherElements.images["palette_tool_pencil_base"].waitForExistence(timeout: 2))
        
        let canvasView = app.scrollViews.firstMatch
        canvasView.swipeRight()
        canvasView.swipeDown()
        
        XCTAssert(app.staticTexts["Did Draw Anything: true"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Show Tool Picker"].waitForExistence(timeout: 2))
        app.buttons["Show Tool Picker"].tap()
        
        XCTAssert(app.scrollViews.otherElements.images["palette_tool_pencil_base"].waitForExistence(timeout: 10))
        canvasView.swipeLeft()

        sleep(1)
        app.buttons["Show Tool Picker"].tap()
        
        sleep(15) // waitForExistence will otherwise return immediately
        XCTAssertFalse(app.scrollViews.otherElements.images["palette_tool_pencil_base"].waitForExistence(timeout: 10))
        canvasView.swipeUp()
    }
    
    func testGeometryReader() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.collectionViews.buttons["Geometry Reader"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Geometry Reader"].tap()
        
        XCTAssert(app.staticTexts["300.000000"].exists)
        XCTAssert(app.staticTexts["200.000000"].exists)
    }
    
    func testLabel() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.collectionViews.buttons["Label"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Label"].tap()

        sleep(2)
        
        // The string value needs to be searched for in the UI.
        // swiftlint:disable:next line_length
        let text = "This is a label ... An other text. This is longer and we can check if the justified text works as expected. This is a very long text."
        XCTAssertEqual(app.staticTexts.allElementsBoundByIndex.filter { $0.label.replacingOccurrences(of: "\n", with: " ").contains(text) }.count, 2)
    }
    
    func testLazyText() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.collectionViews.buttons["Lazy Text"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Lazy Text"].tap()
        
        XCTAssert(app.staticTexts["This is a long text ..."].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["And some more lines ..."].exists)
        XCTAssert(app.staticTexts["And a third line ..."].exists)
        XCTAssert(app.staticTexts["An other lazy text ..."].exists)
    }
    
    func testMarkdownView() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.collectionViews.buttons["Markdown View"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Markdown View"].tap()
        
        XCTAssert(app.staticTexts["This is a markdown example."].waitForExistence(timeout: 2))

        sleep(6)
        
        XCTAssert(app.staticTexts["This is a markdown example taking 5 seconds to load."].exists)
    }

    func testAsyncButtonView() throws {
        let app = XCUIApplication()

        XCTAssert(app.collectionViews.buttons["Async Button"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Async Button"].tap()

        XCTAssert(app.collectionViews.buttons["Hello World"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Hello World"].tap()

        XCTAssert(app.collectionViews.staticTexts["Action executed"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Reset"].tap()

        XCTAssert(app.collectionViews.buttons["Hello Throwing World"].exists)
        app.collectionViews.buttons["Hello Throwing World"].tap()

        let alert = app.alerts.firstMatch.scrollViews.otherElements
        XCTAssert(alert.staticTexts["Custom Error"].waitForExistence(timeout: 1))
        XCTAssert(alert.staticTexts["Error was thrown!"].waitForExistence(timeout: 1))
        alert.buttons["OK"].tap()

        XCTAssert(app.collectionViews.buttons["Hello Throwing World"].isEnabled)
    }
}