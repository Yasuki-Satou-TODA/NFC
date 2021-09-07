//
//  AlertUtils.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/07/07.
//
import UIKit

enum AlertType {
    case apiSuccess(response: String)
    case apiFailure
    case invalidNumber(ValidationError)
    case noValue
    case debug(completion: ((Swift.Void) -> Void)?)

    var alert: UIAlertController {
        switch self {
        case .apiSuccess(let response):
            let alert = UIAlertController(
                title: "成功",
                message: response,
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
            return alert

        case .apiFailure:
            let alert = UIAlertController(
                title: "エラー",
                message: "APIリクエストが失敗しました",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
            return alert

        case let .invalidNumber(error):
            let alert = UIAlertController(
                title: "エラー",
                message: error.errorDescription,
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
            return alert

        case .noValue:
            let alert = UIAlertController(
                title: "エラー",
                message: "NFCTagが入力されていません",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
            return alert

        case let .debug(completion):
            var textField = UITextField()
            let alertController = UIAlertController(title: "Admin only", message: "Please enter password", preferredStyle: .alert)
            alertController.addTextField { alertTextField in
                textField = alertTextField
            }

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if textField.text == "toda" {
                    if let completion = completion {
                        completion(())
                    }
                }
            })
            return alertController
        }
    }
}

extension AppDelegate {
    func showAlert(_ type: AlertType) {
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(type.alert, animated: true, completion: nil)
        }
    }
}
