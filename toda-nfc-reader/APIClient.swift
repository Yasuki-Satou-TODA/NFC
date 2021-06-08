//
//  APIClient.swift
//  toda-nfc-reader
//
//  Created by Iichiro Kawashima on 2021/06/08.
//

import Foundation

enum APIError: Error {
    case offlineError
    case decodeError
    case noData
    case systemError
}

struct Request {

    let query: String

    var baseUrl: String {
        return "https://sw89w1f7wf.execute-api.ap-northeast-1.amazonaws.com/dev/nfctag"
    }

    var queryItem: [URLQueryItem] {
        return [URLQueryItem(name: "input_text", value: query)]
    }

    var urlRequest: URLRequest? {
        var compnents = URLComponents(string: baseUrl)
        compnents?.queryItems = queryItem
        guard let url = compnents?.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}

struct Response: Decodable {
    var outputText: String

    private enum CodingKeys: String, CodingKey {
        case outputText = "output_text"
    }
}

struct APIClient {

    static func fetch(
        query: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        guard let request = Request(query: query).urlRequest else { return }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let nsError = error as? NSError,
               nsError.domain == NSURLErrorDomain,
               nsError.code == NSURLErrorNotConnectedToInternet {
                debugPrint("Error: offline error")
                completion(.failure(APIError.offlineError))
                return

            } else if let error = error {
                Logger.printError(error: error)
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                debugPrint("Error: no response")
                completion(.failure(APIError.noData))
                return
            }

            switch response.statusCode {
            case 200..<300:

                do {
                    Logger.prettyPrint(data: data)
                    let json = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(json.outputText))

                } catch {
                    debugPrint("decodeError: \(error.localizedDescription)")
                    completion(.failure(APIError.decodeError))
                }
                
            default:
                debugPrint("statusCode: \(response.statusCode)")
                completion(.failure(APIError.systemError))
                Logger.prettyPrint(data: data)
            }
        }
        task.resume()
    }
}
