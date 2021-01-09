//
//  PhotosVC.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/8/21.
//

import UIKit
import CardsLayout

class PhotosVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = CardsCollectionViewLayout()
            collectionView.isPagingEnabled = true
            collectionView.showsHorizontalScrollIndicator = false
        // Do any additional setup after loading the view.
    }
    

  

}
extension PhotosVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! UICollectionViewCell
        return cell
    }
    
    
}
