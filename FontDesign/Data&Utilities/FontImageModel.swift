//
//  FontImageModel.swift
//  FontDesign
//
//  Created by Netra Technosys on 24/11/21.
//

import Foundation
import UIKit

class FontImage {
    var index: String = "0"
    var alphabet: String?
    var drawImage: UIImage?
    
    init(dic: NSMutableDictionary) {
        self.index = dic.value(forKey: "index") as? String ?? "0"
        self.alphabet = dic.value(forKey: "alphabet") as? String
        self.drawImage = dic.value(forKey: "draw_image") as? UIImage
    }
}
