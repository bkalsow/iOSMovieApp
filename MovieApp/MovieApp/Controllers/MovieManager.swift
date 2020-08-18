
import Foundation

class MovieManager {

  let defaultSession = URLSession(configuration: .default)
  

  var dataTask: URLSessionDataTask?
  var errorMessage = ""
  var movies: [Movie] = []
  
  typealias JSONDictionary = [String: Any]
  typealias QueryResult = ([Movie]?, String) -> Void
  
  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {

    dataTask?.cancel()
    
    if var urlComponents = URLComponents(string: "https://itunes.apple.com/search") {
      urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
      
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
          
          self?.updateSearchResults(data)
          
          DispatchQueue.main.async {
            completion(self?.movies, self?.errorMessage ?? "")
          }
        }
      }
      
      dataTask?.resume()
    }
  }
  
  private func updateSearchResults(_ data: Data) {
    var response: JSONDictionary?
    movies.removeAll()
    
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
          movies.append(movie)
          index += 1
    }
  }
}