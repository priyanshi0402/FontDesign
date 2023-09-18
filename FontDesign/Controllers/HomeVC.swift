//
//  HomeVC.swift
//  FontDesign
//
//  Created by Netra Technosys on 24/11/21.
//

import UIKit
import AppLovinSDK

class HomeVC: UIViewController {
    
    @IBOutlet weak var btnGetReward: UIButton!
    @IBOutlet weak var adsView: UIView!
    @IBOutlet weak var btnTryFont: UIButton!
    @IBOutlet weak var lblKeyboardEnable: UILabel!
    @IBOutlet weak var btnAddFont: UIButton!
    
    var customKeyboardView: CustomKeyboardView!
    var fontData: [FontData] = []
    var isFrom = ""
    var drawFontArray : [FontImage] = []
    
    var interstitialAd: MAInterstitialAd!
    var retryAttempt = 0.0
    var rewardedAd: MARewardedAd!
    var selectedVc : SelectedVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.setupView()
        self.clearDataFromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createBannerAd()
//        self.createInterstitialAd()
        self.createRewardedAd()
    }
    
    func createInterstitialAd() {
        self.interstitialAd = MAInterstitialAd(adUnitIdentifier: interstitalID)
        self.interstitialAd.delegate = self
        self.interstitialAd.load()
    }
    
    func createRewardedAd() {
        self.rewardedAd = MARewardedAd.shared(withAdUnitIdentifier: RewardedID)
        self.rewardedAd.delegate = self
        // Load the first ad
        self.rewardedAd.load()
    }
    
    func createBannerAd() {
        let adView = MAAdView(adUnitIdentifier: bannerID)
        adView.delegate = self
        // Get the adaptive banner height.
        let height: CGFloat = MAAdFormat.banner.adaptiveSize.height
        adView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: height)
        adView.setExtraParameterForKey("adaptive_banner", value: "true")
        // Set background or background color for banners to be fully functional
        adView.backgroundColor = .clear
        self.adsView.addSubview(adView)
        adView.loadAd()
    }
    
    func setupView() {
        //self.btnAddFont.addCorner(value: self.btnAddFont.frame.height / 2)
        let nib = UINib(nibName: "CustomKeyboardView", bundle: nil)
        let objects = nib.instantiate(withOwner: nil, options: nil)
        self.customKeyboardView = objects.first as? CustomKeyboardView
        // Add KVO for textfield to determine when cursor moves
        self.lblKeyboardEnable.addCorner(value: 12.0)
        self.btnTryFont.addCorner(value: 10.0)
        self.btnGetReward.addCorner(value: 10.0)
        self.btnAddFont.addCorner(value: 10.0)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.lblTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.lblKeyboardEnable.isUserInteractionEnabled = true
        self.lblKeyboardEnable.addGestureRecognizer(tapGesture)
        self.customKeyboardView.setNextKeyboardVisible(false)
        
    }
    
    func clearDataFromDB() {
        if !is_purchased_weekly {
            let vc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            if (dbHelper.showDataTodb() ?? []).count > 14 {
                for data in dbHelper.showDataTodb() ?? [] {
                    dbHelper.delteDataFromDb(alphabet: data.index)
                }
            }
        }
        
    }
    
    func setUpimageInArray() {
        
        if let array = fontsArray {
            self.drawFontArray.removeAll()
            for data in array {
                if let imageURL = data.image {
                    if let url = URL(string: imageURL) {
                        let image = UIImage(contentsOfFile: "\(url.path)")
                        let char = Character(data.alphabet ?? "")
                        
                        if let trimmedImage = image?.trimmingTransparentPixels(maximumAlphaChannel: 1, char: char) {
                            if let resizeImage = trimmedImage.resizeImageWithQuality(targetSize: CGSize(width: 20, height: 20), isUppercased: char.isUppercase) {
                                
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.fontData = dbHelper.showDataTodb() ?? []
        self.setUpimageInArray()
    }

    @objc func lblTapGesture(_ gesture: UITapGestureRecognizer) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "KeyboardGuidlineVC") as! KeyboardGuidlineVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnGetRewardClicked(_ sender: Any) {

        if self.rewardedAd.isReady {
            self.rewardedAd.show()
        }
    }
    
    @IBAction func btnTryFontClicked(_ sender: Any) {
//        self.selectedVc = .tryFont
//        if self.interstitialAd.isReady {
//            self.interstitialAd.show()
//        }
        let vc = storyBoard.instantiateViewController(withIdentifier: "FontPreviewVC") as! FontPreviewVC
        vc.drawFontArray = self.drawFontArray
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func btnSubscriptionClicked(_ sender: Any) {
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnAddFontClicked(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "AddFontVC") as! AddFontVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
//        self.selectedVc = .drawLetter
//        if self.interstitialAd.isReady {
//            self.interstitialAd.show()
//        }
        
    }
    
}

extension HomeVC : MAAdViewAdDelegate, MAAdDelegate, MARewardedAdDelegate {
    
    func didDisplay(_ ad: MAAd) {
        
    }
    
    func didHide(_ ad: MAAd) {
//        self.createInterstitialAd()
        print("Did hide")
    }
    
    func didLoad(_ ad: MAAd) {
        
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        
    }
    
    func didClick(_ ad: MAAd) {
        
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        
    }
    
    func didExpand(_ ad: MAAd) {
        
    }
    
    func didCollapse(_ ad: MAAd) {
        
    }
    
    //MARK: - Rewarded Delegate
    
    func didStartRewardedVideo(for ad: MAAd) {
        
    }
    
    func didCompleteRewardedVideo(for ad: MAAd) {
        
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        let alert = UIAlertController(title: "Font design", message: "didRewardUser", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        let defaults = UserDefaults(suiteName: groupID)
        defaults?.set(true, forKey: "get_reward")
        defaults?.set(convertDateToStrForReward(date: Date()), forKey: "reward_date")
        defaults?.synchronize()
        setWeeklyPurchased(bool: true)
    }
}
