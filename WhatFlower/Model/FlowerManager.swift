//
//  FlowerManager.swift
//  WhatFlower
//
//  Created by Дмитрий Пономаренко on 18.07.22.
//

import Foundation
 
protocol FlowerManagerDelegate {
    func didUpdateFlower(extract: String)
    func didFailWithError(error: Error)
}
 
class FlowerManager {
    var delegate: FlowerManagerDelegate?
    var flowerImageURL = ""
    
    func fetchFlower(flowerName: String) {
        
        let wikipediaURl = "https://en.wikipedia.org/w/api.php"
        guard let nameFlower = "\(flowerName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            fatalError("Could update url")
        }
        let urlString = ("\(wikipediaURl)?format=json&action=query&prop=extracts%7Cpageimages&exintro&explaintext&redirects=1&titles=\(nameFlower)")
        print(urlString)
       
        performRequest(urlString: urlString)
    }
   
    func performRequest(urlString: String) {
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("error")
                    return
                }
                            
                if let safeData = data {
                    self.parseJSON(flowerData: safeData)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(flowerData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(FlowerData.self, from: flowerData).query.pages
            if let pageKey = decodedData.first?.key {
                let results = decodedData[pageKey]!
                flowerImageURL = decodedData[pageKey]!.thumbnail.source
                self.delegate?.didUpdateFlower(extract: results.extract)

            }
        } catch {
            print(error)
        }
    }
}
