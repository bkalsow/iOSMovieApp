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
    
    //setup defaults to persist data
    let defaults = UserDefaults.standard
    
    //save the searched movies & recent searches
    var movieArray = [Movie]()
    var last10Searches = [String]()
    
    //make a new movieManager to query the site
    let movieManager = MovieManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RecentSearchesTable.isHidden = true
        MovieTableView.isHidden = false
        // If UserDefaults has any saved searches, load them
        if let previousSearches = defaults.array(forKey: "PreviousSearches") as? [String] {
            last10Searches = previousSearches
        }
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
        if tableView == self.RecentSearchesTable {
            return last10Searches.count
        } else {
            return movieArray.count
        }
        
    }
    
    //Constructs each cell in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == self.MovieTableView) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
            
            cell.title.text = movieArray[indexPath.row].title
            cell.releaseDate.text = movieArray[indexPath.row].releaseDate?.toString(dateFormat: "MMMM dd, yyyy")
            cell.overview.text = movieArray[indexPath.row].overview
            
            let url = self.movieArray[indexPath.row].poster
            cell.poster.load(url: URL(string: url!)!)
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchesCell", for: indexPath) as! RecentSearchesTableCell

            cell.searchTerm.text = last10Searches[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if(tableView == self.RecentSearchesTable)
        {
            //if the search bar is the current first responder resign
            let  firstResponder = view.window?.firstResponder
            if  firstResponder is UISearchBar {
                firstResponder?.resignFirstResponder()
            }
            
            let search = last10Searches[indexPath.row]
            
            //Move selected search to the front of the array
            last10Searches.remove(at: indexPath.row)
            last10Searches.insert(search, at: 0)
            
            //update UserDefaults
            defaults.set(last10Searches, forKey: "PreviousSearches")
            
            //toggle back to the movie view
            self.toggleView()
            
            //search with the selected query
            movieManager.getSearchResults(searchTerm: search) { [weak self] results, errorMessage in
                     UIApplication.shared.isNetworkActivityIndicatorVisible = false
               
                     if let results = results {
                       self?.movieArray = results
                       self?.MovieTableView.reloadData()
                       self?.MovieTableView.setContentOffset(CGPoint.zero, animated: false)
                     }
                     //if there's an error message, print it to the console
                     if !errorMessage.isEmpty {
                        
                        //remove the last search because it wasn't successful
                        self!.last10Searches.removeLast()
                        //alert the user
                        
                        let alert = UIAlertController(title: "Error", message: "Search error: " + errorMessage, preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .default) { (action) in
                            //What happens once user clicks add item
                        }
                        
                        alert.addAction(action)
                        
                        self!.present(alert, animated: true, completion: nil)
                       print("Search error: " + errorMessage)
                     }
                //self!.toggleView()
                   }
        } else {
            print("Selected a cell in MovieTable")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



//MARK: Search Bar Delegate Methods
extension SearchViewController: UISearchBarDelegate {
    
    //When the user starts editing what's in the search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        toggleView()
        RecentSearchesTable.reloadData()
    }
    
    //when the user clicks the cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        toggleView()
        
         MovieTableView.reloadData()
    }
    
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
                last10Searches.insert(search, at: 0)
                
                //update user defaults
                defaults.set(last10Searches, forKey: "PreviousSearches")
            } //else, if they haven't searched 10 times
            else if last10Searches.count < 10 {
                last10Searches.insert(search, at: 0)
                
                //update user defaults
                defaults.set(last10Searches, forKey: "PreviousSearches")
            } else { //otherwise, they've searched 10+ times and we need to cycle the earliest search out
                last10Searches.removeLast()
                last10Searches.insert(search, at: 0)
                
                //update user defaults
                defaults.set(last10Searches, forKey: "PreviousSearches")
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
                        
                        //remove the last search because it wasn't successful
                        self!.last10Searches.removeLast()
                        
                        //alert the user that an error has occured
                        let alert = UIAlertController(title: "Error", message: "Search error: " + errorMessage, preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .default) { (action) in
                            //What happens once user clicks add item
                        }
                        
                        alert.addAction(action)
                        
                        self!.present(alert, animated: true, completion: nil)
                       print("Search error: " + errorMessage)
                     }
                   }
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            //if search is empty, alert the user
        } else {
            let alert = UIAlertController(title: "Please enter a search term", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                //What happens once user clicks add item
            }
            
            alert.addAction(action)
            
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

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
}
