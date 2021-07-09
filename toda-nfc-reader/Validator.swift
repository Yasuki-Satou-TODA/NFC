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
    case length(min: Int, max: Int)
    case nameFormat

    var errorDescription: String? {
        switch self {
        case .empty: return "文字を入力してください"
        case .length(let min, let max): return "\(min)文字以上\(max)文字以下で入力してください。"
        case .nameFormat: return "数字英語大文字小文字のみで入力してください。"
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
    let min: Int
    let max: Int

    func validate(_ value: String) -> ValidationResult {
        if value.count >= min && value.count <= max {
            return .valid
        } else {
            return .invalid(.length(min: min, max: max))
        }
    }
}

struct FormatValidator: Validator {

    let regExpression = "^[1-9a-zA-Z]+$"

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
        LengthValidator(min: 1, max: 8),
        FormatValidator()
    ]
}

extension UITextField {

    @discardableResult
    func validate() -> ValidationResult {
        return EmployeeNumberValidator().validate(text ?? "")
    }
}
