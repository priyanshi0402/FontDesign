//
//  AddFontVC.swift
//  FontDesign
//
//  Created by Netra Technosys on 21/01/22.
//

import UIKit
import SwiftyGif

class AppGuideVC: UIViewController {
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
    }
    
    func setupData() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UserDefaults.standard.set(true, forKey: "isOpen")
        do {
            
            let gif = try UIImage(gifName: bottomSafeArea == 0 ? "draw_iPhone8_plus.gif" : "draw_iPhone11.gif")
            self.imageView.delegate = self
            self.imageView.setGifImage(gif)
            self.imageView.tag = 101
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func btnNextClicked(_ sender: UIButton) {
        if self.imageView.tag == 102 {
            let vc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
            vc.modalPresentationStyle = .fullScreen
            vc.isFromGif = true
            self.present(vc, animated: false, completion: nil)
            return
        }
        
        do {
            let gif = try UIImage(gifName: bottomSafeArea == 0 ? "type_iPhone8_plus.gif" : "type_iPhone11.gif")
            self.imageView.delegate = self
            self.imageView.tag = 102
            self.imageView.setGifImage(gif)
            
        } catch {
            print(error)
        }
    }
    
    var topSafeArea : CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20
        } else {
            return UIApplication.shared.keyWindow?.rootViewController?.topLayoutGuide.length ?? 20
        }
    }

    var bottomSafeArea : CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 20
        } else {
            return UIApplication.shared.keyWindow?.rootViewController?.bottomLayoutGuide.length ?? 20
        }
    }

}

extension AppGuideVC : SwiftyGifDelegate {

    func gifURLDidFinish(sender: UIImageView) {
        print("gifURLDidFinish")
    }

    func gifURLDidFail(sender: UIImageView) {
        print("gifURLDidFail")
    }

    func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
    
    func gifDidLoop(sender: UIImageView) {
        print("gifDidLoop")
    }
    
    func gifDidStop(sender: UIImageView) {
        print("sender.tag\(sender.tag)")
        print("gifDidStop")
    }
}
