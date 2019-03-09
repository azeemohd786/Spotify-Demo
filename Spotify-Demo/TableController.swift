//
//  TableViewController.swift
//  Spotify-Demo
//
//  Created by JOY JOSE on 28/02/19.
//  Copyright © 2019 Riverswave Technologies, India. All rights reserved.
//

import UIKit
@_exported import Alamofire
import AVFoundation
import SVProgressHUD
var player = AVAudioPlayer()

struct post {
    let mainImage : UIImage!
    let name : String!
    let type : String!
    let struri : String!
  let previewURL : String?
}
class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchText: UITextField!
    var posts = [post]()
    var searchURL = String()
    typealias JSONStandard = [String : AnyObject]
    private var isSearchResults = Bool.self
    var searchResults = [[String : Any]]()
  
    @IBAction func playlistButtonTapped(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PlayVC") as! PlayVC
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "enableSearch")
     
        let keywords = searchText.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")


        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&type=track&&limit=5&access_token=\(AuthService.instance.tokenId ?? "")"
         self.view.endEditing(true)
        print(searchURL)
        SVProgressHUD.show()
        posts.removeAll()
        callAlamofire(url: searchURL)
         self.tableView.reloadData()
        self.showToast(message: "Please wait, it will take some time..")
        SVProgressHUD.dismiss()
       
     
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "enableSearch")
        callToken()
        SVProgressHUD.show()
        let defaultURL = "https://api.spotify.com/v1/search?q=Linkin+Park&type=track&limit=5&access_token=\(AuthService.instance.tokenId ?? "")"
        print(defaultURL)
        self.showToast(message: "Please wait, it will take some time..")
     callAlamofire(url: defaultURL)
     self.tableView.endUpdates()
     SVProgressHUD.dismiss()
       
        
    }
    
  
    
   
    func callAlamofire(url: String){
        Alamofire.request(url).responseJSON(completionHandler: {
            response in
           
            self.parseData(JSONData: response.data!)
        })
    }
    func parseData(JSONData : Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
           
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                 SVProgressHUD.show()
                if let items = tracks["items"] as? [JSONStandard] {
                    for i in 0..<items.count{
                        let item = items[i]
                        print(item)
                        let name = item["name"] as! String
                        let type = item["type"] as! String
                        let struri = item["uri"] as! String
                        print(struri)
                        
                       if let previewURL = item["preview_url"] as? String
                       {
                        if let album = item["album"] as? JSONStandard{
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let mainImageURL =  URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: mainImageData as! Data)
                                posts.append(post.init(mainImage: mainImage, name: name, type: type, struri: struri, previewURL: previewURL))
                                SVProgressHUD.dismiss()
                                self.tableView.reloadData()
                            }}}else {
                        SVProgressHUD.dismiss()
                        let alert = UIAlertController(title: "Spotify Limitations:", message: "Preview link not available enough, try some other artists.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                       self.present(alert, animated: true)
                        print("No Preview URL")
                        } }}
            }
        }
        catch{
             SVProgressHUD.dismiss()
            print(error)
        }
        
        
        
    }
    func callToken() {
        let parameters = ["client_id" : "476c620368f349cc8be5b2a29b596eaf",
                          "client_secret" : "05b8fd31242b4afc834dedbe03dd8b2d",
                          "grant_type" : "client_credentials"]
        Alamofire.request("https://accounts.spotify.com/api/token", method: .post, parameters: parameters).responseJSON(completionHandler: {
            response in
            print(response)
            print(response.result)
            print(response.result.value)
            if let result = response.result.value {
                let jsonData = result as! NSDictionary
                AuthService.instance.tokenId = jsonData.value(forKey: "access_token") as? String
                print(AuthService.instance.tokenId!)
                
                
            }
        })
       
    }
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let isSearchResults: Bool = UserDefaults.standard.bool(forKey: "enableSearch")
   return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        mainImageView.image = posts[indexPath.row].mainImage
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = posts[indexPath.row].name
      //  let typeLabel = cell?.viewWithTag(3) as! UILabel
      //  typeLabel.text = posts[indexPath.row].type
        return cell!
       
    }
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137.0;//Choose your custom row height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        
        let vc = segue.destination as! AudioVC
        
        vc.image = posts[indexPath!].mainImage
        vc.mainSongTitle = posts[indexPath!].name
        vc.tryStrUri = posts[indexPath!].struri
        vc.mainPreviewURL = posts[indexPath!].previewURL!
    }
    
   
}

