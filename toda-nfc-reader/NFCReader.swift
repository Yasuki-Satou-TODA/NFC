//
//  NFCReader.swift
//  toda-nfc-reader
//
//  Created by 小松崎千春 on 2021/05/31.
//

import CoreNFC

final class NFCReader: NSObject {

    var completionHandler: ((String) -> Void)?

    enum State {
        case standBy
        case read
        case write
    }

    private var message: NFCNDEFMessage?
    private var text: String = ""
    private var state: State = .standBy

    private lazy var session: NFCNDEFReaderSession = {
        return NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )
    }()

    func startSession(state: State) {

        self.state = state

        guard NFCNDEFReaderSession.readingAvailable else {
            debugPrint("この端末ではNFCが使えません。")
            return
        }

        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false
        )

        session.alertMessage = "NFCタグをiPhone上部に近づけてください．"
        session.begin()
    }

    func stopSession(
        alert: String = "",
        error: String = ""
    ) {

        session.alertMessage = alert

        if error.isEmpty {
            session.invalidate()
        } else {
            session.invalidate(errorMessage: error)
        }

        state = .standBy
    }

    func setInputNFCInfo(_ text: String?) {

        guard let text = text, !text.isEmpty else { return }
        self.text = text

        startSession(state: .write)
    }

    private func tagRemovalDetect(_ tag: NFCNDEFTag) {

        session.connect(to: tag) { [weak self] error in

            guard let self = self else { return }

            if let _ = error, !tag.isAvailable {
                self.session.restartPolling()
                return
            }

            DispatchQueue.global().asyncAfter(
                deadline: DispatchTime.now() + .milliseconds(500),
                execute: {
                    self.tagRemovalDetect(tag)
            })
        }
    }

    private func updateMessage(_ message: NFCNDEFMessage) -> Bool {

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

    private func makePayload(capacity: Int, tag: NFCNDEFTag) {

//        if let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: text, locale: Locale(identifier: "en")),
        if let payload = NFCNDEFPayload.wellKnownTypeURIPayload(string: text),
           let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: "toda-nfc-app://") {

            self.message = NFCNDEFMessage(records: [payload, urlPayload])

            if let length = self.message?.length, length > capacity {
                self.stopSession(error: "容量オーバーです。！\n容量は\(capacity)bytesです。")
                return
            }

            guard let message = self.message else { return }

            tag.writeNDEF(message) { [weak self] error in

                guard let self = self else { return }

                guard let writeError = error else {
                    self.stopSession(alert: "書き込みに成功しました。")
                    return
                }
                self.stopSession(error: writeError.localizedDescription)
            }
        }
    }
}

extension NFCReader: NFCNDEFReaderSessionDelegate {

    // 読み取り状態になったとき
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

    // 読み取りエラーが起こった時呼ばれる。ユーザーがキャンセルボタンを押すか、タイムアウトしたときに呼ばれる。
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        debugPrint(error.localizedDescription)
    }

    // 読み取りに成功したら呼ばれる。
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {

        if tags.count > 1 {
            session.alertMessage = "読み込ませるNFCタグは1枚にしてください．"
            guard let firstTag = tags.first else { return }
            self.tagRemovalDetect(firstTag)
            return
        }

        guard let tag = tags.first else { return }
        session.connect(to: tag) { error in
            if let _ = error {
                session.restartPolling()
                return
            }
        }

        tag.queryNDEFStatus { [weak self] (status, capacity, _) in

            guard let self = self else { return }

            switch (status, self.state) {
            case (.notSupported, _):
                self.stopSession(error: "このNFCタグは対応していません。")

            case (.readOnly, .write):
                self.stopSession(error: "このNFCタグには書き込めません。")

            case (_, .write):
                self.makePayload(capacity: capacity, tag: tag)

            case (_ , .read):
                tag.readNDEF { [weak self] (message, error) in

                    guard let self = self else { return }

                    if error != nil || message == nil {
                        guard let localizedError = error?.localizedDescription else { return }
                        self.stopSession(error: localizedError)
                        return
                    }

                    guard let message = message, self.updateMessage(message) else {
                        self.stopSession(error: "このNFCタグは対応していません。")
                        return
                    }

                    guard let tagTextInfomation = message.records.first(where: { String(data: $0.type, encoding: .utf8) == "U" })?.wellKnownTypeTextPayload().0 else { return }
                    self.completionHandler?(tagTextInfomation)
                }

            default:
                break
            }
        }
    }
}
