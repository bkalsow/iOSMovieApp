//
//  ViewController.swift
//  MovieApp
//
//  Created by Brandan Kalsow on 8/18/20.
//  Copyright © 2020 Virgin Pulse. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {

    @IBOutlet weak var MovieTableView: UITableView!
    @IBOutlet weak var RecentSearchesTable: UITableView!
    
    var movieArray = [Movie]()
    var last10Searches = [String]()
    
    let movieManager = MovieManager()
    //private static let BASE_IMAGE_URL = "https://image.tmdb.org/t/p/w92"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RecentSearchesTable.isHidden = true
        MovieTableView.isHidden = false
        // Do any additional setup after loading the view.
    }
    
    func toggleView()
    {
        self.RecentSearchesTable.isHidden = !RecentSearchesTable.isHidden
        self.MovieTableView.isHidden = !MovieTableView.isHidden
    }
}

//MARK: Tableview Data Source Methods
extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    
    //Get number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        cell.title.text = movieArray[indexPath.row].title
        print(movieArray[indexPath.row].releaseDate as Any)
        cell.releaseDate.text = movieArray[indexPath.row].releaseDate?.toString(dateFormat: "MM/dd/yyyy")
        cell.overview.text = movieArray[indexPath.row].overview
        let url = self.movieArray[indexPath.row].poster
        cell.poster.load(url: URL(string: url!)!)
        
        return cell
    }
}

//MARK: Search Bar Delegate Methods
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        toggleView()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        toggleView()
        
         MovieTableView.reloadData()
    }
    /**
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
                    MovieTableView.reloadData()
                    
                    DispatchQueue.main.async {
                        searchBar.resignFirstResponder()
                    }
        }
    } */
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        toggleView()
        
        if searchBar.text!.count > 0 {
            if(last10Searches.contains(searchBar.text!))
            {
                let search = searchBar.text!
                last10Searches.remove(at: last10Searches.firstIndex(of: search)!)
                last10Searches.append(searchBar.text!)
            }
            if last10Searches.count < 10 {
                last10Searches.append(searchBar.text!)
            } else {
                last10Searches.removeFirst()
                last10Searches.append(searchBar.text!)
            }
            print(last10Searches)
            
            movieManager.getSearchResults(searchTerm: searchBar.text!) { [weak self] results, errorMessage in
                     UIApplication.shared.isNetworkActivityIndicatorVisible = false
               
                     if let results = results {
                       self?.movieArray = results
                       self?.MovieTableView.reloadData()
                       self?.MovieTableView.setContentOffset(CGPoint.zero, animated: false)
                     }
                     
                     if !errorMessage.isEmpty {
                       print("Search error: " + errorMessage)
                     }
                   }
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            movieArray = movieManager.moviesResult
        } else {
            let alert = UIAlertController(title: "Please enter a search term", message: "", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: Image View Methods
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

//MARK: Date-to-String converter
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
