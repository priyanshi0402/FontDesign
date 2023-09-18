/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

/// Delegate method for the morse keyboard view that will allow it to perform
protocol CustomKeyboardViewDelegate: AnyObject {
    func insertCharacter(_ newCharacter: String)
    func deleteCharacterBeforeCursor()
    func characterBeforeCursor() -> String?
    func copyAndShareImage(image: UIImage)
    func openSubscriptionController()
    func keyboardGuidline()
}

/// Contains all of the logic for handling button taps and translating that into
/// specific actions on the text entry associated with it
class CustomKeyboardView: UIView {
    
    @IBOutlet weak var btnCheckCapital: UIButton!
    @IBOutlet weak var btnSuggestion3: UIButton!
    @IBOutlet weak var btnSuggestion2: UIButton!
    @IBOutlet weak var btnSuggestion1: UIButton!
    @IBOutlet weak var suggestionBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sepcialRow2: UIView!
    @IBOutlet weak var specialRow1: UIView!
    @IBOutlet weak var numberRow3: UIView!
    @IBOutlet weak var numberRow2: UIView!
    @IBOutlet weak var numberRow1: UIView!
    @IBOutlet weak var alphaRow3: UIView!
    @IBOutlet weak var alphaRow2: UIView!
    @IBOutlet weak var alphaRow1: UIView!
    
    @IBOutlet weak var btnCaps: KeyboardButton!
    @IBOutlet weak var btnEmoji: KeyboardButton!
    @IBOutlet weak var btnReturn: KeyboardButton!
    @IBOutlet weak var btnSpace: KeyboardButton!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var textMainView: UIView!
    @IBOutlet weak var textBorderView: UIView!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var btnCloseTextView: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnNumeric: KeyboardButton!
    @IBOutlet var nextKeyboardButton: KeyboardButton!
    @IBOutlet var deleteButton: KeyboardButton!
    
    weak var delegate: CustomKeyboardViewDelegate?
    var shiftStatus: Int! //0 - off, 1 - on, 2 - caps lock
    var strArray : [String] = []
    var fontData: [FontData]? = []
    var drawFontArray: [FontImage] = []
    var spaceStr = ""
    var tappedAlphabetFull = ""
    var tappedAlphabetWord = ""
    var previousRect = CGRect.zero
    var lineBreakText = ""
    var isClickReturn = false
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setColorScheme(.light)
        setNextKeyboardVisible(false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkIAPStatus()
        self.setupView()
        self.setUpimageInArray()
        self.setUpGesture()
        
    }
    
    func checkIAPStatus() {
        
        if checkReward() {
//            setWeeklyPurchased(bool: false)
            serverTimeReturn { getResDate in
                if getResDate != "" , let serverDate = convertStringToDateReward(str: getResDate) {
                    if getRewardDate() != "" , let rewardDate = convertStringToDateReward(str: getRewardDate()) {
                        let diffComponents = Calendar.current.dateComponents([.hour], from: rewardDate, to: serverDate)
                        if diffComponents.hour ?? 0 > 1 {
                            let defaults = UserDefaults(suiteName: groupID)
                            defaults?.set(false, forKey: "get_reward")
                            defaults?.synchronize()
                            setWeeklyPurchased(bool: false)
                            print(false)
                        } else {
                            setWeeklyPurchased(bool: true)
                            print(true)
                        }
                    }
                    
                }
            }
            
        } else {
            IAPHelper.checkPurchaseStatus(productId: weekly_id) { errorStr, expiryDate, isSuccess in
                if isSuccess, let eDate = expiryDate {
                    if isSuccess {
                        setWeeklyPurchased(bool: true)
                        setIAPStartDate(date: Date())
                        setIAPExpiryDate(date: eDate)
                    } else {
                        setWeeklyPurchased(bool: false)
                    }
                } else {
                    setWeeklyPurchased(bool: false)
                }
            }
        }
        
    }
    
