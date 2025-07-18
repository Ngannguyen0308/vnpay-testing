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
    
    var photoList: [PhotoItem] = []
    var onDataUpdated: (() -> Void)?
    
    private(set) var isLoading = false
    private(set) var isPaginating = false
    private(set) var isLastPage = false
    
    var currentPage = 1
    private let maxItemsPerPage = 100
    private let limitStep = 20
    private var currentLimit = 20
    
    init(photoListService: PhotoListService, imageService: ImageService) {
        self.photoListService = photoListService
        self.imageService = imageService
    }
    
    func fetchItemForPage(_ page: Int) {
        guard !isLoading else { return }
        
        isLoading = true
        isLastPage = false
        currentPage = page
        currentLimit = 20
        photoList = []
        onDataUpdated?()
        
        photoListService.getPhotoList(page: page, limit: currentLimit) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let photos):
                    self.photoList = photos
                    self.isLastPage = photos.count >= self.maxItemsPerPage
                    
                case .failure(let error):
                    print("Error fetching page \(page): \(error)")
                    self.photoList = []
                }
                
                self.onDataUpdated?()
            }
        }
    }
    
    func loadNextItem() {
        guard !isLoading, !isPaginating, !isLastPage else { return }
        
        let newLimit = min(currentLimit + limitStep, maxItemsPerPage)
        guard newLimit > currentLimit else {
            isLastPage = true
            return
        }
        
        isPaginating = true
        onDataUpdated?()
        
        photoListService.getPhotoList(page: currentPage, limit: newLimit) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isPaginating = false
                
                switch result {
                case .success(let photos):
                    self.photoList = photos
                    self.currentLimit = newLimit
                    self.isLastPage = photos.count >= self.maxItemsPerPage
                    
                case .failure(let error):
                    print("Pagination error: \(error)")
                }
                
                self.onDataUpdated?()
            }
        }
    }
    
    // handle refresh data with current state in that time
    func refreshCurrentPage() {
        guard !isLoading else { return }
        
        isLoading = true
        isLastPage = false
        photoList = []
        onDataUpdated?()
        
        photoListService.getPhotoList(page: currentPage, limit: currentLimit) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let photos):
                    self.photoList = photos
                    self.isLastPage = photos.count >= self.maxItemsPerPage
                    
                case .failure(let error):
                    print("Error refreshing page \(self.currentPage): \(error)")
                    self.photoList = []
                }
                
                self.onDataUpdated?()
            }
        }
    }
    
}

