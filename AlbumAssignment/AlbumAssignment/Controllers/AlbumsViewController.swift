//
//  ViewController.swift
//  AlbumAssignment
//
//  Created by Alaa Khalil on 1/7/21.
//

import UIKit
import Kingfisher

class AlbumsViewController: UIViewController{
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    var albumsData = [AlbumsModel]()
    var photosData = [PhotosModel]()
    var photoOfAlbumsDict = [Int:String]()
    var data = [CardItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAlbums()
    }
    
    // Getting Albums`s Data From API
    func getAlbums(){
        DispatchQueue.main.async {
            ApiManager.shared.getAlbums {(response, error) in
                if error == nil{
                    self.albumsData = response
                }
                self.savePhotoOfAlbum()
            }
        }
    }
    
    // Get the first photo of each album and
    // save it as a value of album id
    func savePhotoOfAlbum(){
        DispatchQueue.main.async {
            ApiManager.shared.getAllPhotos {(response, erorr) in
                if erorr == nil{
                    self.photosData = response
                    for item in self.photosData{
                        if !self.photoOfAlbumsDict.keys.contains(item.albumId!){
                            self.photoOfAlbumsDict[item.albumId!] = item.thumbnailUrl
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
        let imageUrl = self.photoOfAlbumsDict[albumsData[index].id!]
        cell.updateCell(albumTitle: albumsData[index].title ?? " ", albumImageUrl: imageUrl ?? " " )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        self.getPhotosOfAlbum(albumId: albumsData[index].id!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        return CGSize(width: (width/2 - 6), height: height/4 - 6)
    }
    
    func getPhotosOfAlbum(albumId: Int){
        ApiManager.shared.getPhotosOfAlbum(albumId: albumId) { [self] (response, erorr) in
            if erorr == nil{
                self.data.removeAll()
                self.photosData = response
                for item in self.photosData {
                    self.data.append(CardItem(image: nil,url: item.url!,rating: nil, title: item.title!, subtitle: nil, description: nil))
                }
                let cardSlider = CardSliderViewController.with(dataSource: self)
                cardSlider.title = "Album \(String(describing: albumId))"
                cardSlider.modalPresentationStyle = .overFullScreen
                self.present(cardSlider, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Card Slider

extension AlbumsViewController: CardSliderDataSource{
    func item(for index: Int) -> CardSliderItem {
        return data[index]
    }
    
    func numberOfItems() -> Int {
        return data.count
    }
}

struct CardItem: CardSliderItem{
    var image: UIImage?
    var url: String
    var rating: Int?
    var title: String
    var subtitle: String?
    var description: String?
}
