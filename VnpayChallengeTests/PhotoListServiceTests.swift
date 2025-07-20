//
//  PhotoListServiceTests.swift
//  VnpayChallenge
//
//  Created by ADMIN on 20/7/25.
//

import XCTest
@testable import VnpayChallenge

final class PhotoListServiceTests: XCTestCase {
    
    // MARK: - Mock Classes
    
    class MockPhotoListService: PhotoListService {
        var resultToReturn: Result<[PhotoItem], NetworkError> = .success([])
        
        init() {
            super.init(httpClient: MockHTTPClient())
        }
        
        override func getPhotoList(page: Int = 1, limit: Int = 20, completion: @escaping (Result<[PhotoItem], NetworkError>) -> Void) {
            completion(resultToReturn)
        }
    }
    
    class MockImageService: ImageService {
        init() {
            super.init(httpClient: MockHTTPClient())
        }
    }
    
    // MARK: - Properties
    
    var viewModel: HomeViewModel!
    var mockPhotoListService: MockPhotoListService!
    var mockImageService: MockImageService!
    
    override func setUp() {
        super.setUp()
        mockPhotoListService = MockPhotoListService()
        mockImageService = MockImageService()
        viewModel = HomeViewModel(photoListService: mockPhotoListService, imageService: mockImageService)
    }
    
    // MARK: - Tests
    
    func testFetchItemForPageSuccess() {
        let photo = PhotoItem(id: "1", author: "John Doe", width: 1000, height: 800, urlImage: "https://example.com", downloadURL: "https://example.com/image.jpg")
        mockPhotoListService.resultToReturn = .success([photo])
        
        let expectation = self.expectation(description: "Data updated")
        viewModel.onDataUpdated = {
            expectation.fulfill()
        }
        
        viewModel.fetchItemForPage(1)
        
        waitForExpectations(timeout: 2)
        XCTAssertEqual(viewModel.allPhotos.first?.author, "John Doe")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFetchItemForPageFailure() {
        mockPhotoListService.resultToReturn = .failure(.requestFailed(MockError.someError))
        
        let expectation = self.expectation(description: "Error handled")
        viewModel.onDataUpdated = {
            expectation.fulfill()
        }
        
        viewModel.fetchItemForPage(1)
        waitForExpectations(timeout: 2)
        XCTAssertTrue(viewModel.allPhotos.isEmpty)
    }
    
    func testNormalizeSearchKeyword() {
        let input = "  Jöhn Døe 123!!!"
        let normalized = viewModel.normalizeSearchKeyword(input)
        XCTAssertEqual(normalized, "JohnDoe123")
    }
    
    func testValidateSearchInputTrimsAndLimits() {
        let input = "    LongInputExceeding15Chars    "
        let validated = viewModel.validateSearchInput(input)
        XCTAssertEqual(validated.count, 15)
    }
    
    func testFilterPhotosByAuthorPrefix() {
        let items = [
            PhotoItem(id: "1", author: "John Smith", width: 100, height: 100, urlImage: "", downloadURL: ""),
            PhotoItem(id: "2", author: "Jane Doe", width: 100, height: 100, urlImage: "", downloadURL: "")
        ]
        viewModel.allPhotos = items
        
        let result = viewModel.filterPhotos(with: "jo")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.author, "John Smith")
    }
    
    func testFilterPhotosByID() {
        let items = [
            PhotoItem(id: "123", author: "User A", width: 100, height: 100, urlImage: "", downloadURL: "")
        ]
        viewModel.allPhotos = items
        
        let result = viewModel.filterPhotos(with: "123")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "123")
    }
    
    func testLoadNextItemIncreasesLimit() {
        let photos = (1...50).map { index in
            PhotoItem(id: "\(index)", author: "Author \(index)", width: 100, height: 100, urlImage: "", downloadURL: "")
        }
        viewModel.allPhotos = photos
        viewModel.filteredPhotoList = Array(photos.prefix(10))
        
        viewModel.loadNextItem()
        
        // Gián tiếp kiểm tra
        XCTAssertTrue(viewModel.filteredPhotoList.count > 10)
    }
}

// MARK: - Mocks

enum MockError: Error {
    case someError
}

class MockHTTPClient: HTTPClient {
    func get(to url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        completion(.failure(.noData))
    }
}
