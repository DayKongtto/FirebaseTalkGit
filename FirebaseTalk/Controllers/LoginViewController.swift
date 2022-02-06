//
//  LoginViewController.swift
//  FirebaseTalk
//
//  Created by PSJ on 2021/10/17.
//

import UIKit
import SnapKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color : String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBar = UIView()
        
        let statusBarHeight = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.safeAreaInsets.top ?? 0
        
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(statusBarHeight)
        }
        
        color = remoteConfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        signupButton.backgroundColor = UIColor(hex: color)
        
        signupButton.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
    }
    
    @objc func presentSignup()
    {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        
        self.present(view, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
