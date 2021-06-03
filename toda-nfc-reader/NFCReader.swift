//
//  NFCReader.swift
//  toda-nfc-reader
//
//  Created by 小松崎千春 on 2021/05/31.
//

import CoreNFC
import Foundation
import UIKit

final class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {

    var viewController: ViewController!
    private var message: NFCNDEFMessage?
    private var text: String = ""

    private lazy var session: NFCNDEFReaderSession = {
        return NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
    }()

    func startSession(state: State) {
        viewController.state = state
        guard NFCNDEFReaderSession.readingAvailable else {
            Swift.print("この端末ではNFCが使えません。")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "NFCタグをiPhone上部に近づけてください．"
        session.begin()
    }

    func stopSession(alert: String = "", error: String = "") {
        session.alertMessage = alert
        if error.isEmpty {
            session.invalidate()
        } else {
            session.invalidate(errorMessage: error)
        }
        viewController.state = .standBy
    }

    func tagRemovalDetect(_ tag: NFCNDEFTag) {
        session.connect(to: tag) { (error: Error?) in
            if error != nil || !tag.isAvailable {
                self.session.restartPolling()
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

    func setInputNFCInfo(_ text: String?) {
        setText(text: text)
        startSession(state: .write)
    }

    // 読み取り状態になったとき
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    }

    // 読み取りエラーが起こった時呼ばれる。ユーザーがキャンセルボタンを押すか、タイムアウトしたときに呼ばれる。
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Swift.print(error.localizedDescription)
    }

    // 読み取りに成功したら呼ばれる。
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "読み込ませるNFCタグは1枚にしてください．"
            self.tagRemovalDetect(tags.first!)
            return
        }

        guard let tag = tags.first else { return }
        session.connect(to: tag) { (error) in
            if error != nil {
                session.restartPolling()
                return
            }
        }

        tag.queryNDEFStatus { (status, capacity, error) in
            if status == .notSupported {
                self.stopSession(error: "このNFCタグは対応していません。")
                return
            }
            if self.viewController.state == .write {
                if status == .readOnly {
                    self.stopSession(error: "このNFCタグには書き込めません。")
                    return
                }
                self.makePayload(capacity: capacity, tag: tag)
            } else if self.viewController.state == .read {
                tag.readNDEF { (message, error) in
                    if error != nil || message == nil {
                        self.stopSession(error: error!.localizedDescription)
                        return
                    }
                    if self.updateMessage(message!) {
                        self.stopSession(error: "このNFCタグは対応していません。")
                    }
                }
            }
        }
    }

    func makePayload(capacity: Int, tag: NFCNDEFTag) {
        if let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: text, locale: Locale(identifier: "en")) {

            let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: "toda-nfc-app://")!
            self.message = NFCNDEFMessage(records: [payload, urlPayload])
            if self.message!.length > capacity {
                self.stopSession(error: "容量オーバーです。！\n容量は\(capacity)bytesです。")
                return
            }
            tag.writeNDEF(self.message!) { (error) in
                if error != nil {
                    self.stopSession(error: error!.localizedDescription)
                } else {
                    self.stopSession(alert: "書き込みに成功しました。")
                }
            }
        }
    }

    func setText(text: String?) {
        guard let text = text else { return }
        if text.isEmpty { return }
        self.text = text
    }
}
