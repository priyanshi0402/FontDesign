//
//  FontDataModel.swift
//  FontDesign
//
//  Created by Netra Technosys on 24/11/21.
//

import Foundation
import UIKit


class FontData: Codable {
    var index: String = "0"
    var alphabet: String?
    var image: String?
    //var fontWriting: UIImage? = nil
    
    init(dic: NSMutableDictionary) {
        self.index = dic.value(forKey: "font_index") as? String ?? "0"
        self.alphabet = dic.value(forKey: "alphabet") as? String
        self.image = dic.value(forKey: "font_image") as? String
        //self.fontWriting = dic.value(forKey: "ui_image") as? UIImage ?? UIImage()
    }
}
