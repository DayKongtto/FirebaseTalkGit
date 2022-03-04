//
//  ChatViewController.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/03/04.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var sendButton: UIButton?
    
    public var destinationUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendButton?.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }
    
    @objc func createRoom() {
        print(destinationUid)
        let createRoomInfo = [
            "uid": Auth.auth().currentUser?.uid,
            "destinationUid": destinationUid
        ]
        
        Database.database().reference().child("chatRooms").childByAutoId().setValue(createRoomInfo)
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
