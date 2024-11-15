//
//  LoginUITests.swift
//  agendaescolaredaiUITests
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import XCTest

final class LoginUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()

        addUIInterruptionMonitor(withDescription: "Handle Alert") { alert in
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testLoginWithValidCredentials() throws {
        let emailField = app.textFields["emailTextField"]
        XCTAssertTrue(emailField.exists, "El campo de correo electrónico no existe.")
        emailField.tap()
        emailField.typeText("admin@edai.com")

        let passwordField = app.secureTextFields["passwordSecureField"]
        XCTAssertTrue(passwordField.exists, "El campo de contraseña no existe.")
        passwordField.tap()
        passwordField.typeText("admin123")

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists, "El botón de inicio de sesión no existe.")
        loginButton.tap()

        let adminProfileGreeting = app.staticTexts["adminProfileGreeting"]
        XCTAssertTrue(adminProfileGreeting.waitForExistence(timeout: 5), "No se cargó correctamente el perfil del administrador.")
    }

    func testLoginWithInvalidCredentials() throws {
        let emailField = app.textFields["emailTextField"]
        XCTAssertTrue(emailField.exists, "El campo de correo electrónico no existe.")
        emailField.tap()
        emailField.typeText("invalid@correo.com")

        let passwordField = app.secureTextFields["passwordSecureField"]
        XCTAssertTrue(passwordField.exists, "El campo de contraseña no existe.")
        passwordField.tap()
        passwordField.typeText("wrongpassword")

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists, "El botón de inicio de sesión no existe.")
        loginButton.tap()

        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5), "No se mostró el mensaje de error.")
    }
}
