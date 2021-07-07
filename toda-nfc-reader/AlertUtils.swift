//
//  AlertUtils.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/07/07.
//
import UIKit

extension UIViewController {
    enum AlertType {
        case apiSuccess(response: String)
        case apiFailure
        case invalidNumber

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

            case .invalidNumber:
                let alert = UIAlertController(
                    title: "不要な文字が含まれています",
                    message: "もう一度入力してください",
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                return alert
            }
        }
    }

    func showAlert(_ type: AlertType) {
        self.present(type.alert, animated: true)
    }
}
