//
//  AudioVC.swift
//  Spotify-Demo
//
//  Created by JOY JOSE on 01/03/19.
//  Copyright © 2019 Riverswave Technologies, India. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AudioVC : UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
 
    var player = AVAudioPlayer()
    var image = UIImage()
    var mainSongTitle = String()
    var mainPreviewURL = String()
    var tryStrUri = String()
    @IBOutlet var playpausebtn: UIButton!
    @IBOutlet var background: UIImageView!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var songTitle: UILabel!
    
    override func viewDidLoad() {
      
        
        songTitle.text = mainSongTitle
        background.image = image
        mainImageView.image = image
        downloadFileFromURL(url: URL(string: mainPreviewURL)!)
      print(mainPreviewURL)
        playpausebtn.setTitle("Pause", for: .normal)
        
        
    }
    
    func downloadFileFromURL(url: URL){
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in

            self.play(url: customURL!)

        })

        downloadTask.resume()


    }

    func play(url: URL) {

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()

        }
        catch{
            print(error)
        }


    }
   
    @IBAction func pauseplay(_ sender: AnyObject) {
       
        if player.isPlaying {
            player.pause()
            playpausebtn.setTitle("Play", for: .normal)
        }
        else{
            player.play()
            playpausebtn.setTitle("Pause", for: .normal)
        }

    
}

}

