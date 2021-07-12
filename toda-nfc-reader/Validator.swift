//
//  Validator.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/07/07.
//

import Foundation
import UIKit

enum ValidationResult {
    case valid
    case invalid(ValidationError)
}

protocol ValidationErrorProtocol: LocalizedError { }

protocol Validator {
    func validate(_ value: String) -> ValidationResult
}

protocol CompositeValidator: Validator {
    var validators: [Validator] { get }
    func validate(_ value: String) -> ValidationResult
}

extension CompositeValidator {

    func validate(_ value: String) -> [ValidationResult] {
        return validators.map { $0.validate(value) }
    }

     func validate(_ value: String) -> ValidationResult {
        let results: [ValidationResult] = validate(value)

        let errors = results.filter { result -> Bool in
            switch result {
            case .valid: return false
            case .invalid: return true
            }
        }
        return errors.first ?? .valid
    }
}

enum ValidationError: ValidationErrorProtocol {

    case empty
    case length(Int)
    case nameFormat

    var errorDescription: String? {
        switch self {
        case .empty: return "文字を入力してください"
        case .length(let length): return "\(length)文字で入力してください。"
        case .nameFormat: return "半角数字のみで入力してください。"
        }
    }
}

struct EmptyValidator: Validator {

    func validate(_ value: String) -> ValidationResult {
        if value.isEmpty == true {
            return .invalid(.empty)
        } else {
            return .valid
        }
    }
}

struct LengthValidator: Validator {
    let length: Int

    func validate(_ value: String) -> ValidationResult {
        if value.count == length {
            return .valid
        } else {
            return .invalid(.length(length))
        }
    }
}

struct FormatValidator: Validator {

    let regExpression = "^[1-9]+$"

    func validate(_ value: String) -> ValidationResult {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regExpression)
        let result = predicate.evaluate(with: value)

        switch result {
        case true: return .valid
        case false: return .invalid(.nameFormat)
        }
    }
}

struct EmployeeNumberValidator: CompositeValidator {
    var validators: [Validator] = [
        EmptyValidator(),
        FormatValidator(),
        LengthValidator(length: 7)
    ]
}

extension UITextField {

    @discardableResult
    func validate() -> ValidationResult {
        return EmployeeNumberValidator().validate(text ?? "")
    }
}
