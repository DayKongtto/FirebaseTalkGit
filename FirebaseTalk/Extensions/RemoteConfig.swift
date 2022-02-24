//
//  RemoteConfig.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/02/13.
//

import Foundation
import UIKit
import Firebase

extension RemoteConfig {
    
    func getBackGroundColor(_ remoteConfig: RemoteConfig) -> UIColor? {
        guard let colorString: String = remoteConfig["splash_background"].stringValue else { return nil }
        let color: UIColor? = UIColor(hex: colorString)
        return color
    }
    
    func getCaps(_ remoteConfig: RemoteConfig) -> Bool? {
        let caps: Bool = remoteConfig["splash_message_cap"].boolValue
        return caps
    }
    
    func getMessage(_ remoteConfig: RemoteConfig) -> String? {
        guard let message = remoteConfig["splash_message"].stringValue else { return nil }
        return message
    }
}
