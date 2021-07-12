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

    @IBOutlet weak var employeeNumberLabel: UILabel! {
        didSet {
            employeeNumberLabel.text = "社員番号:" + "  \(get() ?? "未登録")"
        }
    }

    @IBOutlet weak var employeeNumberInputTextField: UITextField! {
        didSet {
            employeeNumberInputTextField.placeholder = "社員番号を入力してください"
        }
    }

    @IBOutlet weak var nfcTagInputTextField: UITextField! {
        didSet {
            nfcTagInputTextField.placeholder = "NFCタグの情報を入力してください"
        }
    }

    @IBOutlet weak var writeBtn: UIButton!

    @IBOutlet weak var readBtn: UIButton!

    private let nfcReader = NFCReader()

    override func viewDidLoad() {
        super.viewDidLoad()

        nfcReader.completionHandler = { [weak self] nfcTag in
            self?.fetch(nfcTag: nfcTag)
        }

        employeeNumberInputTextField.delegate = self
        nfcTagInputTextField.delegate = self
    }

    @IBAction func tapScreen(_ sender: Any) {
        nfcTagInputTextField.resignFirstResponder()
    }

    @IBAction func write(_ sender: Any) {
        nfcTagInputTextField.resignFirstResponder()
        nfcReader.setInputNFCInfo(nfcTagInputTextField.text)
    }

    @IBAction func read(_ sender: Any) {
        nfcReader.startSession(state: .read)
    }

    @IBAction func didHttpButtonTapped(_ sender: Any) {
        guard let nfcTag = nfcTagInputTextField.text else { return }
        fetch(nfcTag: nfcTag)
    }

    private func fetch(nfcTag: String) {

        guard let number = get() else { return }

        APIClient.fetch(nfcTag: nfcTag, employeeNumber: number) { [weak self] result in
            switch result {
            case .success(let response):

                DispatchQueue.main.async {
                    self?.showAlert(.apiSuccess(response: response))
                }

            case .failure:

                DispatchQueue.main.async {
                    self?.showAlert(.apiFailure)
                }
            }
        }
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if employeeNumberInputTextField === textField {

            // TODO: - 不要であれば変更する
            switch employeeNumberInputTextField.validate() {
            case .valid:

                guard let number = employeeNumberInputTextField.text else { return }
                set(number)

            case .invalid:
                self.showAlert(.invalidNumber)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

private extension MainViewController {

    func get() -> String? {
        UserDefaults.standard.string(forKey: "employeeNumber")
    }

    func set(_ employeeNumber: String) {
        UserDefaults.standard.setValue(employeeNumber, forKey: "employeeNumber")
    }
}
