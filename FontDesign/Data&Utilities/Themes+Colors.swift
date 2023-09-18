//
//  Themes+Colors.swift
//  SecNinjazKeyboard
//
//  Created by Leela Prasad on 30/04/18.
//  Copyright © 2018 Leela Prasad. All rights reserved.
//

import UIKit

enum KBColorScheme {
    case dark
    case light
}

struct KBColors {
    
    let buttonTextColor: UIColor
    let buttonBackgroundColor: UIColor
    let buttonHighlightColor: UIColor
    let backgroundColor: UIColor
    let previewTextColor: UIColor
    let previewBackgroundColor: UIColor
    let buttonTintColor: UIColor
    
    init(colorScheme: KBColorScheme) {
        switch colorScheme {
        case .light:
            self.buttonTextColor = .black
            self.buttonTintColor = .black
            self.buttonBackgroundColor = .white
            self.buttonHighlightColor = UIColor(red: 174/255, green: 179/255, blue: 190/255, alpha: 1.0)
            self.backgroundColor = UIColor(red: 210/255, green: 213/255, blue: 219/255, alpha: 1.0)
            self.previewTextColor = .white
            self.previewBackgroundColor = UIColor(red: 186/255, green: 191/255, blue: 200/255, alpha: 1.0)
        case .dark:
            self.buttonTextColor = .white
            self.buttonTintColor = .white
            self.buttonBackgroundColor = UIColor(white: 138/255, alpha: 1.0)
            self.buttonHighlightColor = UIColor(white: 104/255, alpha: 1.0)
            self.backgroundColor = UIColor(white:89/255, alpha: 1.0)
            self.previewTextColor = .white
            self.previewBackgroundColor = UIColor(white: 80/255, alpha: 1.0)
        }
    }
    
}
