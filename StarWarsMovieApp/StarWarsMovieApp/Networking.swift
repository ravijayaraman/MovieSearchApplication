//
//  Networking.swift
//  StarWarsMovieApp
//
//  Created by Tonatiuh C on 20/7/19.
//  Copyright © 2019 Ravi Jayaraman. All rights reserved.
//

import UIKit

struct apiQuery {
    var type = "movie"
    var keyword = ""
    let apikey = "apikey=" + apiKey
    var query = ""
}

//Enum for API call methods
enum method: String {
    case GET
    case POST
}

//API Key
private let baseURL = "http://www.omdbapi.com/"
private let apiKey = "b6d08b5c"

protocol NetworkingDelegate {
    func apiCallError(_ error: Error)
    func apiCallSuccess(_ data: [movieModel])
}

class Networking {
    
    static let shared = Networking()
    var delegate: NetworkingDelegate?
    
    func get(_ vc: ViewController, query: String) {
        delegate = vc
        let strQuery = self.parseQueryForAPI(query: query)
        apiCall(method: .GET, query: strQuery) { (data) in
            self.parseSearchResultList(data: data)
        }
    }
    
    func post(_ vc: ViewController, query: String) {
        apiCall(method: .POST, query: "") { (data) in
            //Parse the data
        }
    }
    
    private func apiCall(method: method, query: String, completion: @escaping (_ data: Data) -> Void) {
        let url = URL(string: baseURL+query)!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            if let error = error {
                self.delegate?.apiCallError(error)
                return
            }
            
            guard let data = data else {
                return
            }
            completion(data)
        }
        
        task.resume()
    }
}

extension Networking {
    
    private func parseSearchResultList(data: Data) {
        
        do {
            // make sure this JSON is in the format we expect
            if let objJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                let bool = ((objJSON["Response"] as? String) ?? "").lowercased().contains("true") ? true : false
                
                if bool {
                    // try to read out a string array
                    if let objValue = objJSON["Search"] as? [Any] {
                        var arrMovieModel = [movieModel]()
                        var objMovieModel = movieModel()
                        
                        for obj in objValue {
                            if let dictObj = obj as? [String: String] {
                                objMovieModel.name = dictObj["Title"] ?? ""
                                objMovieModel.description = dictObj["Year"] ?? ""
                                arrMovieModel.append(objMovieModel)
                            }
                        }
                        self.delegate?.apiCallSuccess(arrMovieModel)
                    }
                }
                else {
                    // try to read out a string array
                    if let objValue = objJSON["Error"] as? String {
                        var objMovieModel = movieModel()
                        objMovieModel.name = "Error"
                        objMovieModel.description = objValue
                        self.delegate?.apiCallSuccess([objMovieModel])
                    }
                }
            }
        } catch let error as NSError {
            self.delegate?.apiCallError(error)
        }
    }
    
    private func parseQueryForAPI(query: String) -> String {
        var strQuery = apiQuery()
        strQuery.query = query.lowercased()
        
        if query.lowercased().contains("movie") || query.lowercased().contains("movies") {
            strQuery.type = "movie"
            if query.lowercased().contains("movie") {
                strQuery.query = strQuery.query.replacingOccurrences(of: "movies", with: "")
            }
            else {
                strQuery.query = strQuery.query.replacingOccurrences(of: "movies", with: "")
            }
        }
        else if query.lowercased().contains("series") || query.lowercased().contains("list") {
            strQuery.type = "series"
            if query.lowercased().contains("series") {
                strQuery.query = strQuery.query.replacingOccurrences(of: "series", with: "")
            }
            else {
                strQuery.query = strQuery.query.replacingOccurrences(of: "list", with: "")
            }
        }
        else if query.lowercased().contains("episode") || query.lowercased().contains("episodes") {
            strQuery.type = "episode"
            strQuery.query = strQuery.query.replacingOccurrences(of: "episode", with: "")
        }
        
        strQuery.keyword = strQuery.query.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+")
        
        return "?s=\(strQuery.keyword)&type=\(strQuery.type)&\(strQuery.apikey)"
    }
}
