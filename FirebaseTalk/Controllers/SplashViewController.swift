//
//  SplashViewController.swift
//  FirebaseTalk
//
//  Created by PSJ on 2021/10/16.
//

import UIKit
import SnapKit
import Firebase

class SplashViewController: UIViewController {

    var box = UIImageView()
    var remoteConfig: RemoteConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            self.remoteConfig.activate { changed, error in
              // ...
            }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
          self.displayWelcome()
        }
        
        self.view.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
        box.image = UIImage(named: "loadingIcon")
    }

    func displayWelcome() {
        let color = remoteConfig["splash_background"].stringValue
        let caps = remoteConfig["splash_message_cap"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if(caps) {
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (action) in
                exit(0)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            self.present(loginVC, animated: false, completion: nil)
        }
        
        if let backColor: String = color {
            self.view.backgroundColor = UIColor(hex: backColor)
        }
    }
}
