//
//  ViewController.swift
//  MovieApp
//
//  Created by Brandan Kalsow on 8/18/20.
//  Copyright © 2020 Virgin Pulse. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    var movieArray = [Movie]()
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as! movieTableCell
        cell.name.text = DisplayedPokemonArray[indexPath.row].name
        cell.id.text = "#" + String(format: "%03d", DisplayedPokemonArray[indexPath.row].id)
        let url = self.DisplayedPokemonArray[indexPath.row].image
        cell.pokemonImage.load(url: URL(string: url)!)
        
        return cell
    }
}

//MARK: Search Bar Delegate Methods
extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        /**
         self.DisplayedPokemonArray = pokemonArray.filter { (pokemon) -> Bool in
             pokemon.name.lowercased().contains(searchBar.text!.lowercased())
         }
         pokemonTableView.reloadData()
         pokemonCollectionView.reloadData()
         */
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            /**
                    self.DisplayedPokemonArray = self.pokemonArray
                    pokemonTableView.reloadData()
                    pokemonCollectionView.reloadData()
                    
                    DispatchQueue.main.async {
                        searchBar.resignFirstResponder()
                    }
             */
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
