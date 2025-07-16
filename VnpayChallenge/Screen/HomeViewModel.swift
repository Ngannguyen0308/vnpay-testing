//
//  HomeViewModel.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import Foundation

class HomeViewModel {
    let photoListService: PhotoListService
    
    init(photoListService: PhotoListService) {
        self.photoListService = photoListService
    }
    
    var photoList: [PhotoItem] = []
    
    func fetchingPhotoList() {
        photoListService.getPhotoList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let photo):
                
                DispatchQueue.main.async {
                    self.photoList = photo
                    print("CHECKKKK \(photo)")
                }
                
            case .failure(let error):
                print("Error fetching photo list: \(error)")
            }
            
        }
    }
}
