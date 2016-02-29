//
//  PostCell.swift
//  devslopes-showcase
//
//  Created by macuser on 2/27/16.
//  Copyright © 2016 ResponseApps. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var imgLikes: UIImageView!
    @IBOutlet weak var profileImg:  UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var post: Post!
    var request: Request?
    var likeRef:Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        imgLikes.addGestureRecognizer(tap)
        
    }

    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
    }
    
    func configureCell(post: Post, img:UIImage?) {
        self.post = post
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        self.likeRef = DataService.ds.REF_USER_Current.childByAppendingPath("likes").childByAppendingPath(self.post.postKey)
        
        if post.imageUrl != nil {
            self.showcaseImg.hidden = false
            
            if img != nil {
                self.showcaseImg.image = img
            } else {
                
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                  
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                    
                })
            }
            
        } else {
            self.showcaseImg.hidden = true
        }
        
        
        
            likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
                if let doesNotExist = snapshot.value as? NSNull {
                    //firebase:  data that does not exist in .value is stored as NSNULL
                    //if we're here, we have not liked this post
                    
                    self.imgLikes.image = UIImage(named: "heart-empty")
                } else {
                    self.imgLikes.image = UIImage(named: "heart-full")
                }
                
            }
        )
        
        
    }
    
    func likeTapped(sender:UITapGestureRecognizer!) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                //firebase:  data that does not exist in .value is stored as NSNULL
                //if we're here, we have not liked this post
                
                self.imgLikes.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
                self.likeRef.setValue(true)
            } else {
                self.imgLikes.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
            
        })
    }
}
