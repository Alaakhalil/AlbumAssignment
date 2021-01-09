//
//  AlbumCell.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/8/21.
//

import UIKit
import Kingfisher

class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBOutlet weak var albumTiltleLabel: UILabel!
    
    func updateCell(albumTitle: String,albumImageUrl: String){
        self.albumTiltleLabel.text = albumTitle
        self.albumImageView.kf.indicatorType = .activity
        let encodeUrl = (albumImageUrl).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodeUrl!)
        self.layoutIfNeeded()
        self.albumImageView.kf.setImage(with: url)
        
        
    }

    
}
