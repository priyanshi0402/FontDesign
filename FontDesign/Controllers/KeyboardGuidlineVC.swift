//
//  KeyboardGuidlineVC.swift
//  FontDesign
//
//  Created by Netra Technosys on 2/12/21.
//

import UIKit
import AppLovinSDK

class KeyboardGuidlineVC: UIViewController, MAAdViewAdDelegate {
    
    @IBOutlet weak var bannerAdView: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnOpenSetting: UIButton!
    @IBOutlet weak var btnKeyboard: UIButton!
    
    var interstitialAd: MAInterstitialAd!
    var retryAttempt = 0.0
    var timer : Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnKeyboard.addCorner(value: 6.0)
        self.btnOpenSetting.addCorner(value: 22.0)
        self.btnDone.addCorner(value: 15.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupBannerAds()
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
        self.interstitialAd.show()
        self.timer.invalidate()
        self.timer = nil
    }
    
    func setupBannerAds() {
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
    
    @IBAction func btnOpenSettingClicked(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }

    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
    
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

