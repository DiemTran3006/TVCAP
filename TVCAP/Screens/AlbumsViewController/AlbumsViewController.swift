//
//  AlbumsViewController.swift
//  TVCAP
//
//  Created by Bui Trung Quan on 07/11/2023.
//

import UIKit
import Photos

class AlbumsViewController: UIViewController {
    @IBOutlet weak var albumsCollectionView: UICollectionView! {
        didSet {
            albumsCollectionView.dataSource = self
            albumsCollectionView.delegate = self
            albumsCollectionView.register(cellType: AlbumsCollectionViewCell.self)
        }
    }
    
    public weak var photoDelegate: PhotoDelegate?
    private var listAlbums: [AlbumModel] = [AlbumModel]() {
        didSet {
            albumsCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Albums"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        
        getListAlbums()
    }
    
    @objc func cancelTapped() {
        self.navigationController?.dismiss(animated: true)
    }
    
    private func getListAlbums() {
        var listAlbums:[AlbumModel] = [AlbumModel]()
        
        let options = PHFetchOptions()
        let recentObj = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: options).firstObject
        if let recentObj = recentObj {
            let recentAlbum = AlbumModel(name: recentObj.localizedTitle ?? "Recents", count: recentObj.photosCount, photoAssets: PHAsset.fetchAssets(in: recentObj, options: nil))
            if recentAlbum.count != 0 {
                listAlbums.append(recentAlbum)
            }
        }
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        userAlbums.enumerateObjects{ (object: AnyObject, count: Int, stop: UnsafeMutablePointer) in
            guard let obj = object as? PHAssetCollection else { return }
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            let newAlbum = AlbumModel(name: obj.localizedTitle!, count: obj.estimatedAssetCount, photoAssets:PHAsset.fetchAssets(in: obj, options: nil))
            if newAlbum.count != 0 {
                listAlbums.append(newAlbum)
            }
        }
        
        self.listAlbums = listAlbums
    }
    
}

extension AlbumsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthItem = Int((collectionView.frame.width-40-11)/2)
        return .init(width: widthItem, height: widthItem+54)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        11
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
}

extension AlbumsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(with: AlbumsCollectionViewCell.self, for: indexPath) else { return AlbumsCollectionViewCell()}
        cell.nameAlbums.text = listAlbums[indexPath.row].name
        cell.numberPhotos.text = "\(listAlbums[indexPath.row].count) photos"
        cell.imageAlbums.addTapGesture { [weak self] in
            
            guard let self = self else { return }
            self.photoDelegate?.selectedAlbums(title: listAlbums[indexPath.row].name, photoAssets: listAlbums[indexPath.row].photoAssets)
            cancelTapped()
        }
        if let firstObject = listAlbums[indexPath.row].photoAssets.firstObject {
              cell.imageAlbums.fetchImage(asset: firstObject, contentMode: .aspectFill, targetSize: cell.imageAlbums.frame.size)
            }
        return cell
    }
}
