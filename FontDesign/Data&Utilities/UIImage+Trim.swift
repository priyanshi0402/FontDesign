//
//  UIImage+Trim.swift
//  FontDesign
//
//  Created by Netra Technosys on 24/11/21.
//

import Foundation
import UIKit

extension CGImage {
    
    /// Crops the insets of transparency around the image.
    /// - Parameters:
    /// - maximumAlphaChannel: The maximum alpha channel value to consider  _transparent_ and thus crop. Any alpha value
    /// strictly greater than `maximumAlphaChannel` will be considered opaque.
    func trimmingTransparentPixels(maximumAlphaChannel: UInt8 = 1, char: Character) -> CGImage? {
        return _CGImageTransparencyTrimmer(image: self, maximumAlphaChannel: maximumAlphaChannel)?.trim(char: char)
    }
    
}

private struct _CGImageTransparencyTrimmer {
    
    let image: CGImage
    let maximumAlphaChannel: UInt8
    let cgContext: CGContext
    let zeroByteBlock: UnsafeMutableRawPointer
    let pixelRowRange: Range<Int>
    let pixelColumnRange: Range<Int>
    
    init?(image: CGImage, maximumAlphaChannel: UInt8) {
        guard let cgContext = CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue), cgContext.data != nil
        else { return nil }
        
        cgContext.draw(image, in: CGRect(origin: .zero,size: CGSize(width: image.width,height: image.height)))
        guard let zeroByteBlock = calloc(image.width, MemoryLayout<UInt8>.size)
        else { return nil }
        
        self.image = image
        self.maximumAlphaChannel = maximumAlphaChannel
        self.cgContext = cgContext
        self.zeroByteBlock = zeroByteBlock
        
        self.pixelRowRange = 0..<image.height
        self.pixelColumnRange = 0..<image.width
    }
    
    func trim(char: Character) -> CGImage? {
        guard let topInset = self.firstOpaquePixelRow(in: self.pixelRowRange),
              let bottomOpaqueRow = self.firstOpaquePixelRow(in: self.pixelRowRange.reversed()),
              let leftInset = self.firstOpaquePixelColumn(in: self.pixelColumnRange),
              let rightOpaqueColumn = self.firstOpaquePixelColumn(in: self.pixelColumnRange.reversed())
        else { return nil }
        
        var bottomInset = (self.image.height) - bottomOpaqueRow
        var rightInset = (self.image.width) - rightOpaqueColumn
        var top = topInset
        var left = leftInset-20
        
        let imageSize = CGRect(origin: CGPoint(x: left, y: top), size: CGSize(width: self.image.width - (left + rightInset), height: self.image.height - (top + bottomInset)))
        let imageHeight = imageSize.height
        let strChar = String(char)
        
        if char.isLowercase {
            if strChar == "g" || strChar == "j" || strChar == "q" || strChar == "p" || strChar == "y"{
                if imageHeight >= 300 {
                    top = top-160
                } else {
                    top = top-180
                }
                //bottomInset = bottomInset-20
            } else {
                if imageHeight >= 300 {
                    top = top-50
                } else if imageHeight >= 250 {
                    top = top-80
                } else if imageHeight >= 200 {
                    top = top-120
                } else {
                    top = top-140
                }
            }
            
        } else if char.isUppercase {
            bottomInset = bottomInset-40
        } else if char.isASCII || char.isSymbol {
            
            if strChar == "\"" || strChar == "'" || strChar == "^" {
                top = topInset
                bottomInset = bottomInset-110
                rightInset = rightInset-10
                left = left-10
            } else if strChar == "~" || strChar == "-" {
                top = topInset-150
                bottomInset = bottomInset-60
            } else if strChar == "=" {
                top = topInset-15
                bottomInset = bottomInset-30
            } else if strChar == "_" {
                top = top-170
            } else if strChar == "," {
                top = top-200
            } else if strChar == "." {
                top = top-170
                left = leftInset-10
            } else if strChar == ";" || strChar == ":" {
                top = top-50
                left = leftInset-20
                //bottomInset = bottomInset+30
            } else if strChar == "*" || strChar == "+" {
                top = top-50
                bottomInset = bottomInset-50
                //bottomInset = bottomInset+30
            } else {
                top = top-20
            }
            bottomInset = bottomInset-40
        }
        
        guard !(top == 0 && bottomInset == 0 && leftInset == 0 && rightInset == 0)
        else { return self.image }
        let trimmedImage = self.image.cropping(to: CGRect(origin: CGPoint(x: left, y: top),size: CGSize(width: self.image.width - (left + rightInset), height: self.image.height - (top + bottomInset))))
        //let uiimageAfter = UIImage(cgImage: trimmedImage!)
        return trimmedImage
    }
    
    @inlinable
    func isPixelOpaque(column: Int, row: Int) -> Bool {
        // Sanity check: It is safe to get the data pointer in iOS 4.0+ and macOS 10.6+ only.
        assert(self.cgContext.data != nil)
        return self.cgContext.data!.load(fromByteOffset: (row * self.cgContext.bytesPerRow) + column, as: UInt8.self)
        > self.maximumAlphaChannel
    }
    
    @inlinable
    func isPixelRowTransparent(_ row: Int) -> Bool {
        assert(self.cgContext.data != nil)
        // `memcmp` will efficiently check if the entire pixel row has zero alpha values
        return memcmp(self.cgContext.data! + (row * self.cgContext.bytesPerRow), self.zeroByteBlock, self.image.width) == 0
        // When the entire row is NOT zeroed, we proceed to check each pixel's alpha
        // value individually until we locate the first "opaque" pixel (very ~not~ efficient).
        || !self.pixelColumnRange.contains(where: { self.isPixelOpaque(column: $0, row: row) })
    }
    
    @inlinable
    func firstOpaquePixelRow<T: Sequence>(in rowRange: T) -> Int? where T.Element == Int {
        return rowRange.first(where: { !self.isPixelRowTransparent($0) })
    }
    
    @inlinable
    func firstOpaquePixelColumn<T: Sequence>(in columnRange: T) -> Int? where T.Element == Int {
        return columnRange.first(where: { column in
            self.pixelRowRange.contains(where: { self.isPixelOpaque(column: column, row: $0) })
        })
    }
}
