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
    var remoteConfig: RemoteConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        remoteConfig = RemoteConfig.remoteConfig()
        guard let remoteConfig = remoteConfig else { return }
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch { status, err -> Void in
          if status == .success {
            print("Config fetched!")
            self.remoteConfig?.activate { _, _ in
              // ...
            }
          } else {
            print("Config not fetched")
            print("Error: \(err?.localizedDescription ?? "No error available.")")
          }
          self.displayWelcome()
        }
        
        self.view.addSubview(box)
        box.snp.makeConstraints { make in
            make.center.equalTo(self.view)
        }
        box.image = UIImage(named: "loadingIcon")
    }

    func displayWelcome() {
        remoteConfig = RemoteConfig.remoteConfig()
        guard let remoteConfig = remoteConfig else { return }
        guard let color = remoteConfig.getBackGroundColor(remoteConfig) else { return }
        guard let caps = remoteConfig.getCaps(remoteConfig) else { return }
        guard let message = remoteConfig.getMessage(remoteConfig) else { return }
        
        if caps == true {
            let alert = UIAlertController(title: "공지사항",
                                          message: message,
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "확인",
                                          style: UIAlertAction.Style.default,
                                          handler: { _ in
                exit(0)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            if let loginVC = self.storyboard?
                .instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: false, completion: nil)
            }
        }
        
        self.view.backgroundColor = color
        
    }
}
