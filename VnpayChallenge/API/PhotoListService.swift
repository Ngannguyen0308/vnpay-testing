//
//  PhotoListService.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import Foundation


class PhotoListService {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func getPhotoList(page: Int = 1, limit: Int = 20, completion: @escaping (Result<[PhotoItem], NetworkError>) -> Void) {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=\(limit)") else {
            completion(.failure(.invalidURL))
            return
        }
                
        httpClient.get(to: url) { result in
            switch result {
            case .success(let data):
                do {
                    let photosList = try JSONDecoder().decode([PhotoItem].self, from: data)
                    completion(.success(photosList))
                } catch {
                    completion(.failure(.decodingFailed(error)))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
