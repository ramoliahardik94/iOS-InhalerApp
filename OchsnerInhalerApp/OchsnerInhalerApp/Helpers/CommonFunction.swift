//
//  File.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 25/01/22.
//

import UIKit
import Photos
import MBProgressHUD


open class CommonFunctions {
    
    // MARK: -  Alert
    
    public class func showMessage(message : String, _ completion: @escaping ((Bool?) -> Void ) = { _ in  })
    {
        let Alert = UIAlertController(title: (message), message: "", preferredStyle: UIAlertController.Style.alert)
        
        Alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            completion(true)
        }))
        UIApplication.topViewController()?.present(Alert, animated: true, completion: nil)
    }

    // MARK: -  Alert
    
    public class func showMessageYesNo(
        message : String,
        cancelTitle : String = "Cancel",
        okTitle : String = "Ok",
        _ completion: @escaping ((Bool?) -> Void ) = { _ in  }
    )
    {
        let Alert = UIAlertController(title: (message), message: "", preferredStyle: UIAlertController.Style.alert)
        
        Alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: { (action: UIAlertAction!) in
            completion(false)
        }))
        
        Alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (action: UIAlertAction!) in
            completion(true)
        }))
        UIApplication.topViewController()?.present(Alert, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: - Show Progress HUD
    
    class func showGlobalProgressHUD(_ viewcontroller: UIViewController) {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: viewcontroller.view, animated: true)
        }
    }
    class func hideGlobalProgressHUD(_ viewcontroller: UIViewController) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: viewcontroller.view, animated: true)
        }
    }

   
    
    class func removeUserDefaultForKey(_ key : String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func setUserDefaultObject(_ object : AnyObject, key : String) {
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()
        } catch {
            print(error.localizedDescription)
        }
      
    }
    
  
    
    class func getUserDefaultObjectForKey(key : String) -> AnyObject? {
        var retval : AnyObject! = nil;
        do {
            
            if let data: AnyObject =  UserDefaults.standard.object(forKey: key) as AnyObject? {
                retval = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as! Data) as AnyObject
            }
        } catch{
            print(error.localizedDescription)
        }
       
        return retval
    }
    
   
}

extension TimeZone {

    func offsetFromUTC() -> Int
    {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        return Int(localTimeZoneFormatter.string(from: Date())) ?? 0
    }
}



