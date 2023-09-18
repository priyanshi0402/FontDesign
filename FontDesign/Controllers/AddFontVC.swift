//
//  AddFontVC.swift
//  FontDesign
//
//  Created by Netra Technosys on 24/11/21.
//

import UIKit
import Sketch
import AppLovinSDK

class AddFontVC: UIViewController {

    @IBOutlet weak var bannerAdView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var btnErase: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCheckDraw: UIButton!
    @IBOutlet weak var fontDrawCollectionview: UICollectionView!
    @IBOutlet weak var lblPAgeControll: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblAlphabet: UILabel!
    
    @IBOutlet weak var btnClose: UIButton!
    var alphabetsArray : [String] = []
    var selectedIndex = 0
    var fontArray : [FontData] = []
    var fontDataArray : [FontData] = []
    var isDrawed = false
    var isSaved = false
    var isDrawing = false
    
    var interstitialAd: MAInterstitialAd!
    var retryAttempt = 0.0
    var timer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.lblAlphabet.font = UIFont(name: "Helvetica Neue Bold", size: (screenSize.width - 90) / 2.26)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadBannerAds()
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
    
    func createInterstitialAd() {
        self.interstitialAd = MAInterstitialAd(adUnitIdentifier: interstitalID)
        self.interstitialAd.delegate = self
        self.interstitialAd.load()
    }
    
    @objc func updateCounter() {
        if !self.isDrawing {
            self.interstitialAd.show()
        }
        self.timer.invalidate()
        self.timer = nil
    }
    
