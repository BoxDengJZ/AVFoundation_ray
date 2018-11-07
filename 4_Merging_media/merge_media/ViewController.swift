
//
//  ViewController.swift
//  merge_media
//
//  Created by dengjiangzhou on 2018/8/20.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

import MobileCoreServices
import Photos
import MediaPlayer

class ViewController: UIViewController {

    
    @IBOutlet weak var videoTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var musicLabel: UILabel!
    
    
    var imagePicker: UIImagePickerController!
    var videoURLs = [URL]()
    var currentTableIndex = -1
    var HDVideoSize: CGSize{
        return self.view.bounds.size
    }
    
    var musicAsset: AVAsset?
    var previewURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK:- 第一个按钮
    @IBAction func addVideoClip(_ sender: UIButton) {
        guard activityIndicator.isAnimating == false else{
            return
        }
        
        refreshURL()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.videoQuality = .typeHigh
        present(imagePicker, animated: true)
    }
    
    
    
    // MARK:- 第二个按钮
    @IBAction func deleteVideoClip(_ sender: UIButton) {
        guard currentTableIndex != -1 , activityIndicator.isAnimating == false else {
            return
        }
        
        refreshURL()
        
        let theAlert = UIAlertController(title: "删除视频剪辑", message: "确定从合集中删除这个视频片段", preferredStyle: .alert)
        theAlert.addAction(UIAlertAction(title: "不了", style: .cancel))
        theAlert.addAction(UIAlertAction(title: "是啊", style: .destructive, handler: { (action: UIAlertAction) in
            self.videoURLs.remove(at: self.currentTableIndex)
            self.videoTable.reloadData()
            self.currentTableIndex = -1
            self.previewURL = nil
        }))
        present(theAlert, animated: true)
        
    }
    
    
    
    
    
    // MARK:- 第三个按钮
    @IBAction func addSoundtrack(_ sender: UIButton) {
        let mediaPickerController = MPMediaPickerController(mediaTypes: .anyAudio)
        mediaPickerController.delegate = self
        mediaPickerController.prompt = "选择音轨，用于视频合成"
        mediaPickerController.showsCloudItems = false
        mediaPickerController.allowsPickingMultipleItems = false
        present(mediaPickerController, animated: true)
    }
    
    
    
