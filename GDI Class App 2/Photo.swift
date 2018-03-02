//
//  Photo.swift
//  GDI Class App 2
//
//  Created by Lily Barrett1 on 2/27/18.
//  Copyright © 2018 Lily Barrett1. All rights reserved.
//

import Foundation

class Photo: Decodable {
    let id: String
    let farm: Int //specific to Flickr api
    let server: String
    let secret: String
    let title: String?
    
    func imageUrl() -> URL? {
        let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        return URL(string: urlString)
    }
}
