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
    
    var movieArray = [Movie]()
    var last10Searches = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        cell.releaseDate.text = movieArray[indexPath.row].releaseDate?.toString(dateFormat: "MMM/dd/yyy")
        let url = self.movieArray[indexPath.row].poster
        cell.poster.load(url: URL(string: url!)!)
        
        return cell
    }
}

//MARK: Search Bar Delegate Methods
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        
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
        
        if searchBar.text!.count > 0 {
            if last10Searches.count < 10 {
                last10Searches.append(searchBar.text!)
            } else {
                last10Searches.removeFirst()
                last10Searches.append(searchBar.text!)
            }
            print(last10Searches)
            let movieManager = MovieManager()
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
