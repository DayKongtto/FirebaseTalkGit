//
//  ChatModel.swift
//  FirebaseTalk
//
//  Created by PSJ on 2022/03/04.
//

import ObjectMapper

class ChatModel: Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    
    var users: [String: Bool] = [:]
    var comments: [String: Comments] = [:]
    
    class Comments: Mappable {
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
        }
        
        var uid: String?
        var message: String?
        
    }
}
