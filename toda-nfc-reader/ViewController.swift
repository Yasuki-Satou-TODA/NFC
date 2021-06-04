//
//  ViewController.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/05/23.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
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
