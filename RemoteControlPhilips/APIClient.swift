//
//  APIClient.swift
//  RemoteControlPhilips
//
//  Created by Daian Aiziatov on 13/01/2019.
//  Copyright © 2019 Daian Aiziatov. All rights reserved.
//

import Foundation

struct APIClient {
    
    var ipAddress: String
    
    private lazy var baseURL: URL = {
        let URLString = "https://\(self.ipAddress):1925"
        return URL(string: URLString)!
    }()
    
    private(set) lazy var session: URLSession = {
        return URLSession.shared
    }()
    
    init(ipAddress: String) {
        self.ipAddress = ipAddress
    }
    
    mutating func fetchingSystemInfo(completion: @escaping (Result<SystemInfo, DataResponseError>) -> Void) {
        let urlRequest = URLRequest(url: baseURL.appendingPathComponent(APIRequest.systemNamePath))
        var encodedURLRequest = urlRequest.encode(with: nil)
        encodedURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        print(encodedURLRequest)
        session.dataTask(with: encodedURLRequest, completionHandler: { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.hasSuccessStatusCode,
                let data = data
                else {
                    completion(Result.failure(DataResponseError.network))
                    return
            }
            guard let decodedResponse = try? JSONDecoder().decode(SystemInfo.self, from: data) else {
                completion(Result.failure(DataResponseError.decoding))
                return
            }
            completion(Result.success(decodedResponse))
        }).resume()
    }
    
}
