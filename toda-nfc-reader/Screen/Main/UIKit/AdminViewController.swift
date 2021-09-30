//
//  AdminViewController.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/09/07.
//

import UIKit

final class AdminViewController: UIViewController, NFCTagViewConfiguration {

    private let nfcReader = NFCReader()

    override func viewDidLoad() {
        super.viewDidLoad()

        nfcTagInputTextField.delegate = self

        nfcReader.completionHandler = { [weak self] nfcTag in
            self?.fetch(nfcTag: nfcTag)
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "NFCタグ情報"
            titleLabel.adjustsFontSizeToFitWidth = true
        }
    }

    @IBOutlet weak var nfcTagInputTextField: UITextField! {
        didSet {
            nfcTagInputTextField.placeholder = "NFCタグの情報を入力してください"
        }
    }

    @IBAction func write(_ sender: Any) {

        guard let nfcTag = UserdefaultsUtil.nfcTag, !nfcTag.isEmpty else {
            let alert = AlertType.noValue
            self.showAlert(alert)
            return

        }
        nfcReader.setInputNFCInfo(nfcTag)
    }

    @IBAction func read(_ sender: Any) {
        nfcReader.startSession(state: .read)
    }

    @IBAction func didHttpButtonTapped(_ sender: Any) {
        guard let nfcTag = UserdefaultsUtil.nfcTag, !nfcTag.isEmpty else {
            let alert = AlertType.noValue
            self.showAlert(alert)
            return
        }

        fetch(nfcTag: nfcTag)
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func tapScreen(_ sender: Any) {
        nfcTagInputTextField.resignFirstResponder()
    }
}

extension AdminViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if nfcTagInputTextField === textField {
            UserdefaultsUtil.nfcTag = nfcTagInputTextField.text
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
