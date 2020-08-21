//
//  MovieManager.swift
//  MovieApp
//
//  Created by Brandan Kalsow on 8/19/20.
//  Copyright © 2020 Virgin Pulse. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class MovieManager: UITableViewController {
    
    let defaultSession = URLSession(configuration: .default)
    
    //Get the Core Data context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var maxPages = 0
    
    //Store the results in an array
    var moviesResult: [Movie] = []
    
    //Base URL that images come from
    private static let BASE_IMAGE_URL = "https://image.tmdb.org/t/p/w92"
    
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([Movie]?, String) -> Void
    
    func getMaxPages() -> Int{
        return maxPages
    }
    
    /**
     * Fetches the search results from the server
     * @param searchTerm the term to search for
     */
    func getSearchResults(searchTerm: String, page: Int = 1, completion: @escaping QueryResult) {
        //Cancel any outstanding data tasks
        dataTask?.cancel()
        
        //construct the URL components
        if var urlComponents = URLComponents(string: "https://api.themoviedb.org/3/search/movie") {
            urlComponents.query = "api_key=2696829a81b1b5827d515ff121700838&query=\(searchTerm)&page=\(page)"
            
            //combine the URL components to construct the url
            guard let url = urlComponents.url else {
                return
            }
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
                
                //If you get an error, return it
                if let error = error {
                    self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if
                    //save the data
                    let data = data,
                    //make sure that the server returned a positive response
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    //call updateSearchResults to parse & save the data
                    self?.updateSearchResults(data)
                    
                    DispatchQueue.main.async {
                        completion(self?.moviesResult, self?.errorMessage ?? "")
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    /**
     * Updates the searchResults to be used elsewhere in the program
     *
     * @Param data the JSON data to parse into objects
     */
    private func updateSearchResults(_ data: Data) {
        
        //create a JSO dictionary to save into
        var response: JSONDictionary?
        //delete the previous results
        moviesResult.removeAll()
        do {
            //attempt to cast the response as JSON
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        maxPages = (response!["total_pages"] as? Int)!
        //convert the response into an array
        guard let array = response!["results"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        var index = 0
        
        //Create a formatter to parse the date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        //for each movie
        for movieDictionary in array {
            //if the current dictionary is JSON
            if let MovieDictionary = movieDictionary as? JSONDictionary {
                //create a new movie & populate it with the data
                let newMovie = Movie(context: context)
                newMovie.title = MovieDictionary["title"] as? String
                
                //Check that the date isn't empty
                let dateString = MovieDictionary["release_date"] as? String
                if  dateString != nil {
                    //Use the date formatter to parse the release date
                    if let date = formatter.date(from: MovieDictionary["release_date"] as! String) {
                        newMovie.releaseDate = date
                    }
                }
                //check that the poster path isn't empty
                let posterURL = MovieDictionary["poster_path"] as? String
                if(posterURL == nil)
                {
                    
                } else {
                    newMovie.poster = MovieManager.BASE_IMAGE_URL + (posterURL)!
                    newMovie.overview = MovieDictionary["overview"] as? String
                }
                //add the new movie to the result
                moviesResult.append(newMovie)
                index += 1
            } else {
                errorMessage += "Problem parsing MovieDictionary\n"
            }
        }
    }
}
