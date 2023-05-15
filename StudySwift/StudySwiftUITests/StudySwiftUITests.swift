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
    
    let app = XCUIApplication()
    let exampleEmail = "test@example.com"
    let examplePassword = "Test@212"

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTextField(fieldName: String, exampleString: String, secure: Bool) {
        var field = app.textFields[fieldName]
        if secure {
            field = app.secureTextFields[fieldName]
            
        }
        
        XCTAssertTrue(field.exists)
        field.tap()
        field.typeText(exampleString)
    }
    
    func testStaticText(searchText: String) {
        let text = searchText
        let predicate = NSPredicate(format: "label LIKE %@", text)
        let staticTextElement = app.staticTexts.element(matching: predicate)
        XCTAssertTrue(staticTextElement.exists)
    }
    
    func testButton(buttonName: String) {
        let button = app.buttons[buttonName]
        XCTAssertTrue(button.exists)
        button.tap()
    }
    
    func testTabBarButton(buttonName: String) {
        let button = app.tabBars.buttons[buttonName]
        XCTAssertTrue(button.exists)
        button.tap()
    }

    func testSignUp() throws {
        app.launch()
    
        testTextField(fieldName: "Email", exampleString: exampleEmail, secure: false)
        testTextField(fieldName: "Password", exampleString: examplePassword, secure: true)
        testTextField(fieldName: "Confirm Password", exampleString: examplePassword, secure: true)

        testButton(buttonName: "Sign up")
    }
    
    func testInvalidEmail() throws {
        app.launch()
    
        // type password into all 3 fields to see if the correct error message will show
        testTextField(fieldName: "Email", exampleString: examplePassword, secure: false)
        testTextField(fieldName: "Password", exampleString: examplePassword, secure: true)
        testTextField(fieldName: "Confirm Password", exampleString: examplePassword, secure: true)

        testButton(buttonName: "Sign up")
        
        testStaticText(searchText: "Invalid email!")
    }
    
    func testInvalidPasswords() throws {
        app.launch()
    
        // type email into all 3 fields to see if the correct error message will show
        testTextField(fieldName: "Email", exampleString: exampleEmail, secure: false)
        testTextField(fieldName: "Password", exampleString: exampleEmail, secure: true)
        testTextField(fieldName: "Confirm Password", exampleString: exampleEmail, secure: true)

        testButton(buttonName: "Sign up")
        
        testStaticText(searchText: "Password must be at least 6 characters long and contain at least one uppercase letter, one lowercase letter, and one special character.")
    }
    
    func testDifferentPasswords() throws {
        app.launch()
    
        // type different passwords to see if the correct error message will show
        testTextField(fieldName: "Email", exampleString: exampleEmail, secure: false)
        testTextField(fieldName: "Password", exampleString: examplePassword, secure: true)
        testTextField(fieldName: "Confirm Password", exampleString: exampleEmail, secure: true)

        testButton(buttonName: "Sign up")
        
        testStaticText(searchText: "Passwords do not match! Please try again.")
    }
    
    func testLogin() throws {
        app.launch()
        
        testButton(buttonName: "Already a user? Login here.")
        
        testTextField(fieldName: "Email", exampleString: exampleEmail, secure: false)
        testTextField(fieldName: "Password", exampleString: examplePassword, secure: true)
        
        testButton(buttonName: "Login")
    }
    
    func testHomeTab() throws {
        app.launch()
        try testLogin()
        testTabBarButton(buttonName: "Home")
    }
    
    func testProfileTab() throws {
        app.launch()
        try testLogin()
        testTabBarButton(buttonName: "Profile")
    }
    
    func testLogout() throws {
        app.launch()
        try testLogin()
        testTabBarButton(buttonName: "Profile")
        
        testButton(buttonName: "Logout")
    }
    
    func testProfileReset() throws {
        app.launch()
        try testLogin()
        testTabBarButton(buttonName: "Profile")
        
        testTextField(fieldName: "Email", exampleString: exampleEmail, secure: false)
        testTextField(fieldName: "Old Password", exampleString: examplePassword, secure: true)
        testTextField(fieldName: "New Password", exampleString: exampleEmail, secure: true)
        testTextField(fieldName: "Confirm Password", exampleString: exampleEmail, secure: true)
        
        testButton(buttonName: "Reset password")
    }
    
    func testResetPassword() throws {
        app.launch()
        
        testButton(buttonName: "Already a user? Login here.")
        testButton(buttonName: "Forgot password? Reset here.")
        
        testTextField(fieldName: "Email", exampleString: exampleEmail, secure: false)
        testButton(buttonName: "Reset password")
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
