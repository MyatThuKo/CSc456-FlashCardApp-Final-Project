//
//  StudySwiftUITests.swift
//  StudySwiftUITests
//
//  Created by Myat Thu Ko on 4/12/23.
//

import XCTest

final class StudySwiftUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSignUp() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)
        emailField.tap()
        emailField.typeText("example@domain.com")
        
        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("P@ssword12356")
        
        let confirmField = app.secureTextFields["Confirm Password"]
        XCTAssertTrue(confirmField.exists)
        confirmField.tap()
        confirmField.typeText("P@ssword12356")
        
        
        let button = app.buttons["Sign up"]
        XCTAssertTrue(button.exists)
        button.tap()
    }
    
    func testLogin() throws {
        let app = XCUIApplication()
        app.launch()
        
        let loginLink = app.buttons["Already a user? Login here."]
        XCTAssertTrue(loginLink.exists)
        loginLink.tap()
        
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)
        emailField.tap()
        emailField.typeText("example@domain.com")
        
        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("P@ssword12356")
        
        let button = app.buttons["Login"]
        XCTAssertTrue(button.exists)
        button.tap()
        
    }
    
    func testResetPassword() throws {
        let app = XCUIApplication()
        app.launch()
        
        let loginLink = app.buttons["Already a user? Login here."]
        XCTAssertTrue(loginLink.exists)
        loginLink.tap()
        
        let resetPasswordLink = app.buttons["Forgot password? Reset here."]
        XCTAssertTrue(resetPasswordLink.exists)
        resetPasswordLink.tap()
        
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)
        emailField.tap()
        emailField.typeText("example@domain.com")
        
        let button = app.buttons["Reset password"]
        XCTAssertTrue(button.exists)
        button.tap()
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
