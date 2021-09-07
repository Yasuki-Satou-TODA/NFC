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

        nfcReader.completionHandler = { [weak self] nfcTag in
            self?.fetch(nfcTag: nfcTag)
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
}
