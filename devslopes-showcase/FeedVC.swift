//
//  FeedVC.swift
//  devslopes-showcase
//
//  Created by macuser on 2/27/16.
//  Copyright © 2016 ResponseApps. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var txtAppDescription: MaterialTextField!
    
    var imgPicker: UIImagePickerController!
    
    @IBOutlet var imgSelector: UIImageView!
    
    var posts = [Post]()
    
    var imageSelected = false
    
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 380
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        //observe event type on path.  whenever changes on db, it will push a snapshot of the Value.
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                        
                        
                    }
                    
                }
                
            }
            
            self.tableView.reloadData()
        })
        
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        print("post description: \(post.postDescription)")
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, img:img)
            return cell
            
        } else {
            return PostCell()
        }
        
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150  
        } else {
            return tableView.estimatedRowHeight
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        imgSelector.image = image
        imageSelected = true
    }

    
    @IBAction func tapSelectImg(sender: UITapGestureRecognizer) {
        
        presentViewController(imgPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func btnPost(sender: AnyObject) {
        
        //imageshack api 12DJKPSU5fc3afbd01b1630cc718cae3043220f3
        
        if let txt = txtAppDescription.text where txt != "" {
            
            if let img = imgSelector.image where self.imageSelected {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string:urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                //1 - really compressed.  0 = not compressed.
                //this is data formal
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data:imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    //mimetype - type of data.  fileName - default.  will be rewritten by imageshack.
                    
                    multipartFormData.appendBodyPart(data:keyData, name: "key")
                    
                    multipartFormData.appendBodyPart(data:keyJSON, name: "format")
                    
                    }) { encodingResult in
                        
                        //called when upload is complete
                        //.success and .failure are from alamofire
                        
                        switch encodingResult {
                            
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { response in
                            
                                if let info = response.result.value as? Dictionary<String,AnyObject> {
                                
                                    if let links = info["links"] as? Dictionary<String,AnyObject> {
                                
                                        if let imageLink = links["image_link"] as? String {
                                
                                            print("LINK: \(imageLink)")
                                            self.postToFirebase(imageLink)
                                            
                                
                                        }
                                
                                    }
                                
                                }
                            
                            })
                            
                        case .Failure(let error):
                            
                            print(error)
                            break
                        default:
                            break
                        }
                        
                }
                
                
                
            } else {
                self.postToFirebase(nil)
            }
            
            
            
        }
        
    }
    
    func postToFirebase(imgUrl: String?) {
        
        var post: Dictionary<String, AnyObject> = [
        
            "description":self.txtAppDescription.text!,
            "likes":0
        ]
        
        if imgUrl != nil {
            post["image"]=imgUrl!
        }
        
        let firebasepost = DataService.ds.REF_POSTS.childByAutoId()
        firebasepost.setValue(post)
        
        txtAppDescription.text = ""
        imgSelector.image = UIImage(named: "camera")
        imageSelected = false
        tableView.reloadData()
        
    }
    
    
}
