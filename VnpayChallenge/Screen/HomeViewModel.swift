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
    
    var filteredPhotoList: [PhotoItem] = []
    
    private(set) var isLoading = false
    private(set) var isPaginating = false
    private(set) var isLastPage = false
    
    var currentPage = 1
    private let maxItemsPerPage = 100
    private let limitStep = 20
    private var currentLimit = 20
    
    var currentSearchKeyword: String = ""
    var isSearching = false
    
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
        if page == 1 {
            photoList = []
            filteredPhotoList = []
        }
        onDataUpdated?()
                
        photoListService.getPhotoList(page: page, limit: currentLimit) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let photos):
                    if page == 1 {
                        self.photoList = photos
                    } else {
                        self.photoList += photos
                    }
                    self.filteredPhotoList = self.filterPhotos(with: self.currentSearchKeyword)
                    self.isLastPage = self.filteredPhotoList.count >= self.maxItemsPerPage
                    
                case .failure(let error):
                    print("Error fetching page \(page): \(error)")
                    if page == 1 {
                        self.photoList = []
                        self.filteredPhotoList = []
                    }
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
                    self.filteredPhotoList = self.filterPhotos(with: self.currentSearchKeyword)
                    self.currentLimit = newLimit
                    self.isLastPage = self.filteredPhotoList.count >= self.maxItemsPerPage
                    
                case .failure(let error):
                    print("Pagination error: \(error)")
                }
                
                self.onDataUpdated?()
            }
        }
    }
    
    func refreshCurrentPage() {
        guard !isLoading else { return }
        
        isLoading = true
        isLastPage = false
        photoList = []
        filteredPhotoList = []
        onDataUpdated?()
        
        photoListService.getPhotoList(page: currentPage, limit: currentLimit) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let photos):
                    self.photoList = photos
                    self.filteredPhotoList = self.filterPhotos(with: self.currentSearchKeyword)
                    self.isLastPage = self.filteredPhotoList.count >= self.maxItemsPerPage
                    
                case .failure(let error):
                    print("Error refreshing page \(self.currentPage): \(error)")
                    self.photoList = []
                    self.filteredPhotoList = []
                }
                
                self.onDataUpdated?()
            }
        }
    }
    
    func filterPhotos(with keyword: String) -> [PhotoItem] {
        guard !keyword.isEmpty else {
            isSearching = false
            currentLimit = limitStep
            isLastPage = false
            return Array(photoList.prefix(currentLimit))
        }
        
        isSearching = true
        let lowercased = keyword.lowercased()
        
        let filtered: [PhotoItem]
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: lowercased)) {
            filtered = photoList.filter { $0.id == lowercased }
        } else {
            filtered = photoList.filter { $0.author.lowercased().contains(lowercased) }
        }
        
        if filtered.count <= 100 {
            currentLimit = filtered.count
            isLastPage = true
            return filtered
        } else {
            currentLimit = limitStep
            isLastPage = false
            return Array(filtered.prefix(currentLimit))
        }
    }
    
    func loadMoreFilteredResults() {
        guard isSearching, !isLoading, !isPaginating, !isLastPage else { return }
        
        isPaginating = true
        onDataUpdated?()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let allFiltered = self.filterPhotos(with: self.currentSearchKeyword)
            let newLimit = min(self.currentLimit + self.limitStep, allFiltered.count)
            let newFiltered = Array(allFiltered.prefix(newLimit))
            
            DispatchQueue.main.async {
                self.currentLimit = newLimit
                self.filteredPhotoList = newFiltered
                self.isPaginating = false
                self.isLastPage = self.filteredPhotoList.count >= allFiltered.count
                self.onDataUpdated?()
            }
        }
    }
}

