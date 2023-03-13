//
//  WikiData.swift
//  WhatFlower
//
//  Created by Дмитрий Пономаренко on 18.07.22.
//

import Foundation

struct FlowerData: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [String:Results]
}

struct Results: Codable {
    let pageid: Int
    let title: String
    let extract: String
    let thumbnail: Thumbnail
    let pageimage: String
    
   }
    
   struct Thumbnail: Codable {
      let source: String
      let width: Int
      let height: Int
    
   }


