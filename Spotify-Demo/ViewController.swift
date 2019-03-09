//
//  ViewController.swift
//  Spotify-Demo
//
//  Created by JOY JOSE on 28/02/19.
//  Copyright © 2019 Riverswave Technologies, India. All rights reserved.
//

import UIKit
import SafariServices
@_exported import AVFoundation

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
   var myplaylists = [SPTPartialPlaylist]()
    
    @IBOutlet var spotifyButton: UIButton!
    @IBOutlet var searchButtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      setup()
       
NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
        
    }
    func setup () {
        // insert redirect your url and client ID below
        let redirectURL = "Spotify-Demo://returnAfterLogin" // put your redirect URL here
        let clientID = "476c620368f349cc8be5b2a29b596eaf" // put your client ID here
        auth.redirectURL     = URL(string: redirectURL)
        auth.clientID        = "476c620368f349cc8be5b2a29b596eaf"
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
        
       searchButtn.alpha = 0
    }
    func initializaPlayer(authSession:SPTSession){
        if self.player == nil {
            
            
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
            
        }
        
    }
    
    @objc func updateAfterFirstLogin () {
        
        spotifyButton.isHidden = true
        searchButtn.alpha = 1
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
        //   initializaPlayer(authSession: session)
            self.spotifyButton.isHidden = true
            AuthService.instance.sessiontokenId = session.accessToken!
            print(AuthService.instance.sessiontokenId!)
            SPTUser.requestCurrentUser(withAccessToken: session.accessToken) { (error, data) in
                guard let user = data as? SPTUser else { print("Couldn't cast as SPTUser"); return }
                AuthService.instance.sessionuserId = user.canonicalUserName
                
                print(AuthService.instance.sessionuserId!)
                
            }
            // Method 1 : To get current user's playlist
            SPTPlaylistList.playlists(forUser: session.canonicalUsername, withAccessToken: session.accessToken, callback: { (error, response) in
                if let listPage = response as? SPTPlaylistList, let playlists = listPage.items as? [SPTPartialPlaylist] {
                    print(playlists)   // or however you want to parse these
                    //  self.myplaylists = playlists
                    self.myplaylists.append(contentsOf: playlists)
                    print(self.myplaylists)
                }
            })
            // Method 2 : To get current user's playlist
            let playListRequest = try! SPTPlaylistList.createRequestForGettingPlaylists(forUser: AuthService.instance.sessionuserId ?? "", withAccessToken: AuthService.instance.sessiontokenId ?? "")
            Alamofire.request(playListRequest)
                .response { response in
                    
                    
                    let list = try! SPTPlaylistList(from: response.data, with: response.response)
                    
                    for playList in list.items  {
                        if let playlist = playList as? SPTPartialPlaylist {
                            print( playlist.name! ) // playlist name
                            print( playlist.uri!)    // playlist uri
                            }}
            }
            
        }
        
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        SPTUser.requestCurrentUser(withAccessToken: session.accessToken) { (error, data) in
            guard let user = data as? SPTUser else { print("Couldn't cast as SPTUser"); return }
            AuthService.instance.sessionuserId = user.canonicalUserName
            print(AuthService.instance.sessionuserId!)
        }
        
//                self.player?.playSpotifyURI("spotify:track:60a0Rd6pjrkxjPbaKzXjfq", startingWith: 1, startingWithPosition: 8, callback: { (error) in
//                    if (error != nil) {
//                        print("playing!")
//                    }
//                })
                
                
}
        

    

    @IBAction func tableViewTapped(_ sender: Any) {
        
        //     UIApplication.shared.open(loginUrl!, options: nil, completionHandler: nil)
        
        if UIApplication.shared.openURL(loginUrl!) {
            
            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling
            }
        }

    }
  
    @IBAction func searchSpotifyBTapped(_ sender: Any) {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
                self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 140 , y: self.view.frame.size.height - 100, width: 280, height: 50))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
