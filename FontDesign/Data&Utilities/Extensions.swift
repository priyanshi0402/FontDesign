//
//  Extensions.swift
//  RupeSoKeyboard
//
//  Created by Leela Prasad on 17/04/18.
//  Copyright © 2018 Leela Prasad. All rights reserved.
//

import UIKit
import CoreGraphics
import Accelerate.vImage

extension UIView {
    
    func addCornerWithBorder(value: CGFloat) {
        self.layer.cornerRadius = value
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = true
    }
    
    func scale(by scale: CGFloat) {
        self.contentScaleFactor = scale
        for subview in self.subviews {
            subview.scale(by: scale)
        }
    }
    
    func asImage(scale: CGFloat? = nil) -> UIImage? {
        let newScale = scale ?? UIScreen.main.scale
        self.scale(by: newScale)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale
        
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size, format: format)
        
        let image = renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
        
        return image
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, scale: Bool = true) {
        self.layer.masksToBounds = false
        
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = 15.0
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        self.layer.cornerRadius = 30.0
        self.backgroundColor = .white
    }
    
    func addCorner(value: CGFloat) {
        self.layer.cornerRadius = value
        self.layer.masksToBounds = true
    }
    
    func playInputClick​() {
        UIDevice.current.playInputClick()
    }
}

extension UITextView {
    
    func textViewAsImage(scale: CGFloat) -> UIImage? {
        let newScale = scale
        self.scale(by: newScale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale
        var frame = self.frame.size
        if frame.height <= 200 {
            frame.height = 200
        }
        print(frame)
        
        let renderer = UIGraphicsImageRenderer(size: frame, format: format)
        let image = renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
        
        return image
    }
    
    func setAttributedTextWithImage(image: UIImage) {
        let attachment = NSTextAttachment()
        attachment.adjustsImageSizeForAccessibilityContentSizeCategory = true
        attachment.image = image
        
        let attrStringWithImage = NSAttributedString(attachment: attachment)
        
        self.textStorage.insert(attrStringWithImage, at: self.selectedRange.location)
        let newPosition = self.endOfDocument
        self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
    }
}

extension UIImage {
    
    func resizeImageWithQuality(targetSize: CGSize, isUppercased: Bool) -> UIImage? {
        let size = self.size
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func trimmingTransparentPixels(maximumAlphaChannel: UInt8 = 1, char: Character) -> UIImage? {
        guard size.height > 1 && size.width > 1
        else { return self }
        
#if canImport(UIKit)
        guard let cgImage = cgImage?.trimmingTransparentPixels(maximumAlphaChannel: maximumAlphaChannel, char: char)
        else { return nil }
        
        let image = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        return image
#else
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil)?
                .trimmingTransparentPixels(maximumAlphaChannel: maximumAlphaChannel, char: char)
        else { return nil }
        
        let scale = recommendedLayerContentsScale(0)
        let scaledSize = CGSize(width: CGFloat(cgImage.width) / scale,
                                height: CGFloat(cgImage.height) / scale)
        let image = NSImage(cgImage: cgImage, size: scaledSize)
        image.isTemplate = isTemplate
        return image
#endif
    }
    
}

extension UIInputView: UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool {
        get {
            return true
        }
    }
}

extension UIButton {
    
    func setToCopy() {
        self.isUserInteractionEnabled = true
        self.setTitle("Copy", for: .normal)
        self.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    }
    
    func setToCopied() {
        self.isUserInteractionEnabled = false
        self.setTitle("Copied", for: .normal)
        self.backgroundColor = .green
    }
}

extension UIReturnKeyType {
    
    func get (rawValue: Int)-> String {
        
        switch self.rawValue {
        case UIReturnKeyType.default.rawValue:
            return "Return"
        case UIReturnKeyType.continue.rawValue:
            return "Continue"
        case UIReturnKeyType.google.rawValue:
            return "google"
        case UIReturnKeyType.done.rawValue:
            return "Done"
        case UIReturnKeyType.search.rawValue:
            return "Search"
        case UIReturnKeyType.join.rawValue:
            return "Join"
        case UIReturnKeyType.next.rawValue:
            return "Next"
        case UIReturnKeyType.emergencyCall.rawValue:
            return "Emg Call"
        case UIReturnKeyType.route.rawValue:
            return "Route"
        case UIReturnKeyType.send.rawValue:
            return "Send"
        case UIReturnKeyType.yahoo.rawValue:
            return "search"
            
        default:
            return "Default"
        }
        
    }
    
}
