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

    var session: NFCNDEFReaderSession?
    var message: NFCNDEFMessage?
    var state: State = .standBy
    var text: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapScreen(_ sender: Any) {
        textField.resignFirstResponder()
    }

    @IBAction func write(_ sender: Any) {
        textField.resignFirstResponder()
        if textField.text == nil || textField.text!.isEmpty { return }
        text = textField.text!
        startSession(state: .write)
    }

    @IBAction func read(_ sender: Any) {
        startSession(state: .read)
    }

    func startSession(state: State) {
        self.state = state
        guard NFCNDEFReaderSession.readingAvailable else {
            Swift.print("この端末ではNFCが使えません。")
            return
        }
        session = NFCNDEFReaderSession(delegate: NFCReader(viewController: self), queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "NFCタグをiPhone上部に近づけてください．"
        session?.begin()
    }

    func stopSession(alert: String = "", error: String = "") {
        session?.alertMessage = alert
        if error.isEmpty {
            session?.invalidate()
        } else {
            session?.invalidate(errorMessage: error)
        }
        self.state = .standBy
    }

    func tagRemovalDetect(_ tag: NFCNDEFTag) {
        session?.connect(to: tag) { (error: Error?) in
            if error != nil || !tag.isAvailable {
                self.session?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
                self.tagRemovalDetect(tag)
            })
        }
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
        stopSession(alert: "[" + results.joined(separator: ", ") + "]")
        return true
    }
}
