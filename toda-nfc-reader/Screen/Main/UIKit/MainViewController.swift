//
//  ViewController.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/05/23.
//

import UIKit


final class MainViewController: UIViewController, NFCTagViewConfiguration {

    @IBOutlet weak var descriptionTextView: UILabel! {
        didSet {
            // MARK: - 文言変更の可能性あり
            descriptionTextView.text = "NFCタグをタッチしてください"
            descriptionTextView.adjustsFontSizeToFitWidth = true
        }
    }

    @IBOutlet weak var employeeNumberLabel: UILabel! {
        didSet {
            employeeNumberLabel.text = "社員番号:" + "  \(UserdefaultsUtil.employeeNumber ?? "未登録")"
            employeeNumberLabel.adjustsFontSizeToFitWidth = true
        }
    }

    @IBOutlet weak var employeeNumberInputTextField: UITextField! {
        didSet {
            
            guard let employeeNumber = UserdefaultsUtil.employeeNumber else { return }
            employeeNumberInputTextField.text = "\(employeeNumber)"
        }
    }

    @IBOutlet weak var placeholderText: UILabel! {
        didSet {
            placeholderText.text = "↑ご自身の社員番号を入力してください"
            placeholderText.adjustsFontSizeToFitWidth = true
        }
    }

    private let nfcReader = NFCReader()

    override func viewDidLoad() {
        super.viewDidLoad()

        nfcReader.completionHandler = { [weak self] nfcTag in
            self?.fetch(nfcTag: nfcTag)
        }

        employeeNumberInputTextField.delegate = self

    }

    @IBAction func didAdminButtonTapped(_ sender: Any) {
        let completion: ((Swift.Void) -> Void)? = { [weak self] _ in
            let vc = UIStoryboard(name: "AdminViewController", bundle: nil).instantiateViewController(identifier: "AdminViewController")
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self?.present(vc, animated: true)
        }

        let alert = AlertType.debug(completion: completion).alert
        self.present(alert, animated: true)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if employeeNumberInputTextField === textField {

            // TODO: - 不要であれば変更する
            switch employeeNumberInputTextField.validate() {
            case .valid:

                guard let number = employeeNumberInputTextField.text else { return }
                employeeNumberLabel.text = "社員番号:" + "  \(number)"
                UserdefaultsUtil.employeeNumber = number
            
            case let .invalid(error):
                self.showAlert(.invalidNumber(error))
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