    // MARK:- 第四个按钮,  Composition Methods
    @IBAction func previewComposition(_ sender: UIButton) {
        guard videoURLs.count > 0 , activityIndicator.isAnimating == false else{
            return
        }
        var player: AVPlayer!
        defer {
            let playerViewController = AVPlayerViewController()
            playerViewController.allowsPictureInPicturePlayback = true
            playerViewController.player = player
            present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
        
        guard previewURL == nil else {
            
            //  if previewURL == nil,
            //  you will be creating the AVPlayer item from the composition.
            player = AVPlayer(url: previewURL!)
            return
        }
        
        //  get assets for video clips
        
        var videoAssets = [AVAsset]()
        for urlOne in videoURLs{
            let av_asset = AVAsset(url: urlOne)
            videoAssets.append(av_asset)
        }// Get assets for video clips
        
        // Create AVMutableComposition to hold AVMutableCompositionTrack instances.
        let composition = AVMutableComposition()
        
        // Create tracks from assets.
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        var startTime = kCMTimeZero
        
        //  iterates through the video assets array and
        //  inserted time range of media from each asset into both video and audio tracks.
        
        //
        let mainInstruction = AVMutableVideoCompositionInstruction()
        for asset in videoAssets{
            
            do{
                // Insert Video
                try videoTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: asset.tracks(withMediaType: .video)[0], at: startTime)
            }catch{
                print("插入合成视频轨迹， 视频有错误")
            }
            
            // Insert Audio
            if musicAsset == nil {
                do{
                    // Insert Audio
                    try audioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: asset.tracks(withMediaType: .audio)[0], at: startTime)
                }catch{
                    print("插入合成视频轨迹， 音频有错误")
                }
                //  The start time is updated,
                //  so that the next asset begins after the previous.
            }
            let instruction = videoCompositionInstructionForTrack(track: videoTrack!, asset: asset)
            instruction.setOpacity(1.0, at: startTime)
            mainInstruction.layerInstructions.append(instruction)
            startTime = CMTimeAdd(startTime, asset.duration)
            // The start time is updated ,
            //  so that the next asset begins after the previous
        }
        let totalDuration = startTime
        if musicAsset != nil {
            do{
                try audioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, totalDuration), of: musicAsset!.tracks(withMediaType: .audio)[0], at: kCMTimeZero)
            }
            catch{
                print("Error creating soundtrack total.")
            }
            //  This adds the audio from the musicAsset to the audio track for the entire duration of the composition.
        }
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration)
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [mainInstruction]
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderSize = HDVideoSize
        videoComposition.renderScale = 1.0
        
        //  https://stackoverflow.com/questions/32081057/how-to-convert-an-avmutablevideocomposition-to-an-avasset
        let playItem = AVPlayerItem(asset: composition)
        playItem.videoComposition = videoComposition
        player = AVPlayer(playerItem: playItem)
    }
    
    
    
    // MARK:- 第五个按钮
    @IBAction func mergeAndExportVideo(_ sender: UIButton) {
        guard videoURLs.count > 0 , activityIndicator.isAnimating == false else {
            return
        }
        
        let alertController = UIAlertController(title: "Merge and Export", message: "Merge and export video clips to photo library?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "NO", style: .cancel ))
        alertController.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { (action: UIAlertAction) in
            self.have_a_spin_mergeAndExportVideo()
        }))
        present(alertController, animated: true)
    }
    
    
    // MARK:- 添加了， 就不用原来导出的视频了
    func refreshURL() {
        
        guard videoURLs.count > 0  else{
            return
        }
        
        self.previewURL = nil
        
        
    }
    
    
    
    
    
    
    // MARK:- 合成视频  （ 音视频 ）
    // the merge and export process can take some time,
    private func have_a_spin_mergeAndExportVideo(){

        activityIndicator.isHidden = false
        
        //  start animating the activity indicator,
        //  to provide visual feedback that something ia happening.
        //  给用户反馈
        activityIndicator.startAnimating()
        
        //  把记录的 previewURL 置为 nil
        //  视频合成， 导出成功， 就赋新值
        previewURL = nil
        
        // 先创建资源 AVAsset
        var videoAssets = [AVAsset]()
        for url_piece in videoURLs{
            let av_asset = AVAsset(url: url_piece)
            videoAssets.append(av_asset)
        }
        // 创建合成的 AVMutableComposition 对象
        let composition = AVMutableComposition()
        //  创建 AVMutableComposition 对象的音轨
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        // 通过 AVMutableVideoCompositionInstruction ，调整合成轨迹的比例、位置、裁剪和透明度等属性。
        // AVMutableVideoCompositionInstruction 对象， 控制一组 layer 对象 AVMutableVideoCompositionLayerInstruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        var startTime = kCMTimeZero
        // iterating through the video assets to add content to the AVMutableComposition
        for asset in videoAssets{
            //  Insert Video

            //  instead of inserting segments of video . into a single video track
            //  this time , you are creaing video track for every video asset.
            
            // this is because the layer instructions are applied to an entire track.
            let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do{
                try videoTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: asset.tracks(withMediaType: .video)[0], at: startTime)
            }catch{
                print("Error creating Video track.")
            }
            
            // Insert Audio
            if musicAsset == nil {
                //  This code prevents audio from the video assets from being added to the audio track, effectively muting the sound from the video clips.

                
                do{
                    try audioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: asset.tracks(withMediaType: .audio)[0], at: startTime)
                }
                catch{
                    print("Error creating Audio track.")
                }
                
            }   //  if musicAsset == nil for asset in videoAssets{
            
            

            let instruction = videoCompositionInstructionForTrack(track: videoTrack!, asset: asset)
            instruction.setOpacity(1.0, at: startTime)
            if asset != videoAssets.last{
                instruction.setOpacity(0.0, at: CMTimeAdd(startTime, asset.duration))
                //  at the end of each video assets duration,
                //  the opacity is set to 0
                //  to prevent the track from displaying past in time.
                
                //  每一个视频片段结束， 都添加了过渡, 避免片段之间的干涉
                // other wise, the tracks would obscure each other.
                
            }
            mainInstruction.layerInstructions.append(instruction)
            // after adding our assets , one layerInstruction is created for
            // every video track to correct its orientation ,
            // using helper method videoCompositionInstructionForTrack
            
            
            // 这样， mainInstruction 就添加好了
            startTime = CMTimeAdd(startTime, asset.duration)
        }// for asset in videoAssets{
        
        let totalDuration = startTime
        if musicAsset != nil {
            do{
                try audioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, totalDuration), of: musicAsset!.tracks(withMediaType: .audio)[0], at: kCMTimeZero)
            }
            catch{
                print("Error creating soundtrack total.")
            }
            //  This adds the audio from the musicAsset to the audio track for the entire duration of the composition.
        }
        // sets the mainInstruction timeRange,
        //  to the total duration of all our video assets.
        
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration)
        
        
        //  an AVMutableVideoComposition , provides a description of
        //  how multiple video tracks
        //  are composited together at any point along the composition's timeline
        
        //  视频们如何合成
        
        // it also provides a way to configure
        //  its frame , duration, render size ,and scale
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [mainInstruction]
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderSize = HDVideoSize
        videoComposition.renderScale = 1.0
        
        
        // Export
        //  拿 composition ，创建 AVAssetExportSession
        let exporter: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        // 配置输出的 url
        exporter.outputURL = theURL
        // 设定输出格式， quick time movie file
        exporter.outputFileType = .mov
        //  optimizing it to play on the internet
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = videoComposition
        // start the export session
        //  开启会话， 建立连接
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                self.exportDidFinish_deng(session: exporter)
            }
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



