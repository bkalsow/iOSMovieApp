//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by Brandan Kalsow on 8/24/20.
//  Copyright © 2020 Virgin Pulse. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var MovieTitle: UILabel!
    @IBOutlet weak var ReleaseDate: UILabel!
    @IBOutlet weak var Overview: UILabel!
    @IBOutlet weak var Poster: UIImageView!
    
    var selectedMovie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MovieTitle.text = selectedMovie?.title
        MovieTitle.textAlignment = NSTextAlignment.center
        ReleaseDate.text = selectedMovie?.releaseDate?.toString(dateFormat: "MMMM dd, yyyy")
        ReleaseDate.textAlignment = NSTextAlignment.center
        Overview.text = selectedMovie?.overview
        Overview.numberOfLines = 0
        Overview.textAlignment = NSTextAlignment.center
        Poster?.load(url: URL(string: (selectedMovie?.poster)!)!)
    }
}
