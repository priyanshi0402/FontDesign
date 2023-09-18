//
//  KeyboardViewController.swift
//  FontDesignKeyboard
//
//  Created by Netra Technosys on 24/11/21.
//

import UIKit
import CoreLocation

class KeyboardViewController: UIInputViewController {
    
    var customKeyboardView: CustomKeyboardView!
    var userLexicon: UILexicon?
    
    var currentWord: String? {
        var lastWord: String?
        if let stringBeforeCursor = textDocumentProxy.documentContextBeforeInput {
            stringBeforeCursor.enumerateSubstrings(in: stringBeforeCursor.startIndex...,
                                                   options: .byWords)
            { word, _, _, _ in
                if let word = word {
                    lastWord = word
                }
            }
        }
        return lastWord
    }
    
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    override func viewDidAppear(_ animated: Bool) {
       
    }
    
    func openURL(url: NSURL) -> Bool {
        do {
            let application = try self.sharedApplication()
            return application.performSelector(inBackground: "openURL:", with: url) != nil
        }
        catch {
            return false
        }
    }

    func sharedApplication() throws -> UIApplication {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application
            }

            responder = responder?.next
        }

        throw NSError(domain: "UIInputViewController+sharedApplication.swift", code: 1, userInfo: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CustomKeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: nil, options: nil)
        self.customKeyboardView = objects.first as? CustomKeyboardView
        self.customKeyboardView.delegate = self
        
        self.customKeyboardView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 291)
        self.view.addSubview(self.customKeyboardView)
        self.customKeyboardView.setNextKeyboardVisible(needsInputModeSwitchKey)
        self.customKeyboardView.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.requestSupplementaryLexicon { lexicon in
            self.userLexicon = lexicon
        }
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 100
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.customKeyboardView.removeFromSuperview()
        self.customKeyboardView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 291)
        self.view.frame = self.customKeyboardView.frame
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.customKeyboardView)
        self.customKeyboardView.layoutSubviews()
        
    }
  
    override func textDidChange(_ textInput: UITextInput?) {
        let colorScheme: KBColorScheme
        
        if textDocumentProxy.keyboardAppearance == .dark {
            colorScheme = .dark
        } else {
            colorScheme = .light
        }
        self.customKeyboardView.setColorScheme(colorScheme)
    }
    
    var hasAccess: Bool {
        get{
            if #available(iOSApplicationExtension 11.0, *) {
                
                return self.hasFullAccess
            } else {
                return UIDevice.current.identifierForVendor != nil
            }
        }
    }
    
}

extension KeyboardViewController: CustomKeyboardViewDelegate {
    
    func copyAndShareImage(image: UIImage) {
        UIPasteboard.general.image = image
    }
    
    func openSubscriptionController() {
        let isSucess = self.openURL(url: NSURL(string:"subscription:")!)
        print(isSucess)
    }

    func keyboardGuidline() {
        let isSucess = self.openURL(url: NSURL(string:"guildline:")!)
        print(isSucess)
    }
    
    func insertCharacter(_ newCharacter: String) {
        self.inputView?.playInputClick​()
        if newCharacter == " " {
            self.attemptToReplaceCurrentWord()
            /*if currentWord?.lowercased() == "sos",
               let currentLocation = currentLocation {
                let lat = currentLocation.coordinate.latitude
                let lng = currentLocation.coordinate.longitude
                textDocumentProxy.insertText(" (\(lat), \(lng))")
            } else {
                
            }*/
        }
//
//        let proxy = self.textDocumentProxy
//        self.customKeyboardView.text = newCharacter
//        proxy.insertText(newCharacter)
    }
    
    func deleteCharacterBeforeCursor() {
        textDocumentProxy.deleteBackward()
    }
    
    func characterBeforeCursor() -> String? {
        guard let character = textDocumentProxy.documentContextBeforeInput?.last else {
            return nil
        }
        return String(character)
    }
}

// MARK: - Private methods
private extension KeyboardViewController {
    func attemptToReplaceCurrentWord() {
        guard let entries = userLexicon?.entries,
              let currentWord = currentWord?.lowercased() else {
                  return
              }
        
        let replacementEntries = entries.filter {
            $0.userInput.lowercased() == currentWord
        }
        
        if let replacement = replacementEntries.first {
            for _ in 0..<currentWord.count {
                textDocumentProxy.deleteBackward()
            }
            
            textDocumentProxy.insertText(replacement.documentText)
        }
        
    }
}

// MARK: - CLLocationManagerDelegate
extension KeyboardViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
}
