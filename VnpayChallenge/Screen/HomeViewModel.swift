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
    var isLoading: Bool = false
    
    func fetchingPhotoList() {
        isLoading = true
        onDataUpdated?()
        
        photoListService.getPhotoList { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let photo):
                    self.photoList = photo
                case .failure(let error):
                    print("Error fetching photo list: \(error)")
                    self.photoList = []
                }
                self.onDataUpdated?()
            }
        }
    }
}
