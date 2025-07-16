//
//  NetworkError.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case decodingFailed(Error)
}
