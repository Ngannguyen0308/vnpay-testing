//
//  ImageService.swift
//  VnpayChallenge
//
//  Created by ADMIN on 17/7/25.
//

import Foundation
import UIKit

class ImageService {
    private let cache: ImageCache
    private let httpClient: HTTPClient
    
    init(cache: ImageCache = ImageCache() ,httpClient: HTTPClient) {
        self.cache = cache
        self.httpClient = httpClient
    }
    
    func downloadImg(from url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        // check cache
        if let image = cache.photo(for: url) {
            completion(.success(image))
            return
        }
        
        // if not -> download image
        httpClient.get(to: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.cache.insertPhoto(image, for: url)
                    DispatchQueue.main.async {
                        completion(.success(image))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingFailed(NSError(domain: "ImageService", code: -1))))
                    }
                }
                
            case .failure:
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed(NSError(domain: "ImageService", code: -2))))
                }
            }
        }
    }
    
    
}
