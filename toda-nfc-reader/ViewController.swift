//
//  ViewController.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/05/23.
//

import CoreNFC
import UIKit

enum State {
    case standBy
    case read
    case write
}

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var writeBtn: UIButton!
    @IBOutlet weak var readBtn: UIButton!

    var message: NFCNDEFMessage?
    var state: State = .standBy
    var nfcReader = NFCReader()

    override func viewDidLoad() {
        super.viewDidLoad()
        nfcReader.viewController = self
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
