//
//  Validator.swift
//  TalkSpace
//
//  Created by MacBook Pro on 24/09/2024.
//

import Foundation


// Validator for checking the password criteria
struct Validator {
    static func isEmailValid(_ email: String) -> Bool {
           let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Z|a-z]{2,}"
           let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
           return emailTest.evaluate(with: email)
       }
    
    // Password Validation
    static func isPasswordValid(_ password: String) -> Bool {
        return hasUpperCase(password) &&
               hasLowerCase(password) &&
               hasDigit(password) &&
               hasSpecialCharacter(password) &&
               hasMinimumLength(password)
    }
    
    static func hasUpperCase(_ password: String) -> Bool {
        return password.range(of: "[A-Z]", options: .regularExpression) != nil
    }
    
    static func hasLowerCase(_ password: String) -> Bool {
        return password.range(of: "[a-z]", options: .regularExpression) != nil
    }
    
    static func hasDigit(_ password: String) -> Bool {
        return password.range(of: "[0-9]", options: .regularExpression) != nil
    }
    
    static func hasSpecialCharacter(_ password: String) -> Bool {
        return password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
    }
    
    static func hasMinimumLength(_ password: String) -> Bool {
        return password.count >= 6
    }
}
