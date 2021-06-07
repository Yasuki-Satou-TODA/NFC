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
}
