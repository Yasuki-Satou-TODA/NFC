//
//  LifeCycleSwiftUIApp.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/06/06.
//

import SwiftUI

/// - Note: SwiftUIのViewを起動時に呼び出したい場合は、
/// LifeCycleSwiftUIAppの@mainのコメントアウトを外す
/// AppDelegateの@mainにコメントアウトをつける

// @main
struct LifeCycleSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