    func setupView() {
        
        self.fontData = fontsArray
        self.shiftStatus = 1
        
        self.numberRow1.isHidden = true
        self.numberRow2.isHidden = true
        self.numberRow3.isHidden = true
        self.sepcialRow2.isHidden = true
        self.specialRow1.isHidden = true
//        self.suggestionBarHeight.constant = 0
        
        self.textBorderView.addCornerWithBorder(value: 15.0)
        self.btnCopy.addCorner(value: 8.0)
        self.btnCloseTextView.addCorner(value: self.btnCloseTextView.frame.height / 2)
        self.setColorScheme(.light)
        self.setNextKeyboardVisible(false)
        
    }
    
    func setUpimageInArray() {
        self.drawFontArray.removeAll()
        if let array = fontsArray {
            for data in array {
                if let imageURL = data.image {
                    if let url = URL(string: imageURL) {
                        let image = UIImage(contentsOfFile: "\(url.path)")
                        let char = Character(data.alphabet ?? "")
//                        char.is
                        if let trimmedImage = image?.trimmingTransparentPixels(maximumAlphaChannel: 1, char: char) {
                            if let resizeImage = trimmedImage.resizeImageWithQuality(targetSize: CGSize(width: 15, height: 15), isUppercased: char.isUppercase) {
                                
                                DispatchQueue.global(qos: .utility).async {
                                    DispatchQueue.main.async {
                                        let dic : NSMutableDictionary = NSMutableDictionary()
                                        dic.setValue(resizeImage, forKey: "draw_image")
                                        dic.setValue(data.alphabet ?? "", forKey: "alphabet")
                                        dic.setValue(data.index, forKey: "index")
                                        let drawFont = FontImage(dic: dic)
                                        self.drawFontArray.append(drawFont)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func setUpGesture() {
        let longPrssRcngr = UILongPressGestureRecognizer.init(target: self, action: #selector(onLongPressOfBackSpaceKey(longGestr:)))
        longPrssRcngr.minimumPressDuration = 0.5
        longPrssRcngr.numberOfTouchesRequired = 1
        longPrssRcngr.allowableMovement = 0.1
        self.deleteButton.addGestureRecognizer(longPrssRcngr)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.btnCaps.addGestureRecognizer(doubleTapGesture)
    }
    
    func setNextKeyboardVisible(_ visible: Bool) {
        self.nextKeyboardButton.isHidden = !visible
    }
    
    func setColorScheme(_ colorScheme: KBColorScheme) {
        let colorScheme = KBColors(colorScheme: colorScheme)
        self.backgroundColor = colorScheme.backgroundColor
        
        for stackView in self.buttonsView.subviews {
            if let button = stackView as? KeyboardButton {
                button.setTitleColor(colorScheme.buttonTextColor, for: [])
                button.tintColor = colorScheme.buttonTextColor
                if button == self.deleteButton {
                    button.defaultBackgroundColor = colorScheme.buttonHighlightColor
                    button.highlightBackgroundColor = colorScheme.buttonBackgroundColor
                } else {
                    button.defaultBackgroundColor = colorScheme.buttonBackgroundColor
                    button.highlightBackgroundColor = colorScheme.buttonHighlightColor
                }
            }
            
            for button in stackView.subviews {
                if let button = button as? KeyboardButton {
                    button.setTitleColor(colorScheme.buttonTextColor, for: [])
                    button.tintColor = colorScheme.buttonTextColor
                    
                    if button == self.nextKeyboardButton || button == self.btnReturn || button == self.btnNumeric {
                        button.defaultBackgroundColor = colorScheme.buttonHighlightColor
                        button.highlightBackgroundColor = colorScheme.buttonBackgroundColor
                    } else {
                        button.defaultBackgroundColor = colorScheme.buttonBackgroundColor
                        button.highlightBackgroundColor = colorScheme.buttonHighlightColor
                    }
                }
            }
            
        }
    }
    
    @objc func onLongPressOfBackSpaceKey(longGestr: UILongPressGestureRecognizer) {
        
        switch longGestr.state {
        case .began:
            if let delegate = delegate {
                self.tappedAlphabetFull = String(self.tappedAlphabetFull.dropLast())
                self.tappedAlphabetWord = String(self.tappedAlphabetWord.dropLast())
                self.spaceStr = String(self.spaceStr.dropLast())
                self.lineBreakText = String(self.lineBreakText.dropLast())
                self.getSuggestionWords(str: self.tappedAlphabetWord)
                
                self.textView.deleteBackward()
                delegate.deleteCharacterBeforeCursor()
            }
            
        case .ended:
            print("Ended")
            return
        default:
            if let delegate = delegate {
                self.tappedAlphabetFull = String(self.tappedAlphabetFull.dropLast())
                self.tappedAlphabetWord = String(self.tappedAlphabetWord.dropLast())
                self.spaceStr = String(self.spaceStr.dropLast())
                self.lineBreakText = String(self.lineBreakText.dropLast())
                self.getSuggestionWords(str: self.tappedAlphabetWord)
                self.textView.deleteBackward()
                delegate.deleteCharacterBeforeCursor()
            }
            //deleteLastWord()
        }
        
    }
    
    @IBAction func alphabetKeyPressed(button: UIButton) {
        if let delegate = self.delegate {
            //self.tappedAlphabetWord = ""
            guard let title = button.currentTitle else { return }
            
            let colorScheme = KBColors(colorScheme: .light)
            
            for stackView in self.buttonsView.subviews {
                if stackView == self.alphaRow1 ||  stackView == self.alphaRow2 || stackView == self.alphaRow3 || stackView == self.numberRow1 ||  stackView == self.numberRow2 || stackView == self.numberRow3 || stackView == self.specialRow1 ||  stackView == self.sepcialRow2 {
                    for buttons in stackView.subviews {
                        if let button = buttons as? KeyboardButton {
                            if button.currentTitle?.lowercased() == title.lowercased() {
//                                button.isHighlighted = true
                                button.backgroundColor = colorScheme.buttonHighlightColor
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    button.backgroundColor = colorScheme.buttonBackgroundColor
                                }
                                
                            }
                        }
                    }
                    
                }
            }
            
            self.tappedAlphabetFull.append(title)
            self.tappedAlphabetWord.append(title)
            self.getSuggestionWords(str: self.tappedAlphabetWord)
            
            self.spaceStr = ""
            if self.shiftStatus == 1 {
                self.btnCapsLockClicked(UIButton())
            }

            if let data = self.drawFontArray.first(where: {$0.alphabet == title}) {
                self.lineBreakText.append(title)
                if let image = data.drawImage {
                    self.textView.setAttributedTextWithImage(image: image)
                    
                    let currentRect = self.textView.caretRect(for: self.textView.endOfDocument)

                    if(currentRect.origin.y > self.previousRect.origin.y) {
                        if self.lineBreakText.contains(" ") {
                            if !self.isClickReturn {
                                let array = self.lineBreakText.components(separatedBy: " ")
                                if let last = array.last {
                                    let lastWord = last
                                    for _ in 0..<lastWord.count {
                                        self.textView.deleteBackward()
                                    }
                                    print(last)
                                    let attrString = NSAttributedString(string: "\n")
                                    self.textView.textStorage.insert(attrString, at: self.textView.selectedRange.location)
                                    let newPosition = self.textView.endOfDocument
                                    self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
                                    
                                    for char in lastWord {
                                        if let data = self.drawFontArray.first(where: {$0.alphabet == "\(char)"}) {
                                            self.textView.setAttributedTextWithImage(image: data.drawImage ?? UIImage())
                                        }
                                    }
                                }
                            } else {
                                self.isClickReturn = false
                            }
                        }
                        //new line reached, write your code
                    }
                    self.previousRect = currentRect
                }
                let textStorage = NSTextStorage()
                let layoutManager = NSLayoutManager()
                textStorage.addLayoutManager(layoutManager)
                let textViewFrame = CGRect.zero
                let textContainer = NSTextContainer(size: textViewFrame.size)
                layoutManager.addTextContainer(textContainer)

                textContainer.widthTracksTextView = true
                textContainer.heightTracksTextView = true
            } else {
                let attrString = NSAttributedString(string: "\(title)")
                self.textView.textStorage.insert(attrString, at: self.textView.selectedRange.location)
                let newPosition = self.textView.endOfDocument
                self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
            }
            
            delegate.insertCharacter(title)
        }
    }
    
    @IBAction func btnCopyClicked(_ sender: Any) {
        if self.textView.text.count > 0 {
            if is_purchased_weekly {
                self.copyImageOfFont()
            }else {
                if let delegate = self.delegate {
                    delegate.openSubscriptionController()
                }
            }
//            if #available(iOS 15.0, *) {
//                self.checkIAPForiOS15()
//            } else {
                // Fallback on earlier versions
                self.checkIAPStatus()
//            }
        }
    }
    
    func copyImageOfFont() {
        let textView = UITextView(frame: CGRect(origin: .zero, size: self.textView.contentSize))
        textView.textStorage.append(self.textView.attributedText)
        textView.backgroundColor = .clear
        textView.tintColor = .clear
        textView.layoutSubviews()
        
        if let image = textView.textViewAsImage(scale: UIScreen.main.scale) {
            let size = CGRect(origin: .zero, size: image.size)
            let imageView = UIImageView(frame: size)
            imageView.backgroundColor = .systemGray3
            imageView.image = image
            if let finalImage = imageView.asImage() {
                self.btnCopy.setToCopied()
                UIPasteboard.general.image = finalImage
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self.btnCopy.setToCopy()
                }
                if let delegate = self.delegate {
                    delegate.copyAndShareImage(image: finalImage)
                }
            }
        }
    }
    
    /*@available(iOS 15.0, *)
    func checkIAPForiOS15() {
        var config = UIButton.Configuration.filled()
        config.showsActivityIndicator = true
        config.title = ""
        self.btnCopy.configuration = config
        self.btnCopy.setTitle("", for: .normal)
        
        IAPHelper.checkPurchaseStatus(productId: weekly_id) { errorStr, expiryDate, isSuccess in
            if isSuccess, let eDate = expiryDate {
                if isSuccess {
                    setWeeklyPurchased(bool: true)
                    setIAPStartDate(date: Date())
                    setIAPExpiryDate(date: eDate)
                    
                    self.btnCopy.isUserInteractionEnabled = false
                    config.showsActivityIndicator = false
                    config.title = "Copied"
                    config.baseBackgroundColor = .green
                    self.btnCopy.configuration = config
                    self.btnCopy.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 13.0) ?? UIFont()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                        self.btnCopy.isUserInteractionEnabled = true
                        config.title = "Copy"
                        config.baseBackgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
                        self.btnCopy.configuration = config
                    }
                    
                    self.copyImageOfFont()
                    
                } else {
                    config.showsActivityIndicator = false
                    config.title = "Copy"
                    self.btnCopy.configuration = config
                    setWeeklyPurchased(bool: false)
                    if let delegate = self.delegate {
                        delegate.openSubscriptionController()
                    }
                }
            } else {
                config.showsActivityIndicator = false
                config.title = "Copy"
                self.btnCopy.configuration = config
                setWeeklyPurchased(bool: false)
                if let delegate = self.delegate {
                    delegate.openSubscriptionController()
                }
            }
        }
    }*/
    
    @IBAction func btnSuggetions(_ sender: UIButton) {
        if sender.tag == 101 {
            //This is for first suggestion
            return
        }
        guard let title = sender.currentTitle else { return }
        for _ in  0..<self.tappedAlphabetWord.count {
            self.textView.deleteBackward()
        }
        self.tappedAlphabetWord = ""
        self.getSuggestionWords(str: self.tappedAlphabetWord)
        let array = self.tappedAlphabetFull.components(separatedBy: " ")
        if let last = array.last {
            self.tappedAlphabetFull = String(self.tappedAlphabetFull.dropLast(last.count))
            self.lineBreakText = String(self.lineBreakText.dropLast(last.count))
            
        }
        self.tappedAlphabetFull.append("\(title) ")
        self.lineBreakText.append("\(title) ")
        let suggestionWord = title+" "
        
        var lastAddedText = ""
        for char in suggestionWord {
            lastAddedText.append(char)
            if let data = self.drawFontArray.first(where: {$0.alphabet == "\(char)"}) {
                if let image = data.drawImage {
                    self.textView.setAttributedTextWithImage(image: image)
                }
            } else {
                let attrString = NSAttributedString(string: "\(char)")
                self.textView.textStorage.insert(attrString, at: self.textView.selectedRange.location)
                let newPosition = self.textView.endOfDocument
                self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
            }
            let currentRect = self.textView.caretRect(for: self.textView.endOfDocument)
            if (currentRect.origin.y > self.previousRect.origin.y) {
//                if self.lineBreakText.contains(" ") {
//                    let array = self.lineBreakText.components(separatedBy: " ")
//                    if let last = array.last {
//                        let lastWord = last
                        for _ in 0..<lastAddedText.count {
                            self.textView.deleteBackward()
                        }
                        let attrString = NSAttributedString(string: "\n")
                        self.textView.textStorage.insert(attrString, at: self.textView.selectedRange.location)
                        let newPosition = self.textView.endOfDocument
                        self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
                        
                        for char in suggestionWord {
                            if let data = self.drawFontArray.first(where: {$0.alphabet == "\(char)"}) {
                                self.textView.setAttributedTextWithImage(image: data.drawImage ?? UIImage())
                            }
                        }
//                    }
                    self.previousRect = self.textView.caretRect(for: self.textView.endOfDocument)
                    break
//                }
            }
        }
        
    }
    
    @IBAction func btnGuidKeyboardClicked(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.keyboardGuidline()
        }
    }
    
    @IBAction func btnReturnClicked(_ sender: Any) {
        DispatchQueue.global(qos: .utility).async {
            DispatchQueue.main.async {
                self.isClickReturn = true
                self.tappedAlphabetFull.append("\n")
                self.lineBreakText.append("\n")
                self.tappedAlphabetWord = ""
                self.getSuggestionWords(str: self.tappedAlphabetWord)
                let attrString = NSAttributedString(string: "\n")
                self.textView.textStorage.insert(attrString, at: self.textView.selectedRange.location)
                let newPosition = self.textView.endOfDocument
                self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
            }

        }
        
    }
    
    @IBAction func btnCloseTextView(_ sender: Any) {
        self.textView.text = ""
        self.spaceStr = ""
        self.lineBreakText = ""
        self.tappedAlphabetFull = ""
        self.tappedAlphabetWord = ""
        self.getSuggestionWords(str: self.tappedAlphabetWord)
//        self.suggestionBarHeight.constant = 0
    }
    
    @IBAction func btnSpaceClicked(_ button: UIButton) {
        
        if let delegate = self.delegate {
            self.tappedAlphabetWord = ""
            self.tappedAlphabetFull.append(" ")
            self.lineBreakText.append(" ")
            self.getSuggestionWords(str: self.tappedAlphabetWord)
            DispatchQueue.global(qos: .utility).async {
                DispatchQueue.main.async {
                    self.spaceStr += " "
                    var attrString = NSAttributedString(string: " ")
                    if self.spaceStr == "  " {
                        attrString = NSAttributedString(string: ". ")
                        self.shiftStatus = 1
                        self.shiftChange(containerView: self.alphaRow1)
                        self.shiftChange(containerView: self.alphaRow2)
                        self.shiftChange(containerView: self.alphaRow3)
                        self.spaceStr = ""
                        if self.shiftStatus == 0 {
                            if #available(iOSApplicationExtension 13.0, *) {
                                self.btnCaps.setImage(UIImage(systemName: "shift"), for: .normal)
                            }
                        } else {
                            if #available(iOSApplicationExtension 13.0, *) {
                                if self.shiftStatus == 2 {
                                    self.btnCaps.setImage(UIImage(systemName: "capslock.fill"), for: .normal)
                                } else {
                                    self.btnCaps.setImage(UIImage(systemName: "shift.fill"), for: .normal)
                                }
                            }
                        }
                    }
              
                    self.textView.textStorage.insert(attrString, at: self.textView.selectedRange.location)
                    let newPosition = self.textView.endOfDocument
                    self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
                    delegate.insertCharacter(" ")
                }
                
            }
            
        }
        
    }
    
    @IBAction func btnBackSpaceClicked(_ sender: Any) {
        self.textView.deleteBackward()
        if let delegate = self.delegate {
            self.tappedAlphabetFull = String(self.tappedAlphabetFull.dropLast())
            self.tappedAlphabetWord = String(self.tappedAlphabetWord.dropLast())
            self.spaceStr = String(self.spaceStr.dropLast())
            self.lineBreakText = String(self.lineBreakText.dropLast())
            if self.tappedAlphabetWord.count == 0 {
                let trimmedText = self.tappedAlphabetFull.trimmingCharacters(in: .whitespacesAndNewlines)
                let array = trimmedText.components(separatedBy: " ")
                if let text = array.last {
                    self.tappedAlphabetWord = text
                } else {
                    self.tappedAlphabetWord = self.tappedAlphabetFull
                }
                
            }
            self.getSuggestionWords(str: self.tappedAlphabetWord)
            let text = delegate.characterBeforeCursor()
            print(text ?? "")
            delegate.deleteCharacterBeforeCursor()
        }
    }
    
    @IBAction func btnNumericClicked(_ sender: UIButton) {
        
        if self.btnCaps.currentTitle != "#+=" {
            sender.setTitle("ABC", for: .normal)
            self.stackViewToggleShow(hidden: true)
        } else {
            sender.setTitle("123", for: .normal)
            self.stackViewToggleShow(hidden: false)
        }
    }
    
    @IBAction func btnCapsLockClicked(_ sender: UIButton) {
        DispatchQueue.global(qos: .utility).async {
            DispatchQueue.main.async {
                if sender.currentTitle == "#+=" {
                    self.stackSpecialShowToggle(hidden: true)
                } else if sender.currentTitle == "123" {
                    self.stackSpecialShowToggle(hidden: false)
                } else if sender.currentTitle != "#+=" {
                    self.shiftStatus = self.shiftStatus > 0 ? 0 : 1
                    self.shiftChange(containerView: self.alphaRow1)
                    self.shiftChange(containerView: self.alphaRow2)
                    self.shiftChange(containerView: self.alphaRow3)
                    if self.shiftStatus == 0 {
                        if #available(iOSApplicationExtension 13.0, *) {
                            self.btnCaps.setImage(UIImage(systemName: "shift"), for: .normal)
                        }
                    } else {
                        if #available(iOSApplicationExtension 13.0, *) {
                            if self.shiftStatus == 2 {
                                self.btnCaps.setImage(UIImage(systemName: "capslock.fill"), for: .normal)
                            } else {
                                self.btnCaps.setImage(UIImage(systemName: "shift.fill"), for: .normal)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func doubleTapGesture(_ doubleTap: UITapGestureRecognizer) {
        self.shiftStatus = 2
        self.shiftChange(containerView: self.alphaRow1)
        self.shiftChange(containerView: self.alphaRow2)
        self.shiftChange(containerView: self.alphaRow3)
        if self.shiftStatus == 0 {
            if #available(iOSApplicationExtension 13.0, *) {
                self.btnCaps.setImage(UIImage(systemName: "shift"), for: .normal)
            }
        } else {
            if #available(iOSApplicationExtension 13.0, *) {
                if self.shiftStatus == 2 {
                    self.btnCaps.setImage(UIImage(systemName: "capslock.fill"), for: .normal)
                } else {
                    self.btnCaps.setImage(UIImage(systemName: "shift.fill"), for: .normal)
                }
            }
        }
    }
    
    func shiftChange(containerView: UIView) {
        for view in containerView.subviews {
            if let button = view as? UIButton {
                let buttonTitle = button.titleLabel!.text
                if self.shiftStatus == 0 {
                    let text = buttonTitle!.lowercased()
                    button.setTitle("\(text)", for: .normal)
                } else {
                    let text = buttonTitle!.uppercased()
                    button.setTitle("\(text)", for: .normal)
                }
            }
        }
    }
}

// MARK: - Actions
extension CustomKeyboardView {
    
    func getSuggestionWords(str: String) {
        let rangeForEndOfStr = NSMakeRange(0, str.utf16.count)
        let spellChecker = UITextChecker()
        let completions = spellChecker.completions(forPartialWordRange: rangeForEndOfStr, in: str, language: "en")
        print(completions ?? "No completion found")
        let suggestions = completions ?? []
        if suggestions.count >= 3 {
            self.btnSuggestion1.setTitle(str.count > 0 ? "\""+str+"\"" : nil, for: .normal)
            self.btnSuggestion2.setTitle(suggestions[0], for: .normal)
            self.btnSuggestion3.setTitle(suggestions[1], for: .normal)
        } else {
            self.btnSuggestion1.setTitle(str.count > 0 ? "\""+str+"\"" : nil, for: .normal)
            self.btnSuggestion2.setTitle(nil, for: .normal)
            self.btnSuggestion3.setTitle(nil, for: .normal)
        }
    }
    
    func stackViewToggleShow(hidden: Bool) {
        
        self.alphaRow1.isHidden = hidden
        self.alphaRow2.isHidden = hidden
        self.alphaRow3.isHidden = hidden
        
        self.numberRow1.isHidden = !hidden
        self.numberRow2.isHidden = !hidden
        self.numberRow3.isHidden = !hidden
        self.sepcialRow2.isHidden = true
        self.specialRow1.isHidden = true
    
        if self.btnCaps.currentTitle == "#+=" {
            self.btnCaps.setTitle(nil, for: .normal)
            let title = self.btnCheckCapital.currentTitle ?? ""
            let char = Character(title)
            if char.isUppercase {
                if #available(iOSApplicationExtension 13.0, *) {
                    self.btnCaps.setImage(UIImage(systemName: "shift.fill"), for: .normal)
                }
            } else {
                if #available(iOSApplicationExtension 13.0, *) {
                    self.btnCaps.setImage(UIImage(systemName: "shift"), for: .normal)
                }
            }
            
            
            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapGesture(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            self.btnCaps.addGestureRecognizer(doubleTapGesture)
//            self.btnCapsLockClicked(UIButton())
        } else {
            self.btnCaps.setTitle("#+=", for: .normal)
            for recognizer in self.btnCaps.gestureRecognizers ?? [] {
                self.btnCaps.removeGestureRecognizer(recognizer)
            }
            self.btnCaps.setImage(nil, for: .normal)
        }
        
    }
    
    func stackSpecialShowToggle(hidden: Bool) {
        if hidden {
            self.numberRow1.isHidden = hidden
            self.numberRow2.isHidden = hidden
            self.numberRow3.isHidden = !hidden
            self.sepcialRow2.isHidden = !hidden
            self.specialRow1.isHidden = !hidden
            self.btnCaps.setTitle("123", for: .normal)
        } else {
            self.numberRow1.isHidden = hidden
            self.numberRow2.isHidden = hidden
            self.numberRow3.isHidden = hidden
            self.sepcialRow2.isHidden = !hidden
            self.specialRow1.isHidden = !hidden
            self.btnCaps.setTitle("#+=", for: .normal)
        }
    }
    
    @IBAction func dashPressed() {
    }
    
    @IBAction func deletePressed() {
        //delegate?.insertCharacter(cacheLetter)
    }
    
    @IBAction func spacePressed() {
        delegate?.insertCharacter(" ")
    }
}

// MARK: - Private Methods
private extension CustomKeyboardView {
    /*func addSignal(_ signal: MorseData.Signal) {
        if signalCache.count == 0 {
            // Have an empty cache
            signalCache.append(signal)
            delegate?.insertCharacter(cacheLetter)
        } else {
            // Building on existing letter
            signalCache.append(signal)
            delegate?.deleteCharacterBeforeCursor()
            delegate?.insertCharacter(cacheLetter)
        }
    }*/
}
