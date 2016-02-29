//
//  Post.swift
//  devslopes-showcase
//
//  Created by macuser on 2/27/16.
//  Copyright © 2016 ResponseApps. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDescription:String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef:Firebase!
    
    var postDescription:String {
        return _postDescription
    }
    
    var imageUrl:String? {
        return _imageUrl
    }
    
    var likes:Int {
        return _likes
    }
    
    var username:String {
        return _username
    }
    
    var postKey:String {
        return _postKey
    }
    
    init(description: String, imageUrl: String?, username: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        //parse firebase data into something useful
        
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }

        if let imgUrl = dictionary["image"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            self._likes = self._likes + 1
        } else {
            self._likes = self._likes - 1
        }
        
        _postRef.childByAppendingPath("likes").setValue(self._likes)
        
    }
    
    
}