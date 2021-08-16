//
//  UserdefaultUtil.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/07/20.
//

import Foundation


final class UserdefaultsUtil {

    static func get() -> String? {
        UserDefaults.standard.string(forKey: "employeeNumber")
    }

    static func set(_ employeeNumber: String) {
        UserDefaults.standard.setValue(employeeNumber, forKey: "employeeNumber")
    }
}
