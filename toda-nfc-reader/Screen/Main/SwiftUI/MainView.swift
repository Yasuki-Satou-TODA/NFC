//
//  MainView.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/06/05.
//

import SwiftUI

struct MainView: View {

    @State private var input = ""
    private let nfcReader = NFCReader()

    var body: some View {

        VStack(alignment: .center, spacing: 30, content: {
            Text(Resource.description)
                .frame(width: UIScreen.main.bounds.width - 40, height: 200, alignment: .center)
                .lineLimit(nil)

            VStack(alignment: .leading, spacing: 10, content: {
                Text("NFC tag informain")
                    .multilineTextAlignment(.leading)
                TextField("Input NFC tag infomation", text: $input,
                        onCommit: {

                                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: UIScreen.main.bounds.width - 60, height: 40, alignment: .center)
            })

            HStack(alignment: .center, spacing: 30, content: {
                Button(action: {
                    nfcReader.setInputNFCInfo(self.input)
                }, label: {
                    Text("Write NFC TAG")
                })
                .padding(.all)
                .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                )

                Button(action: {
                    nfcReader.startSession(state: .read)
                }, label: {
                    Text("Read NFC TAG")
                })
                .padding(.all)
                .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                )
            })

        }).onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

private extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
