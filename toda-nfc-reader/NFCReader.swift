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

    var message: NFCNDEFMessage?
    var viewController: ViewController!

    init(viewController: ViewController) {
        self.viewController = viewController
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
            viewController.tagRemovalDetect(tags.first!)
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
                self.viewController.stopSession(error: "このNFCタグは対応していません。")
                return
            }
            if self.viewController.state == .write {
                if status == .readOnly {
                    self.viewController.stopSession(error: "このNFCタグには書き込めません。")
                    return
                }
                self.makePayload(capacity: capacity, tag: tag)
            } else if self.viewController.state == .read {
                tag.readNDEF { (message, error) in
                    if error != nil || message == nil {
                        self.viewController.stopSession(error: error!.localizedDescription)
                        return
                    }
                    if !self.viewController.updateMessage(message!) {
                        self.viewController.stopSession(error: "このNFCタグは対応していません。")
                    }
                }
            }
        }
    }

    func makePayload(capacity: Int, tag: NFCNDEFTag) {
        if let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: self.viewController.text, locale: Locale(identifier: "en")) {

            let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: "toda-nfc-app://")!
            self.message = NFCNDEFMessage(records: [payload, urlPayload])
            if self.message!.length > capacity {
                self.viewController.stopSession(error: "容量オーバーです。！\n容量は\(capacity)bytesです。")
                return
            }
            tag.writeNDEF(self.message!) { (error) in
                if error != nil {
                    self.viewController.stopSession(error: error!.localizedDescription)
                } else {
                    self.viewController.stopSession(alert: "書き込みに成功しました。")
                }
            }
        }
    }
}
