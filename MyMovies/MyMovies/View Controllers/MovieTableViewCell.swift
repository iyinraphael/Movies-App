//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Iyin Raphael on 1/25/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func addMovie(_ sender: UIButton) {
    
        guard let title = titleLabel.text else {return}
        let movie = Movie(title: title)
        movieController.saveToPersistence()
        movieController.put(movie: movie)
    }
    
    let movieController = MovieController()
}
