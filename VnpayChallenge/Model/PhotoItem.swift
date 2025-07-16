//
//  PhotoItem.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//


struct PhotoItem: Decodable {
    let id: Int
    let author: String
    let width: Int
    let height: Int
    let url: String
    let dowloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case url
        case dowloadURL = "download_url"
    }
}
