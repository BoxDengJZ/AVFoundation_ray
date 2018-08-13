//
//  ViewController.swift
//  QuickPlay_new
//
//  Created by dengjiangzhou on 2018/6/18.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit

import AVFoundation


import AVKit


// add this import statement



class ViewController: UIViewController {
    
    
    @IBOutlet weak var videoTable: UITableView!
    
    
    
    var imagePicker: UIImagePickerController!
    var videoURLs = [URL]()
    var currentTableIndex = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    
    // 最左边
    @IBAction func addVideoClip(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = ["public.movie"]
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    // 左边 第二
    @IBAction func addRemoteStream(_ sender: UIButton) {
        let theAlertController = UIAlertController(title: "Add Remote Stream", message: "Enter URL for remote stream.", preferredStyle: .alert)
        
        theAlertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in }))
        theAlertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            let theTextField = theAlertController.textFields![0]
            self.addVideoURL(url: URL(string: theTextField.text!)!)
        }))
        
        theAlertController.addTextField { (textField) in
            textField.text = "https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
        }
        
        present(theAlertController, animated: true, completion: nil )
    }
    
    
    // 左边 第三
    @IBAction func deleteVideoClip(_ sender: UIButton) {
        guard currentTableIndex != -1 else {
            return
        }
        
        let theAlertController = UIAlertController(title: "Remove Clip", message: "Are you sure you want to remove this video clip from playlist?", preferredStyle: .alert)
            
        theAlertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in }))
        theAlertController.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { action in
            self.videoURLs.remove(at: self.currentTableIndex)
            self.videoTable.reloadData()
            self.currentTableIndex = -1
        }))

        present(theAlertController, animated: true, completion: nil)
        
    }
    
    
    
    // 靠近右边 第二
    // 全部部分， 从 列表的 开始 到 结尾
    @IBAction func playAllVideoClips(_ sender: UIButton) {
        guard videoURLs.count > 0 else {
            return
        }//   First make sure that ,
        //  there are some URLs in the array videoURLs.
        
        
        
        var queue = [AVPlayerItem]()
        for url in videoURLs {
            let videoClip = AVPlayerItem(url: url)
            queue.append(videoClip)
            
            
            //  AVPlayer item contains a lot more informattion about the video asset
            //  than just its location, such as its duration, timebase , and track information ,
            //  as well as properties to observe Reloading and playing back.
            
            
        }
        
        let queuePlayer = AVQueuePlayer(items: queue)
        //  AVQueuePlayer, subclass of AVPlayer .
        //  providing playback of multiple items in the sequence.
        
        // queuePlayer.allowsExternalPlayback = false
        
        
        queuePlayer.allowsExternalPlayback = true // 隔空 播放
        
        
        let playerViewController = AVPlayerViewController()
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.player = queuePlayer
        
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
        queue = []
    } // play all the video in a table , one after the other
    // 播放完了， 应该有 代理 方法， 推出 视频 播放 队列
    // This time it plays through the entire list of video clips.
    
    
    
    
    @IBAction func playVideoClip(_ sender: UIButton) {
        guard currentTableIndex != -1 else {
            return
        }   // First we make sure that a video is selected in the table , by checking current tableIndex
        
        
        
        
        let player = AVPlayer(url: videoURLs[currentTableIndex])
        
       // player.allowsExternalPlayback = false
        //  If you want to stream the video content to external devices like an Apple TV, this would be set to true.
        
        
        player.allowsExternalPlayback = true // AirPlay
        
        let playerViewController = AVPlayerViewController()
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
        } //  Notice that
        //  there is a closure here that starts the video playing
        //  once the controller is on the screen.
        
    }
    //  there is a full set of playback controls
    //  You can scrub through the video , 什么鬼
    //  , rewind    , 什么鬼
    //  , fast forward , play , pause , and change the aspect ratio to fill
    //  or fit the video to the screen.
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



// MARK: - Helpers
extension ViewController{
    func previewImageFromVideo(url: URL) -> UIImage?{
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
        
    }
    
    
    
    
    func addVideoURL(url: URL){
        videoURLs.append(url)
        videoTable.reloadData()
    }
    
    
}


// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        
        let theImagePath: URL = info[UIImagePickerControllerMediaURL] as! URL
        
        // public let UIImagePickerControllerReferenceURL: String // an NSURL that references an asset in the AssetsLibrary framework
        
        // public let UIImagePickerControllerPHAsset: String // a PHAsset
        
        
        addVideoURL(url: theImagePath)
        
        imagePicker.dismiss(animated: true) {        }
        imagePicker = nil
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: {})
        imagePicker = nil
    }
}




// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoURLs.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoClipCell") as! VideoTableViewCell
        cell.clipName.text = "Video Clip \(indexPath.row + 1)"
        print("\n\nurl: \(videoURLs[indexPath.row ])\n\n")
        
        if let previewImage = previewImageFromVideo(url: videoURLs[indexPath.row ] ){
            cell.clipThumbnail.image = previewImage
        }
        return cell
    }
    
    
}



// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate{
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTableIndex = indexPath.row
        
        // 在这里， 修改 与 控制
    }
}






// https://developer.apple.com/documentation/uikit/uiimagepickercontrollermediaurl?language=objc
