//
//  Movie.swift
//  MovieApp
//
//  Created by Brandan Kalsow on 8/18/20.
//  Copyright © 2020 Virgin Pulse. All rights reserved.
//

import Foundation

struct Movie {
    
    var title: String
    var releaseDate: Date
    var image: String
    
    //Initialize struct with appropriate data
    init(title: String, releaseDate: Date) {
        self.title = title
        self.releaseDate = releaseDate
        //TODO: Image doesn't work!
        self.image = "image.tmbd.org/t/p/w92/8RW2runSEc34IwKN2D1aPcJd2UL.jpg"
    }
}
