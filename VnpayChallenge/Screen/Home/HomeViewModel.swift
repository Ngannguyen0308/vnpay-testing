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
    
    var allPhotos: [PhotoItem] = []
    var filteredPhotoList: [PhotoItem] = []
    var onDataUpdated: (() -> Void)?
    
    private(set) var isLoading = false
    private(set) var isPaginating = false
    private(set) var isLastPage = false
    
    var currentPage = 1
    private let maxItemsPerPage = 100
    private let limitStep = 25
    var currentLimit = 25
    
    var currentSearchKeyword: String = ""
    var isSearching = false
    
    init(photoListService: PhotoListService, imageService: ImageService) {
        self.photoListService = photoListService
        self.imageService = imageService
    }
    
    func fetchItemForPage(_ page: Int) {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = page
        onDataUpdated?()
        
        photoListService.getPhotoList(page: page, limit: maxItemsPerPage) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let photos):
                    let startIndex = (page - 1) * self.maxItemsPerPage
                    let endIndex = startIndex + photos.count
                    
                    if self.allPhotos.count >= endIndex {
                        self.allPhotos.replaceSubrange(startIndex..<endIndex, with: photos)
                    } else {
                        if self.allPhotos.count < startIndex {
                            self.allPhotos += Array(repeating: .empty, count: startIndex - self.allPhotos.count)
                        }
                        self.allPhotos += photos
                    }
                    
                    self.currentLimit = self.limitStep
                    self.updateFilteredPhotos()
                    self.isLastPage = photos.count < self.maxItemsPerPage
                    
                case .failure(let error):
                    print("Error fetching page \(page): \(error)")
                }
                
                self.onDataUpdated?()
            }
        }
    }
    
    func loadNextItem() {
        guard !isLoading, !isPaginating, !isLastPage, !isSearching else { return }
        
        let startIndex = (currentPage - 1) * maxItemsPerPage
        let endIndex = min(allPhotos.count, currentPage * maxItemsPerPage)
        guard startIndex < endIndex else { return }
        
        let currentItems = Array(allPhotos[startIndex..<endIndex])
        let newLimit = min(currentLimit + limitStep, currentItems.count)
        
        guard newLimit > currentLimit else {
            isLastPage = true
            return
        }
        
        isPaginating = true
        onDataUpdated?()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            DispatchQueue.main.async {
                self.currentLimit = newLimit
                self.filteredPhotoList = Array(currentItems.prefix(self.currentLimit))
                self.isPaginating = false
                self.isLastPage = self.filteredPhotoList.count >= currentItems.count
                self.onDataUpdated?()
            }
        }
    }
    
    func refreshCurrentPage() {
        guard !isLoading else { return }
        
        isLoading = true
        isLastPage = false
        onDataUpdated?()
        
        photoListService.getPhotoList(page: currentPage, limit: maxItemsPerPage) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let photos):
                    let rangeStart = (self.currentPage - 1) * self.maxItemsPerPage
                    if self.allPhotos.count >= rangeStart + self.maxItemsPerPage {
                        self.allPhotos.replaceSubrange(rangeStart..<rangeStart + self.maxItemsPerPage, with: photos)
                    } else {
                        if self.allPhotos.count < rangeStart {
                            self.allPhotos += Array(repeating: .empty, count: rangeStart - self.allPhotos.count)
                        }
                        self.allPhotos += photos
                    }
                    self.updateFilteredPhotos()
                case .failure(let error):
                    print("Error refreshing page \(self.currentPage): \(error)")
                }
                self.onDataUpdated?()
            }
        }
    }
    
    func filterPhotos(with rawKeyword: String) -> [PhotoItem] {
        let keyword = normalizeSearchKeyword(rawKeyword)
        currentSearchKeyword = keyword
        
        guard !keyword.isEmpty else {
            isSearching = false
            updateFilteredPhotos()
            return filteredPhotoList
        }
        
        isSearching = true
        
        let filtered: [PhotoItem]
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: keyword)) {
            filtered = allPhotos.filter { $0.id == keyword }
        } else {
            filtered = allPhotos.filter { photo in
                let normalizedAuthor = photo.author
                    .folding(options: .diacriticInsensitive, locale: .current)
                    .lowercased()
                
                // Match prefix of each word
                let words = normalizedAuthor.split(separator: " ")
                return words.contains { $0.hasPrefix(keyword.lowercased()) }
            }
        }
        
        filteredPhotoList = filtered
        return filtered
    }
    
    func fetchAllPages(totalPages: Int = 10, completion: @escaping () -> Void) {
        guard !isLoading else { return }
        
        isLoading = true
        onDataUpdated?()
        
        var all: [PhotoItem] = []
        let group = DispatchGroup()
        
        for page in 1...totalPages {
            group.enter()
            photoListService.getPhotoList(page: page, limit: maxItemsPerPage) { result in
                switch result {
                case .success(let photos):
                    all.append(contentsOf: photos)
                case .failure(let error):
                    print("Error fetching page \(page): \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.allPhotos = all
            self.filteredPhotoList = self.filterPhotos(with: self.currentSearchKeyword)
            self.isLoading = false
            self.hideFetchAllButton?()
            self.onDataUpdated?()
            completion()
        }
    }
    
    private func updateFilteredPhotos() {
        let startIndex = (currentPage - 1) * maxItemsPerPage
        let endIndex = min(allPhotos.count, currentPage * maxItemsPerPage)
        guard startIndex < endIndex else {
            filteredPhotoList = []
            return
        }
        let pageItems = Array(allPhotos[startIndex..<endIndex])
        filteredPhotoList = Array(pageItems.prefix(currentLimit))
    }
    
    func normalizeSearchKeyword(_ rawInput: String) -> String {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let noDiacritics = trimmed.folding(options: .diacriticInsensitive, locale: .current)
        let allowedCharacters = CharacterSet.alphanumerics
        let filteredScalars = noDiacritics.unicodeScalars.filter { allowedCharacters.contains($0) }
        let result = String(String.UnicodeScalarView(filteredScalars))
        return String(result.prefix(15))
    }
    
    func validateSearchInput(_ rawInput: String) -> String {
        return normalizeSearchKeyword(rawInput)
    }
    
    var hideFetchAllButton: (() -> Void)?
}
