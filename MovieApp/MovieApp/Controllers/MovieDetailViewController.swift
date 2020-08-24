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
    
    var selectedMovie: Movie? {
        didSet {
            MovieTitle.text = selectedMovie?.title
            ReleaseDate.text = selectedMovie?.releaseDate?.toString(dateFormat: "MMMM dd, yyyy")
            Overview.text = selectedMovie?.overview
            Poster?.load(url: URL(string: (selectedMovie?.poster)!)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
