//
//  SubscriptionVC.swift
//  FontDesign
//
//  Created by Netra Technosys on 24/11/21.
//

import UIKit
import JGProgressHUD
import Ripples

class SubscriptionVC: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var rippleView: UIView!
    @IBOutlet weak var btnFreetrail: UIButton!
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var viewDetails: UIView!
    
    var isFromGif = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupRipple()
    }
    
    func setupView() {
        self.viewDetails.addCorner(value: 18.0)
        self.btnFreetrail.addCorner(value: 12.0)
        self.btnSubscribe.addCorner(value: 18.0)
        
        if is_purchased_weekly {
            self.btnSubscribe.setTitle("Subscribed".uppercased(), for: .normal)
            self.btnSubscribe.isEnabled = false
            self.btnSubscribe.alpha = 0.8
        } else {
            self.btnSubscribe.setTitle("Subscribe".uppercased(), for: .normal)
            self.btnSubscribe.isEnabled = true
            self.btnSubscribe.alpha = 1.0
        }
        //self.checkIAPStatus()
    }
    
    let ripple = Ripples()
    let sRippleView = UIView()
    
    func setupRipple() {
        
        self.sRippleView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 320)
        self.ripple.radius = 170
        self.ripple.animationDuration = 3.0
        self.ripple.keyTimeForHalfOpacity = 0.7
        self.ripple.backgroundColor = UIColor(red: 220/255, green: 201/255, blue: 182/255, alpha: 1.0).cgColor
        self.ripple.rippleCount = 10
        self.ripple.position = self.sRippleView.center
        self.sRippleView.layer.addSublayer(self.ripple)
        
        self.rippleView.addSubview(self.sRippleView)
        self.rippleView.bringSubview(toFront: self.imgView)
        DispatchQueue.main.async {
            self.ripple.start()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.ripple.position = self.sRippleView.center
    }
    
    func checkIAPStatus() {
        IAPHelper.checkPurchaseStatus(productId: weekly_id) { errorStr, expiryDate, isSuccess in
            if isSuccess, let eDate = expiryDate {
                if isSuccess {
                    setWeeklyPurchased(bool: true)
                    setIAPStartDate(date: Date())
                    setIAPExpiryDate(date: eDate)
                    
                    self.btnSubscribe.setTitle("Subscribed".uppercased(), for: .normal)
                    self.btnSubscribe.isEnabled = false
                    self.btnSubscribe.alpha = 0.8
                } else {
                    print(errorStr ?? "")
                    setWeeklyPurchased(bool: false)
                    self.btnSubscribe.setTitle("Subscribe".uppercased(), for: .normal)
                    self.btnSubscribe.isEnabled = true
                    self.btnSubscribe.alpha = 1.0
                }
            } else {
                print(errorStr ?? "")
                self.openAlert(msg: errorStr ?? "")
                setWeeklyPurchased(bool: false)
                self.btnSubscribe.setTitle("Subscribe".uppercased(), for: .normal)
                self.btnSubscribe.isEnabled = true
                self.btnSubscribe.alpha = 1.0
            }
        }
    }
    
    @IBAction func btnRestoreClicked(_ sender: Any) {
        let hud = JGProgressHUD()
        hud.show(in: self.view)
        
        IAPHelper.restorePurchase { errorStr, productId, expiryDate, isSuccess in
            hud.dismiss()
            if isSuccess, let eDate = expiryDate, let pId = productId {
                let defaults = UserDefaults(suiteName: groupID)
                defaults?.set(false, forKey: "get_reward")
                defaults?.synchronize()
                setWeeklyPurchased(bool: true)
                setIAPStartDate(date: Date())
                setIAPExpiryDate(date: eDate)
                self.openAlert(msg: "You have successfully restored to the Weekly.")
            } else {
                setWeeklyPurchased(bool: false)
                self.openAlert(msg: errorStr ?? "")
            }
        }
    }
    
    @IBAction func btnSubscribeClicked(_ sender: Any) {
        let hud = JGProgressHUD()
        hud.show(in: self.view)
        
        IAPHelper.doSubscription(productId: weekly_id) { errorStr, purchaseDetail, isSuccess in
            if isSuccess {
                IAPHelper.checkPurchaseStatus(productId: weekly_id) { errorStr, expiryDate, isSuccess in
                    hud.dismiss()
                    if isSuccess, let eDate = expiryDate {
                        if isSuccess {
                            
                            let defaults = UserDefaults(suiteName: groupID)
                            defaults?.set(false, forKey: "get_reward")
                            defaults?.synchronize()
                            
                            setWeeklyPurchased(bool: true)
                            setIAPStartDate(date: Date())
                            setIAPExpiryDate(date: eDate)
                            self.btnSubscribe.setTitle("Subscribed".uppercased(), for: .normal)
                            self.btnSubscribe.isEnabled = false
                            self.btnSubscribe.alpha = 0.8
                            let alert = UIAlertController(title: appName, message: "Congrats! You have successfully subscribed to the Weekly subscription.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            self.openAlert(msg: errorStr ?? "")
                        }
                    } else {
                        self.openAlert(msg: errorStr ?? "")
                    }
                }
            } else {
                hud.dismiss()
                self.openAlert(msg: errorStr ?? "")
            }
        }
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        if self.isFromGif {
            let vc = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func openAlert(msg: String) {
        let alert = UIAlertController(title: appName, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func OpenTerms(sender: AnyObject) {
        let myUrl = "https://appswim.com/terms/"
        if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func OpenPrivacy(sender: AnyObject) {
        let myUrl = "https://appswim.com/privacy/"
        if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}