// MARK:- Helper
extension ViewController{
    func addVideoURL(url: URL){
        videoURLs.append(url)
        videoTable.reloadData()
        previewURL = nil
    }
    
    //  which saves the video to the shared photo library
    //
    func exportDidFinish_deng(session: AVAssetExportSession){
        defer {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }

        
        guard session.status == .completed else{
            return
        }
        
        let outputURL = session.outputURL
        let photoLibrary = PHPhotoLibrary.shared()
        photoLibrary.performChanges({
             PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
        }, completionHandler: {
            (success: Bool , error: Error?)
            in
            var alertTitle: String!
            var alertMessage: String!
            if success{
                alertTitle = "好啦"
                alertMessage = "视频文件合成好啦"
                self.previewURL = session.outputURL
            }
            else{
                alertTitle = "🤪， 有错误"
                alertMessage = "视频文件合成出错"
                self.previewURL = nil
            }
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "明白了", style: .cancel))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        })
    }
    
    
    // Deng : Finish add
    // This creates a layer instruction from the passed  in track
    //  and grabs the video from the AVAsset
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction{
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: .video)[0]
        // here , you get the asset's preferredTransform
        //  and use it to determine if the video is portrait or landscape , using the helper method orientationFromTransform()
        let transfrom = assetTrack.preferredTransform
        let assetInfo = transfrom.orientationFromTransform()
        
        //  the scaleToFitRatio , is set to match a high definition video landscape orientation
        var scaleToFitRatio = HDVideoSize.width / assetTrack.naturalSize.width
        
        if assetInfo.isPortrait  {
            // Portrait
            
            //  change the scale to fit ratio to accommodate a high definition video portrait orientation
            
            scaleToFitRatio = HDVideoSize.height / assetTrack.naturalSize.width
            
            // then create a scale transform matrix
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)

            let concatTranform = assetTrack.preferredTransform.concatenating(scaleFactor)
            instruction.setTransform(concatTranform, at: kCMTimeZero)
            
            
        }
        else{
            // Landscape
            
            // rotate and scale if neccessary
            let scale_factor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            let scale_factor_two = CGAffineTransform(rotationAngle: .pi/2.0)
            let concat_transform = assetTrack.preferredTransform.concatenating(scale_factor).concatenating(scale_factor_two)
            instruction.setTransform(concat_transform, at: kCMTimeZero)

        }
        // 将处理好的 AVMutableVideoCompositionLayerInstruction 返回
        return instruction
    }
}



extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let theImagePath: URL = info["UIImagePickerControllerMediaURL"] as! URL
        print(info["UIImagePickerControllerPHAsset"] ?? "")
        addVideoURL(url: theImagePath)
        imagePicker.dismiss(animated: true)
        imagePicker = nil
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true)
        imagePicker = nil
    }
    
}




extension ViewController: MPMediaPickerControllerDelegate{
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        musicLabel.isHidden = false
        let selectedSong = mediaItemCollection.items
        if selectedSong.count > 0{
            let song = selectedSong[0]
            if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                musicAsset = AVAsset(url: url)
                musicLabel.text = song.value(forProperty: MPMediaItemPropertyTitle) as? String
            }
            else{
                musicLabel.text = "歌曲，不可用"
            }
        }
        mediaPicker.dismiss(animated: true)
    }
    
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        musicAsset = nil
        musicLabel.text = "加载音轨，未完成"
        musicLabel.isHidden = false
        mediaPicker.dismiss(animated: true)
    }
    
}



extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTableIndex = indexPath.row
    }
    
    
}



extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoURLs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoClipCell") as! VideoTableViewCell
        cell.clipName.text = "视频剪辑， \(indexPath.row + 1)"
        cell.clipThumbnail.image = videoURLs[indexPath.row].previewImageFromVideo()
        return cell
    }
    
    
}
