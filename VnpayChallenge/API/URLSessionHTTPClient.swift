//
//  URLSessionHTTPClient.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import Foundation

class URLSessionHTTPClient: HTTPClient {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(to url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        
        session.dataTask(with: request) { dataInfor, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = dataInfor else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(data))
        
        }.resume()
        
    }
}
