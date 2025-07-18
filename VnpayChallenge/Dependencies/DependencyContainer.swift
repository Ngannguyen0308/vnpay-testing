//
//  DependencyContainer.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import Foundation

final class DependencyContainer {
    let httpClient: HTTPClient
    let photoListService: PhotoListService
    let imageService: ImageService
    
    init() {
        self.httpClient = URLSessionHTTPClient()
        self.photoListService = PhotoListService(httpClient: httpClient)
        self.imageService = ImageService(httpClient: httpClient)
    }
    
}
