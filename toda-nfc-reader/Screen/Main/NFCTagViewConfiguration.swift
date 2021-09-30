//
//  NFCTagViewConfiguration.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/09/07.
//

import UIKit

protocol NFCTagViewConfiguration {
    func fetch(nfcTag: String)
    func showAlert(_ type: AlertType)
}

extension NFCTagViewConfiguration where Self: UIViewController {
    func fetch(nfcTag: String) {

        guard let number = UserdefaultsUtil.employeeNumber else { return }

        APIClient.fetch(nfcTag: nfcTag, employeeNumber: number) { [weak self] result in
            switch result {
            case .success(let response):

                DispatchQueue.main.async {
                    self?.showAlert(.apiSuccess(response: response))
                }

            case .failure:

                DispatchQueue.main.async {
                    self?.showAlert(.apiFailure)
                }
            }
        }
    }

    func showAlert(_ type: AlertType) {
        self.present(type.alert, animated: true)
    }
}
