//
//  SearchViewController.swift
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
    
    //save the searched movies & recent searches
    var movieArray = [Movie]()
    var last10Searches = [String]()
    
    //make a new movieManager to query the site
    let movieManager = MovieManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RecentSearchesTable.isHidden = true
        MovieTableView.isHidden = false
        // Do any additional setup after loading the view.
    }
    
    /**
     * Toggles between the recent searches table and the movie table
     */
    func toggleView()
    {
        self.RecentSearchesTable.isHidden = !RecentSearchesTable.isHidden
        self.MovieTableView.isHidden = !MovieTableView.isHidden
    }
}

//MARK: Tableview Data Source Methods -
extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    
    //Get number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    //Constructs each cell in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        cell.title.text = movieArray[indexPath.row].title
        cell.releaseDate.text = movieArray[indexPath.row].releaseDate?.toString(dateFormat: "MMMM dd, yyyy")
        cell.overview.text = movieArray[indexPath.row].overview
        let url = self.movieArray[indexPath.row].poster
        cell.poster.load(url: URL(string: url!)!)
        
        return cell
    }
}



//MARK: Search Bar Delegate Methods
extension SearchViewController: UISearchBarDelegate {
    
    //When the user starts editing what's in the search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        toggleView()
    }
    
    //when the user clicks the cancel button
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
    
    //When the user clicks the "Search" button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //toggle back to the movie table
        toggleView()
        
        //verify that the search text isn't empty
        if searchBar.text!.count > 0 {
            
            let search = searchBar.text!
            
            //if the user searched this before, move it to the front
            if(last10Searches.contains(search))
            {
                last10Searches.remove(at: last10Searches.firstIndex(of: search)!)
                last10Searches.append(search)
            } //else, if they haven't searched 10 times
            else if last10Searches.count < 10 {
                last10Searches.append(search)
            } else { //otherwise, they've searched 10+ times and we need to cycle the first search out
                last10Searches.removeFirst()
                last10Searches.append(search)
            }
            
            //get the search results for the query
            movieManager.getSearchResults(searchTerm: search) { [weak self] results, errorMessage in
                     UIApplication.shared.isNetworkActivityIndicatorVisible = false
               
                     if let results = results {
                       self?.movieArray = results
                       self?.MovieTableView.reloadData()
                       self?.MovieTableView.setContentOffset(CGPoint.zero, animated: false)
                     }
                     //if there's an error message, print it to the console
                     if !errorMessage.isEmpty {
                       print("Search error: " + errorMessage)
                     }
                   }
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            //if search is empty, alert the user
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
