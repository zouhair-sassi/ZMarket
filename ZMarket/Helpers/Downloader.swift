//
//  Downloader.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 10/3/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import Foundation
import FirebaseStorage

let storage = Storage.storage()

func uploadImages(images: [UIImage?], itemId: String, completion: @escaping(_ imagesLinks: [String]) -> Void) {

    if Reachabilty.HasConnection() {
        var uploadedImagesCount = 0
        var imageLinkArray: [String] = []
        var nameSuffix = 0

        for image in images {

            let fileName = "ItemImages/" + itemId + "/" + "\(nameSuffix)" + ".jpg"
            let imageData = image!.jpegData(compressionQuality: 0.5)

            saveImageInFirebase(imageData: imageData!, fileName: fileName) { (imageLink) in

                if imageLink != nil {

                    imageLinkArray.append(imageLink!)

                    uploadedImagesCount += 1

                    if uploadedImagesCount == images.count {
                            completion(imageLinkArray)
                    }
                }
            }

            nameSuffix += 1
        }
    } else {
        print("No internet connection")
    }
}

func saveImageInFirebase(imageData: Data, fileName: String, completion: @escaping (_ imageLink: String?) -> Void) {

    var task: StorageUploadTask!
    let storageRef = storage.reference(forURL: KFILEREFERENCE).child(fileName)
    task = storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
        task.removeAllObservers()
        if error != nil {
            print("Error uploading image", error!.localizedDescription)
            completion(nil)
            return
        }
        storageRef.downloadURL { (url, error) in
            guard let downloadURl = url else {
                completion(nil)
                return
            }
            completion(downloadURl.absoluteString)
        }
    })
}
