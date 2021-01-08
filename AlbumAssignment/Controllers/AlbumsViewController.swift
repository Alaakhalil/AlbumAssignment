//
//  ViewController.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/7/21.
//

import UIKit
import CardSlider
import Kingfisher

class AlbumsViewController: UIViewController {

    var albumsData = [AlbumsModel]()
    var photosData = [PhotosModel]()
    var data = [CardItem]()
    @IBOutlet weak var albumCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getAlbums()
        getAllPhotos()
    }
    
// Getting Albums`s Data From Api
    func getAlbums(){
        ApiManager.shared.getAlbums { (response, error) in
            if error == nil{
                self.albumsData = response
                self.albumCollectionView.reloadData()

            }
            else{
                print(error)
            }
        }
    }
    // Getting  All Photos
    func getAllPhotos(){
        ApiManager.shared.getAllPhotos { (response, error) in
            if error == nil{
                self.photosData = response
            }
            else{
                print(error)
            }
        }
    }

}

// MARK: - Collection View

extension AlbumsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumCollectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        let index = indexPath.row
        cell.updateCell(albumTitle: albumsData[index].title ?? " ", albumImageUrl: " ")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        
        ApiManager.shared.getPhotosOfAlbum(albumId: albumsData[index].id!) { [self] (response, erorr) in
            if erorr == nil{
                self.photosData = response
                for item in self.photosData {
                    let photo = UIImageView()
                    photo.kf.indicatorType = .activity
                    let encodeUrl = (item.url)!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                        let url = URL(string: encodeUrl!)
                        print("image url\(url!)")
                        photo.kf.setImage(with: url)
                    self.data.append(CardItem(image: UIImage(systemName: "bookmark")!,rating: nil, title: item.title!, subtitle: nil, description: nil))
                }
                let cardSlider = CardSliderViewController.with(dataSource: self)
                cardSlider.title = "Album \(String(describing: albumsData[index].id!))"
                present(cardSlider, animated: true, completion: nil)
            }
        }

        

      }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
      
        return CGSize(width: (width/2 - 6), height: height/4 - 6)
       
        }
    
    
}
// MARK: - Card Slider

extension AlbumsViewController: CardSliderDataSource{
    func item(for index: Int) -> CardSliderItem {
    
        return data[index]
       
    }
    
    func numberOfItems() -> Int {
        return photosData.count
    }
}

struct CardItem: CardSliderItem{
    var image: UIImage
    var rating: Int?
    var title: String
    var subtitle: String?
    var description: String?
}
