//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by Brandan Kalsow on 8/24/20.
//  Copyright © 2020 Virgin Pulse. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var ReleaseDate: UILabel!
    @IBOutlet weak var Overview: UILabel!
    @IBOutlet weak var Poster: UIImageView!
    
    var selectedMovie: Movie? {
        didSet {
            print(selectedMovie?.title as Any)
            loadData()
        }
    }
    
    func loadData() {
        /**Name?.text = selectedMovie?.title
        ReleaseDate?.text = selectedMovie?.releaseDate?.toString(dateFormat: "MMMM dd, yyyy")
        Overview?.text = selectedMovie?.overview
        if(selectedMovie?.poster != nil)
        {
            let url = self.selectedMovie?.poster
            Poster?.load(url: URL(string: url!)!)
        } else {
            Poster?.image = UIImage(named: "ImageNotFound")
        } */
        guard let title = selectedMovie?.title else {
            return
        }
        guard let release = selectedMovie?.releaseDate else {
            return
        }
        guard let overview = selectedMovie?.overview else {
            return
        }
        guard let posterURL = selectedMovie?.poster else {
                return
        }
        Name.text = title
        ReleaseDate.text = release.toString(dateFormat: "MMMM dd, yyyy")
        Overview.text = overview
        Poster?.load(url: URL(string: posterURL)!)
    }
}
