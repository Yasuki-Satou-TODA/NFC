//
//  Logger.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/06/08.
//


import Foundation

struct Logger {
    static func printError(error: Error) {

        print("error Description: \(error.localizedDescription)")
    }

    static func printRequest(request: URLRequest) {

        let urlString = request.url?.absoluteString ?? ""
        let components = NSURLComponents(string: urlString)

        let method = request.httpMethod != nil ? "\(request.httpMethod!)": ""
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        let host = "\(components?.host ?? "")"

        var requestLog = "\n-------------------⚡️⚡️ APIRequest ⚡️⚡️------------------>\n"
        requestLog += "\(urlString)"
        requestLog += "\n\n"
        requestLog += "\(method) \(path)?\(query) HTTP/1.1\n"
        requestLog += "Host: \(host)\n"
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            requestLog += "\(key): \(value)\n"
        }
        if let body = request.httpBody {
            let bodyString = String(data: body, encoding: .utf8) ?? "Can't render body; not utf8 encoded"
            requestLog += "\n\(bodyString)\n"
        }

        requestLog += "\n------------------------------------------------------------------------>\n"
        print(requestLog)

    }

    static func prettyPrint(data: Data) {

        var requestLog = "\n-------------------🔥🔥 APIResponse 🔥🔥------------------>\n"
        requestLog += data.prettyPrintedJSONString ?? ""
        requestLog += "\n------------------------------------------------------------------------>\n"

        print(requestLog)
    }
}

extension Data {
    var prettyPrintedJSONString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else { return nil }

        return prettyPrintedString
    }
}
