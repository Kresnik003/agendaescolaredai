//
//  NavigationUITests.swift
//  agendaescolaredaiUITests
//
//  Created by Juan Antonio Sánchez Carrillo on 23/11/24.
//

import XCTest

final class NavigationUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Configuración inicial antes de cada test.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Manejar alertas emergentes inesperadas.
        addUIInterruptionMonitor(withDescription: "Handle Alert") { alert in
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }
    }

    override func tearDownWithError() throws {
        // Liberar recursos después de cada test.
        app = nil
    }

    /// Test para navegar a la vista de administración de aulas desde el perfil del administrador.
    func testNavigationToAdminAulasListView() throws {
        // **Paso 1: Iniciar sesión**
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

        // **Paso 2: Navegar a "Administrar Aulas"**
        let adminAulasOption = app.images["adminAulasOption"]
        XCTAssertTrue(adminAulasOption.waitForExistence(timeout: 5), "La opción 'Administrar Aulas' no existe.")
        adminAulasOption.tap()
    }

    /// Test para navegar a la vista de administración de usuarios desde el perfil del administrador.
    func testNavigationToAdminUsersListView() throws {
        // **Paso 1: Iniciar sesión**
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

        // **Paso 2: Navegar a "Administrar Usuarios"**
        let adminUsersOption = app.images["adminUsersOption"]
        XCTAssertTrue(adminUsersOption.waitForExistence(timeout: 5), "La opción 'Administrar Usuarios' no existe.")
        adminUsersOption.tap()
    }

    /// Test para navegar a la vista de noticias desde el perfil del administrador.
    func testNavigationToAdminNoticiasListView() throws {
        // **Paso 1: Iniciar sesión**
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

        // **Paso 2: Navegar a "Noticias"**
        let adminNoticiasOption = app.images["adminNoticiasOptionCard"]
        XCTAssertTrue(adminNoticiasOption.waitForExistence(timeout: 5), "La opción 'Noticias' no existe.")
        adminNoticiasOption.tap()
    }
}
