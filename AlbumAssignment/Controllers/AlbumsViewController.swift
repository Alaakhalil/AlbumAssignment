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
    var albumImageDict = [Int:String]()
    var data = [CardItem]()
    @IBOutlet weak var albumCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAlbums()
    }
    
    // Getting Albums`s Data From Api
    
    func getAlbums(){
        DispatchQueue.main.async {
            ApiManager.shared.getAlbums {(response, error) in
                if error == nil{
                    self.albumsData = response
                }
                self.saveAlbumPhoto()
            }
        }
    }
    // save an image for album
    func saveAlbumPhoto(){
        DispatchQueue.main.async {
            ApiManager.shared.getAllPhotos {(response, erorr) in
                if erorr == nil{
                    self.photosData = response
                    for item in self.photosData{
                        if !self.albumImageDict.keys.contains(item.albumId!){
                            self.albumImageDict[item.albumId!] = item.thumbnailUrl
                        }
                    }
                }
                else
                {
                    print(erorr ?? " ")
                }
                self.albumCollectionView.reloadData()
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
        let imageUrl = self.albumImageDict[albumsData[index].id!]
        cell.updateCell(albumTitle: albumsData[index].title ?? " ", albumImageUrl: imageUrl ?? " " )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        ApiManager.shared.getPhotosOfAlbum(albumId: albumsData[index].id!) { [self] (response, erorr) in
            if erorr == nil{
                self.photosData = response
                for item in self.photosData {
                    let photo = self.getImage(from: item.url!)
                    self.data.append(CardItem(image: photo,rating: nil, title: item.title!, subtitle: nil, description: nil))
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
    func getImage(from url: String) -> UIImage {
        guard let url = URL(string: url) else { return UIImage() }
        do{
            let imageData: Data = try Data(contentsOf: url)
            guard let image = UIImage(data: imageData) else { return UIImage() }
            return image
        }catch{
            print("Unable to load data: \(error)")
        }
        return UIImage()
    }
}

struct CardItem: CardSliderItem{
    var image: UIImage
    var rating: Int?
    var title: String
    var subtitle: String?
    var description: String?
}
