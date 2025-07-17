//
//  HTTPClient.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import Foundation   

protocol HTTPClient {
    func get(to url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void)
}

enum HTTPMethod: String {
    case GET
}
