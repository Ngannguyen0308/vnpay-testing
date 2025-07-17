//
//  ImageCache.swift
//  VnpayChallenge
//
//  Created by ADMIN on 17/7/25.
//

import Foundation
import UIKit

final class ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    func photo(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    func insertPhoto(_ photo: UIImage, for url: URL) {
        cache.setObject(photo, forKey: url as NSURL)
    }
}
