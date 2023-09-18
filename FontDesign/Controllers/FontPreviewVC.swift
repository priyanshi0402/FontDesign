//
//  FontPreviewVC.swift
//  FontDesign
//
//  Created by Netra Technosys on 2/12/21.
//

import UIKit
import AppLovinSDK

class FontPreviewVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var bannerAdView: UIView!
    @IBOutlet weak var secondTextView: UITextView!
    @IBOutlet weak var previewFontTxt: UITextView!
    
    var textViewString = ""
    var drawFontArray : [FontImage] = []
    var previousRect = CGRect.zero
    var isClickReturn = false
    
    var interstitialAd: MAInterstitialAd!
    var retryAttempt = 0.0
    var timer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setUpimageInArray()
        self.previewFontTxt.becomeFirstResponder()
        self.previewFontTxt.tintColor = .clear
        self.previewFontTxt.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadBanneradView()
        self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: false)
        self.createInterstitialAd()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    func loadBanneradView() {
        let adView = MAAdView(adUnitIdentifier: bannerID)
        adView.delegate = self
        // Get the adaptive banner height.
        let height: CGFloat = MAAdFormat.banner.adaptiveSize.height
        adView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: height)
        adView.setExtraParameterForKey("adaptive_banner", value: "true")
        // Set background or background color for banners to be fully functional
        adView.backgroundColor = .clear
        self.bannerAdView.addSubview(adView)
        adView.loadAd()
    }
    
    func createInterstitialAd() {
        self.interstitialAd = MAInterstitialAd(adUnitIdentifier: interstitalID)
        self.interstitialAd.delegate = self
        self.interstitialAd.load()
    }
    
    @objc func updateCounter() {
        self.interstitialAd.show()
        self.timer.invalidate()
        self.timer = nil
     
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.textViewString = text
        textView.tintColor = .clear
        
       if let char = text.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                print("Backspace was pressed")
                self.secondTextView.deleteBackward()
            } else {
                let isReturn = strcmp(char, "\\n")
                if (isReturn == -82) {
                    self.isClickReturn = true
                    self.setStringInTextView(text: "\n")
                }
                self.addFontInTextview(text: text)
            }
        } else {
            self.addFontInTextview(text: text)
        }
        if self.drawFontArray.count == 0 {
            return false
        } else {
            return true
        }
        
    }
    
    func addFontInTextview(text: String) {
        
        self.getImagesUsingForLoop(text: text)
        let currentRect = self.secondTextView.caretRect(for: self.secondTextView.endOfDocument)
        self.previousRect = self.previousRect.origin.y == 0.0 ? currentRect : self.previousRect
        print(self.previousRect.origin.y)
        if(currentRect.origin.y > self.previousRect.origin.y) {
            print(text)
            if !self.isClickReturn {
                for _ in 0..<text.count {
                    self.secondTextView.deleteBackward()
                }
                self.setStringInTextView(text: "\n")
                
                for char in text {
                    if let data = self.drawFontArray.first(where: {$0.alphabet == "\(char)"}) {
                        if let image = data.drawImage {
                            let whiteImage = image.withTintColor(.white)
                            self.setImageInTextviewInCenter(image: whiteImage)
                            self.secondTextView.selectedTextRange = self.secondTextView.textRange(from: self.secondTextView.endOfDocument, to: self.secondTextView.endOfDocument)
                        }
                    } else {
                        if "\(char)" == " " {
                            self.setStringInTextView(text: " ")
                        }
                    }
                }
                print("New Line")
            } else {
                self.isClickReturn = false
            }
            
        }
        self.previousRect = currentRect
    }
    
    func getImagesUsingForLoop(text: String) {
        for char in text {
            if let data = self.drawFontArray.first(where: {$0.alphabet == "\(char)"}) {
                if let image = data.drawImage {
                    let whiteImage = image.withTintColor(.white)
                    self.setImageInTextviewInCenter(image: whiteImage)
                    self.secondTextView.selectedTextRange = self.secondTextView.textRange(from: self.secondTextView.endOfDocument, to: self.secondTextView.endOfDocument)
                }
            } else {
                if "\(char)" == " " {
                    self.setStringInTextView(text: " ")
                }
            }
        }
    }
    
    func setStringInTextView(text: String) {
        let attrString = NSAttributedString(string: text)
        self.secondTextView.textStorage.insert(attrString, at: self.secondTextView.selectedRange.location)
        self.secondTextView.selectedTextRange = self.secondTextView.textRange(from: self.secondTextView.endOfDocument, to: self.secondTextView.endOfDocument)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func setImageInTextviewInCenter(image: UIImage) {
        
        let attachment = NSTextAttachment()
        attachment.adjustsImageSizeForAccessibilityContentSizeCategory = true
        attachment.image = image
        
        let imageStyle = NSMutableParagraphStyle()
        imageStyle.alignment = .center
        let imageText = NSAttributedString(attachment: attachment).mutableCopy() as! NSMutableAttributedString
        let length2 = imageText.length
        imageText.addAttribute(NSAttributedString.Key.paragraphStyle, value: imageStyle, range: NSRange(location: 0, length: length2))
        self.secondTextView.textStorage.insert(imageText, at: self.secondTextView.selectedRange.location)
    }
    
}

extension FontPreviewVC : MAAdViewAdDelegate {
    
    func didExpand(_ ad: MAAd) {
        
    }
    
    func didCollapse(_ ad: MAAd) {
        
    }
    
    func didLoad(_ ad: MAAd) {
        
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        
    }
    
    func didDisplay(_ ad: MAAd) {
        
    }
    
    func didHide(_ ad: MAAd) {
        self.createInterstitialAd()
    }
    
    func didClick(_ ad: MAAd) {
        
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        
    }
    
}
