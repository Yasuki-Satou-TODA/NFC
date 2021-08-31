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
        }
    }
}

extension UIViewController {
    func showAlert(_ type: AlertType) {
        self.present(type.alert, animated: true)
    }
}

extension AppDelegate {
    func showAlert(_ type: AlertType) {
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(type.alert, animated: true, completion: nil)
        }
    }
}
