
import Foundation

class MovieManager {

  let defaultSession = URLSession(configuration: .default)
  

  var dataTask: URLSessionDataTask?
  var errorMessage = ""
  var moviesResult: [Movie] = []
  
  typealias JSONDictionary = [String: Any]
  typealias QueryResult = ([Movie]?, String) -> Void
  
    func getSearchResults(searchTerm: String, completion: @escaping QueryResult, page: Int = 1) {

    dataTask?.cancel()
    //https://api.themoviedb.org/3/search/movie?api_key=2696829a81b1b5827d515ff121700838&query=batman&page=1
    if var urlComponents = URLComponents(string: "https://api.themoviedb.org/3/search/movie") {
      urlComponents.query = "api_key=2696829a81b1b5827d515ff121700838&query=\(searchTerm)&page=\(page)"
      
      guard let url = urlComponents.url else {
        return
      }
      dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
        defer {
          self?.dataTask = nil
        }
        
        if let error = error {
          self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
        } else if
          let data = data,
          let response = response as? HTTPURLResponse,
          response.statusCode == 200 {
            //Getting nil while unwrapping data, why?
            let dataString = data.toString()!
            print(dataString)
            print("Attempting to update results")
            self?.updateSearchResults(data)
          
          DispatchQueue.main.async {
            completion(self?.moviesResult, self?.errorMessage ?? "")
          }
        }
      }
      
      dataTask?.resume()
    }
  }
  
  private func updateSearchResults(_ data: Data) {
    print("updating results")
    var response: JSONDictionary?
    moviesResult.removeAll()
    print("removed previous results")
    do {
      response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
    } catch let parseError as NSError {
      errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
      return
    }
    
    guard let array = response!["results"] as? [Any] else {
      errorMessage += "Dictionary does not contain results key\n"
      return
    }
    
    var index = 0
    
    for MovieDictionary in array {
        let movie = Movie()
        if let MovieDictionary = MovieDictionary as? JSONDictionary {
            movie.title = MovieDictionary["title"] as? String
            movie.releaseDate = MovieDictionary["release_date"] as? Date
            movie.poster = MovieDictionary["poster_path"] as? String
            movie.movieOverview = MovieDictionary["overview"] as? String
        } else {
          errorMessage += "Problem parsing MovieDictionary\n"
        }
          moviesResult.append(movie)
          index += 1
    }
  }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}
