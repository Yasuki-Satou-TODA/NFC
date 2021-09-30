//
//  UserdefaultUtil.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/07/20.
//

import Foundation


final class UserdefaultsUtil {

    static var employeeNumber: String? {
        get { UserDefaults.standard.string(forKey: "employeeNumber") }
        set { UserDefaults.standard.setValue(newValue, forKey: "employeeNumber") }
    }

    static var nfcTag: String? {
        get { UserDefaults.standard.string(forKey: "nfcTag") }
        set { UserDefaults.standard.setValue(newValue, forKey: "nfcTag") }
    }
}
