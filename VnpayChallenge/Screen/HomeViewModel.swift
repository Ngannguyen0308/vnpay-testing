//
//  HomeViewModel.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import Foundation

class HomeViewModel {
    
    let photoListService: PhotoListService
    let imageService: ImageService

    init(photoListService: PhotoListService, imageService: ImageService) {
        self.photoListService = photoListService
        self.imageService = imageService
    }
    
    var photoList: [PhotoItem] = []
    var onDataUpdated: (() -> Void)?

    func fetchingPhotoList() {
        photoListService.getPhotoList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let photo):
                
                DispatchQueue.main.async {
                    self.photoList = photo
                    self.onDataUpdated?()
                }
                
            case .failure(let error):
                print("Error fetching photo list: \(error)")
            }
            
        }
    }
}
