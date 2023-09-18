//
//  Constants.swift
//  FontDesign
//
//  Created by Netra Technosys on 24/11/21.
//

import Foundation
import UIKit

var screenSize : CGRect {
    return UIScreen.main.bounds
}

let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
let dbHelper = SQLiteHelper()
let groupID = "group.com.M9TR7KRYDY.keyboardApplication"
let bannerID = "11ff0ffbd587b959" //"ca-app-pub-5242051506085122~1620181773"
let interstitalID = "b29fd0dc10d09c0f"
let RewardedID = "fefe4a075704977b"

var fontsArray : [FontData]? {
    let defaults = UserDefaults(suiteName: groupID)
    defaults?.synchronize()
    if let fontData = defaults?.object(forKey: "fonts") as? Data,
       let fontData = try? JSONDecoder().decode([FontData].self, from: fontData) {
        return fontData
    }
    return nil
}

func getDirectoryPath() -> URL? {
    let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)
    return path
}

func checkReward() -> Bool {
//    return true
    let defaults = UserDefaults(suiteName: groupID)
    defaults?.synchronize()
    if let reward = defaults?.object(forKey: "get_reward") as? Bool {
        return reward
    }
    return false
}

func getRewardDate() -> String {
    
    let defaults = UserDefaults(suiteName: groupID)
    defaults?.synchronize()
    if let reward = defaults?.object(forKey: "reward_date") as? String {
        return reward
    }
    return ""
}

enum SelectedVC {
    case tryFont
    case drawLetter
    case guideVc
}

func convertDateToStrForReward(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy h:mm a"
    let myString = formatter.string(from: date)
    let yourDate = formatter.date(from: myString)
    formatter.dateFormat = "dd-MM-yyyy h:mm a"
    formatter.timeZone = TimeZone.current
    let myStringafd = formatter.string(from: yourDate!)
    return myStringafd
}

func convertStringToDateReward(str: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy h:mm a"
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.date(from: str)
}


func serverTimeReturn(completionHandler: @escaping (_ getResDate: String) -> Void){
    let url = URL(string: "http://www.google.com")
    let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        let httpResponse = response as? HTTPURLResponse
        if let contentType = httpResponse?.allHeaderFields["Date"] as? String {
            
            let dFormatter = DateFormatter()
            dFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            dFormatter.timeZone = TimeZone.current
            let serverTime = dFormatter.date(from: contentType)
            let strDate = convertDateToStrForReward(date: serverTime ?? Date())
            completionHandler(strDate)
        } else {
            completionHandler("")
        }
    }
    
    task.resume()
}