    func loadBannerAds() {
        let adView = MAAdView(adUnitIdentifier: bannerID)
        adView.delegate = self
        let height = MAAdFormat.banner.adaptiveSize.height
        adView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: height)
        adView.setExtraParameterForKey("adaptive_banner", value: "true")
        adView.backgroundColor = .clear
        self.bannerAdView.addSubview(adView)
        adView.loadAd()
        
    }
    
    func setupView() {
        
        self.alphabetsArray =               ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
                                             "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
                                             "1","2","3","4","5","6","7","8","9","0",
                                             ".",",","?","\"","'","-","/",":",";",
                                             "(",")","$","&","@","!","|","+","*","%","^","<",">","#","€","£","{","}","~","=","[","]","\\","_"]
        
        self.lblPAgeControll.text = "1/\(self.alphabetsArray.count)"
        self.fontDataArray = dbHelper.showDataTodb() ?? []
        //self.setImageInImageView()
        self.btnCheckDraw.isEnabled = false
        self.btnCheckDraw.alpha = 0.8
        if self.fontDataArray.count == 0  {
            self.btnDone.isEnabled = false
        }
        
        self.shadowView.dropShadow(color: .lightGray, opacity: 1, offSet: .zero, scale: true)
        self.btnCheckDraw.addCorner(value: self.btnCheckDraw.frame.height/2)
        self.btnErase.addCorner(value: self.btnErase.frame.height/2)
        self.btnClose.addCorner(value: self.btnClose.frame.height/2)
        self.btnDone.addCorner(value: 8.0)
        self.lblPAgeControll.addCorner(value: 8.0)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.fontDrawCollectionview.delegate = self
        self.fontDrawCollectionview.dataSource = self
    }
    
    /// Get data from Database and show Drawed image in collectionView
    func setImageInCollectionImage(fontCell: FontDrawCollectionCell) {
        if self.fontDataArray.count > self.selectedIndex {
            let data = self.fontDataArray[self.selectedIndex]
            if data.alphabet == self.lblAlphabet.text {
                if let image = data.image {
                    if let url = URL(string: image) {
                        let image = UIImage(contentsOfFile: "\(url.path)")
                        fontCell.imageView.image = image
                    }
                }
                
            } else {
                fontCell.imageView.image = nil
            }
        } else {
            fontCell.imageView.image = nil
        }
    }
    
    func setFontDataInArray(drawView: UIView) {
        ///Get image from UIView
        if let image = drawView.asImage() {
            ///Remove white space surrounding  Image
            if image.trimmingTransparentPixels(maximumAlphaChannel: 1, char: Character("S")) != nil {
                
                let datefor = DateFormatter()
                datefor.dateFormat = "MM_yyyy_HH_mm_ss"
                datefor.timeZone = .current
                let gmtTime = datefor.string(from: Date())
                let documentsDirectory = getDirectoryPath()
                let fileURL = documentsDirectory?.appendingPathComponent("\(gmtTime)_\(self.selectedIndex).png")
                guard let fileURL = fileURL else {return}
                
                ///Convert image into png data
                if let pngData = UIImagePNGRepresentation(image) {
                    ///Save image in document directory
                    do {
                        try pngData.write(to: fileURL)
                        print(fileURL.absoluteString)
                        let dic : NSMutableDictionary = NSMutableDictionary()
                        dic.setValue("\(self.selectedIndex)", forKey: "font_index")
                        dic.setValue(self.alphabetsArray[self.selectedIndex], forKey: "alphabet")
                        dic.setValue(fileURL.absoluteString, forKey: "font_image")
                        let fontData = FontData(dic: dic)
                        self.fontArray.append(fontData)
                    } catch {
                        print("error")
                    }
                }
            }
            
        }
    }
  
    @IBAction func btnCheckDrawFont(_ sender: Any) {
        print("btnCheckDrawFont")
        
        self.btnDone.isEnabled = self.fontDataArray.count != 0
        if self.selectedIndex < self.alphabetsArray.count {
            
            self.isDrawed = true
            if self.btnCheckDraw.isEnabled {
                self.isSaved = true
            }
            if self.alphabetsArray[self.selectedIndex] == "\\" {
                self.btnCheckDraw.isHidden = true
                self.btnDone.isEnabled = true
            }
            
            let visibleRect = CGRect(origin: fontDrawCollectionview.contentOffset, size: fontDrawCollectionview.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            let visibleIndexPath = fontDrawCollectionview.indexPathForItem(at: visiblePoint)
            guard let visibleIndexPath = visibleIndexPath else {
                return
            }
            let fontCell = self.fontDrawCollectionview.cellForItem(at: visibleIndexPath)
            if let fontCell = fontCell as? FontDrawCollectionCell {
                self.setFontDataInArray(drawView: fontCell.drawView)
                self.setImageInCollectionImage(fontCell: fontCell)
            }
            
            self.selectedIndex += 1
            self.lblAlphabet.text = self.alphabetsArray[self.selectedIndex]
            //self.setImageInImageView()
            self.lblPAgeControll.text = "\(self.selectedIndex+1)/\(self.alphabetsArray.count)"
            self.collectionView.reloadData()
            
            DispatchQueue.main.async {
                self.btnCheckDraw.isEnabled = false
                self.btnCheckDraw.alpha = 0.8
                let indexPath = IndexPath(item: self.selectedIndex, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.fontDrawCollectionview.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        }
        
    }
    
    @IBAction func btnRedoClicked(_ sender: Any) {
        let visibleRect = CGRect(origin: self.fontDrawCollectionview.contentOffset, size: self.fontDrawCollectionview.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = fontDrawCollectionview.indexPathForItem(at: visiblePoint)
        guard let visibleIndexPath = visibleIndexPath else {
            return
        }
        let fontCell = self.fontDrawCollectionview.cellForItem(at: visibleIndexPath)
        if let fontCell = fontCell as? FontDrawCollectionCell {
            fontCell.drawView.redo()
            
        }
    }
    
    @IBAction func btnUndoClicked(_ sender: Any) {
        let visibleRect = CGRect(origin: self.fontDrawCollectionview.contentOffset, size: self.fontDrawCollectionview.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = self.fontDrawCollectionview.indexPathForItem(at: visiblePoint)
        guard let visibleIndexPath = visibleIndexPath else {
            return
        }
        
        let fontCell = self.fontDrawCollectionview.cellForItem(at: visibleIndexPath)
        if let fontCell = fontCell as? FontDrawCollectionCell{
            fontCell.drawView.undo()
        }
    }
    
    @IBAction func btnEraseClicked(_ sender: Any) {
        let visibleRect = CGRect(origin: self.fontDrawCollectionview.contentOffset, size: self.fontDrawCollectionview.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = self.fontDrawCollectionview.indexPathForItem(at: visiblePoint)
        guard let visibleIndexPath = visibleIndexPath else {
            return
        }
        
        let fontCell = self.fontDrawCollectionview.cellForItem(at: visibleIndexPath)
        if let fontCell = fontCell as? FontDrawCollectionCell {
            self.btnCheckDraw.isEnabled = false
            self.btnCheckDraw.alpha = 0.9
            if fontCell.imageView.image != nil {
                fontCell.imageView.image = nil
            }
            fontCell.drawView.clear()
        }
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        if self.isDrawed {
            let alert = UIAlertController(title: "Discard design?", message: "Do you want to discard your changes?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        
        if !self.isSaved && self.fontDataArray.count != 0 {
            let alert = UIAlertController(title: "Font Design", message: "Please submit your custom font by clicking Save.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let visibleRect = CGRect(origin: self.fontDrawCollectionview.contentOffset, size: self.fontDrawCollectionview.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            let visibleIndexPath = fontDrawCollectionview.indexPathForItem(at: visiblePoint)
            guard let visibleIndexPath = visibleIndexPath else {
                return
            }
            let fontCell = self.fontDrawCollectionview.cellForItem(at: visibleIndexPath)
            if let fontCell = fontCell as? FontDrawCollectionCell {
                            self.setFontDataInArray(drawView: fontCell.drawView)
            }
            for array in self.fontArray {
                dbHelper.insertDataToDb(index: array.index, image: array.image ?? "", alphbet: array.alphabet ?? "")
            }
            let fonTData = dbHelper.showDataTodb() ?? []
            
            do {
                let encodedData = try JSONEncoder().encode(fonTData)
                let defaults = UserDefaults(suiteName: groupID)
                defaults?.set(encodedData, forKey: "fonts")
                defaults?.synchronize()
            }catch{
                print("Error in Serialization")
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension AddFontVC: SketchViewDelegate {
    func drawView(_ view: SketchView, didEndDrawUsingTool tool: AnyObject) {
        self.btnCheckDraw.isEnabled = true
        self.btnCheckDraw.alpha = 1.0
        self.isDrawing = false
        //self.isDrawedView = true
        print("didEndDrawUsingTool")
    }
    
    func drawView(_ view: SketchView, willBeginDrawUsingTool tool: AnyObject) {
        self.isDrawing = true
        if !is_purchased_weekly {
            let alphabet = self.alphabetsArray[self.selectedIndex]
            if alphabet == "O" {
                self.btnDone.isEnabled = true
                let vc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        print("Alphabet\(self.alphabetsArray[self.selectedIndex])")
        print("willBeginDrawUsingTool")
    }
    
}

extension AddFontVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.alphabetsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlphabetCollectionCell", for: indexPath) as! AlphabetCollectionCell
            cell.lblAlpabet.text = self.alphabetsArray[indexPath.item]
            cell.viewCheck.addCorner(value: cell.viewCheck.frame.height/2)
            
            if self.fontDataArray.count == self.alphabetsArray.count {
                cell.viewCheck.isHidden = false
            } else {
                var isAdded = false
                if self.fontDataArray.first(where: {$0.alphabet == self.alphabetsArray[indexPath.row]}) != nil {
                    isAdded = true
                }
                cell.viewCheck.isHidden = !isAdded
            }
            cell.viewSelectedAlphabet.isHidden = self.selectedIndex != indexPath.row
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontDrawCollectionCell", for: indexPath) as! FontDrawCollectionCell
            self.setImageInCollectionImage(fontCell: cell)
            cell.drawView.tag = self.selectedIndex
            cell.drawView.lineWidth = 8.0
            cell.drawView.sketchViewDelegate = self
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            let width = (self.collectionView.frame.height)
            return CGSize(width: 50 , height: width)
        } else {
            return CGSize(width: collectionView.frame.width , height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if is_purchased_weekly {
            self.selectedIndex = indexPath.item
            self.lblAlphabet.text = self.alphabetsArray[indexPath.item]
            self.lblPAgeControll.text = "\(indexPath.item+1)/\(self.alphabetsArray.count)"
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.fontDrawCollectionview.scrollToItem(at: indexPath, at: .right, animated: false)
        } else {
            if self.fontDataArray.count > indexPath.row {
                self.selectedIndex = indexPath.item
                self.lblAlphabet.text = self.alphabetsArray[indexPath.item]
                self.lblPAgeControll.text = "\(indexPath.item+1)/\(self.alphabetsArray.count)"
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.fontDrawCollectionview.scrollToItem(at: indexPath, at: .right, animated: false)
            } else {
                let vc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        
//        if self.fontDataArray.count > indexPath.row {
//            let visibleRect = CGRect(origin: self.fontDrawCollectionview.contentOffset, size: fontDrawCollectionview.bounds.size)
//             if self.fontArray.first(where: {$0.alphabet == self.alphabetsArray[indexPath.row]}) != nil || self.fontDataArray.count != 0 {
//                self.btnCheckDraw.isEnabled = true
//                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//                 let visibleIndexPath = self.fontDrawCollectionview.indexPathForItem(at: visiblePoint)
//                guard let visibleIndexPath = visibleIndexPath else {
//                    return
//                }
//                let fontCell = self.fontDrawCollectionview.cellForItem(at: visibleIndexPath)
//                if let fontCell = fontCell as? FontDrawCollectionCell {
//                    self.setImageInCollectionImage(fontCell: fontCell)
//                }
//                self.selectedIndex = indexPath.item
//                self.lblAlphabet.text = self.alphabetsArray[indexPath.item]
//
//                self.lblPAgeControll.text = "\(indexPath.item+1)/\(self.alphabetsArray.count)"
//                self.collectionView.reloadData()
//                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//                self.fontDrawCollectionview.scrollToItem(at: indexPath, at: .right, animated: false)
//            }
//        }
        
    }
    
}

extension AddFontVC : MAAdViewAdDelegate {
    
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
