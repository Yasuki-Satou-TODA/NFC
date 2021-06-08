//
//  ViewController.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/05/23.
//

import UIKit

struct Resource {
    static let description: String = """
            アプリ説明:
            - NFCタグに書き込みたい情報を入力欄に入力し書き込みボタンを押下します。
            - 端末をNFCタグに近づけ、タグに入力した情報の書込みます。
            - 書き込みが完了したら、読み取りボタンを押下しNFCタグの情報を読取ります。
            """
}

final class MainViewController: UIViewController {

    @IBOutlet weak var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.text = Resource.description
        }
    }

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.placeholder = "NFCタグの情報を入力してください"
        }
    }

    @IBOutlet weak var writeBtn: UIButton!

    @IBOutlet weak var readBtn: UIButton!

    private let nfcReader = NFCReader()

    override func viewDidLoad() {
        super.viewDidLoad()

        nfcReader.completionHandler = { [weak self] in
            self?.fetch()
        }
    }

    @IBAction func tapScreen(_ sender: Any) {
        textField.resignFirstResponder()
    }

    @IBAction func write(_ sender: Any) {
        textField.resignFirstResponder()
        nfcReader.setInputNFCInfo(textField.text)
    }

    @IBAction func read(_ sender: Any) {
        nfcReader.startSession(state: .read)
    }

    @IBAction func didHttpButtonTapped(_ sender: Any) {
        fetch()
    }

    private func fetch() {
        APIClient.fetch(query: "test") { [weak self] result in
            switch result {
            case .success(let response):

                DispatchQueue.main.async {
                    self?.showAlert(.success(response: response))
                }

            case .failure:

                DispatchQueue.main.async {
                    self?.showAlert(.failure)
                }
            }
        }
    }

}

private extension MainViewController {

    enum AlertType {
        case success(response: String)
        case failure

        var alert: UIAlertController {
            switch self {
            case .success(let response):
                let alert = UIAlertController(
                    title: "成功",
                    message: response,
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                return alert

            case .failure:
                let alert = UIAlertController(
                    title: "エラー",
                    message: "APIリクエストが失敗しました",
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
