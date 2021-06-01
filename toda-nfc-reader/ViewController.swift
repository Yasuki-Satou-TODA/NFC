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
    var text: String = ""
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
        if textField.text == nil || textField.text!.isEmpty { return }
        text = textField.text!
        nfcReader.startSession(state: .write)
    }

    @IBAction func read(_ sender: Any) {
        nfcReader.startSession(state: .read)
    }

    func updateMessage(_ message: NFCNDEFMessage) -> Bool {
        if message.records.isEmpty { return false }
        var results = [String]()
        for record in message.records {
            if let type = String(data: record.type, encoding: .utf8) {
                if type == "T" { // データ形式がテキストならば
                    let res = record.wellKnownTypeTextPayload()
                    if let text = res.0 {
                        results.append("text: \(text)")
                    }
                } else if type == "U" { // データ形式がURLならば
                    let res = record.wellKnownTypeURIPayload()
                    if let url = res {
                        results.append("url: \(url)")
                    }
                }
            }
        }
        nfcReader.stopSession(alert: "[" + results.joined(separator: ", ") + "]")
        return true
    }
}
