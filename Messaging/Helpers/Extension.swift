//
//  Extension.swift
//  Messaging
//
//  Created by A on 15.05.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCache(profileImageUrl: String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: profileImageUrl as NSString) {
            self.image = cachedImage
            return
        }
        
        let url = URL(string: profileImageUrl)!
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                print("error")
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: profileImageUrl as NSString)
                    
                    self.image = downloadedImage
                }
            
            }
        }.resume()
    }
}
