/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Sketch
import Ripples

class AlphabetCollectionCell: UICollectionViewCell {
    @IBOutlet weak var viewCheck: UIButton!
    @IBOutlet weak var viewSelectedAlphabet: UILabel!
    @IBOutlet weak var lblAlpabet: UILabel!
}

class FontDrawCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var drawView: SketchView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}

class GuideappCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rippleView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    let ripple = Ripples()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (self.bounds.height)-8)
        self.ripple.radius = 200
        self.ripple.keyTimeForHalfOpacity = 0.7
        self.ripple.backgroundColor = UIColor(red: 220/255, green: 201/255, blue: 182/255, alpha: 1.0).cgColor
        self.ripple.rippleCount = 10
        self.imageView.frame = CGRect(x: 0, y: 0, width: 270, height: 190)
        self.imageView.center = view.center
        view.addSubview(self.imageView)
        view.layer.addSublayer(self.ripple)
        self.ripple.position = view.center
        self.addSubview(view)
        view.bringSubview(toFront: self.imageView)
        
        self.ripple.start()
        
    }
}

