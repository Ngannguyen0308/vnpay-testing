//
//  PhotoItem.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//


struct PhotoItem: Decodable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let urlImage: String
    let downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case urlImage = "url"
        case downloadURL = "download_url"
    }
}
