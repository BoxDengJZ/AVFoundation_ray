//
//  ViewController_Video.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2018/8/1.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit
import Photos


extension ViewController{
    
    // MARK: - Movie Capture
    func captureMovie() {
        guard movieOutput.isRecording == false else {
            print("movieOutput.isRecording\n")
            stopRecording()
            modePicker.isUserInteractionEnabled = true
            modePicker.alpha = 1
            return;
        }
        modePicker.isUserInteractionEnabled = false
        modePicker.alpha = 0.6
        let connection = movieOutput.connection(with: .video)
        if (connection?.isVideoOrientationSupported)!{
            connection?.videoOrientation = currentVideoOrientation()
        }
        if (connection?.isVideoStabilizationSupported)!{
            connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
        }
        
        let device = activeInput.device

        //  On capable devices, you can enable a “smooth” focusing mode in which lens movements are made more slowly. This mode make focus transitions less visually intrusive, a behavior that you may want for video capture.
        if device.isSmoothAutoFocusSupported{
            do{
                try device.lockForConfiguration()
                device.isSmoothAutoFocusEnabled = false
                device.unlockForConfiguration()
            }catch{
                print("Error setting configuration: \(String(describing: error.localizedDescription))")
            }
        }// if device.isSmoothAutoFocusSupported
        let output = URL.tempURL
        movieOutput.startRecording(to: output!, recordingDelegate: self)
    }// func captureMovie()

    
    func stopRecording(){
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }

    func saveMovieToLibrary(movieURL: URL) {
        let photoLibrary = PHPhotoLibrary.shared()
        photoLibrary.performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieURL)
            
        }) { (isV: Bool, error: Error?) in
            if isV{
                // Set thumbnail
                self.setVideoThumbnailFrom(movieURL)
            }
            else{
                print("Error writing to movie library: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func setVideoThumbnailFrom(_ movieURL: URL){
        videoQueue.async {
            let asset = AVAsset(url: movieURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            do{
                let imageRef: CGImage = try imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
                let image = UIImage(cgImage: imageRef)
                self.toSetPhotoThumbnail(image: image)
                
            }catch{
                print("Error generating image: \(String(describing: error.localizedDescription))")
            }
            
        }// videoQueue.async 
    }
    
    func setupCaptureMode(mode: CaptureMode){
        captureMode = mode
        switch mode {
        case .photo:
            // Photo Mode
            setTorchMode(isCancelled: true)
            timeLabel.isHidden = true
        case .movie:
            // Video Mode
            setFlashMode(isCancelled: true)
            // 从操作管理完备（ 脱离他， 就远离他的一切 ） ...  至于图灵完备
            timeLabel.isHidden = false
        }
        
    }
    
    // MARK: Flash Modes (Still Photo), 闪光灯
    func setFlashMode(isCancelled: Bool = false) {
        let device = activeInput.device
        if device.isFlashAvailable{
            var currentMode = currentFlashOrTorchMode().mode
            currentMode += 1
            if currentMode > 2 || isCancelled == true{
                currentMode = 0
            }
            let new_mode = AVCaptureDevice.FlashMode(rawValue: currentMode)
            self.outputSetting.flashMode = new_mode!;
            flashLabel.text = currentFlashOrTorchMode().name
        }
    }
    
    // MARK: Torch Modes (Video)， 手电筒
    // AVFoundation handles the flash mode,
    // differently depending on the type of output.
    func setTorchMode(isCancelled: Bool = false) {
        let device = activeInput.device
        if device.hasTorch{
            var currentMode = currentFlashOrTorchMode().mode
            currentMode += 1
            if currentMode > 2 || isCancelled == true{
                currentMode = 0
            }
            let new_mode = AVCaptureDevice.TorchMode(rawValue: currentMode)
            if device.isTorchModeSupported(new_mode!){
                do{
                    try device.lockForConfiguration()
                    device.torchMode = new_mode!
                    device.unlockForConfiguration()
                    flashLabel.text = currentFlashOrTorchMode().name
                    
                }catch{
                    print("Error setting flash mode: \(String(describing: error.localizedDescription))")
                }
                
            }
            
        }
    }
    // When the output is a movie file，the flash stays on throughout the recording and is referred to as the torch.
    
    func currentFlashOrTorchMode() -> (mode: Int, name: String){
        var currentMode: Int = 0
        switch captureMode {
        case .photo:
            currentMode = outputSetting.flashMode.rawValue
        case .movie:
            currentMode = activeInput.device.torchMode.rawValue
        }
        // 这两个 mode , 分的 真他妈 的细致，
        // 瞬间的， 给 output 设置，
        // 持续时间的， 给设备
        
        
        var modeName: String!
        switch currentMode {
        case 0:
            modeName = "Off"
        case 1:
            modeName = "On"
        case 2:
            modeName = "Auto"
        default:
            modeName = "Off"
        }
        
        if !activeInput.device.hasFlash{
            modeName = "N/A"
        }
        return (currentMode, modeName)
    }
}

//MARK:- AVCaptureFileOutputRecordingDelegate

extension ViewController: AVCaptureFileOutputRecordingDelegate{
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        //  updates the UI, by changing the appearance of the capture button to reflect the camera is recording
        captureButton.setImage(UIImage(named: "Capture_Butt1"), for: .normal)
         // print(Thread.current)
        //  <NSThread: 0x1d4263380>{number = 1, name = main}
        // print(Thread.isMainThread)
        //  true

        startTimer()
    }
    
    
    // method fires while a recording has finished
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        //  outputFileURL， contains a reference to the temporary URL of the movie file
        if let error = error{
            print("Error, recording movie: \(String(describing: error.localizedDescription))")
        }
        else{
            // write video to library
            saveMovieToLibrary(movieURL: outputFileURL)
            captureButton.setImage(UIImage(named: "Capture_Butt"), for: .normal)
            stopTimer()
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modeData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = modeData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [.foregroundColor: UIColor.white])
        return myTitle
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setupCaptureMode(mode: CaptureMode(rawValue: row)!)
    }
}

// MARK:- Timer
extension ViewController{
    func startTimer(){
        if updateTimer != nil {
            updateTimer.invalidate()
        }
        
        updateTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(self.updateTimeDisplay), userInfo: nil, repeats: true)
        
         RunLoop.main.add(updateTimer, forMode: RunLoop.Mode.common)
         // RunLoop.main.add(updateTimer, forMode: .defaultRunLoopMode)
    }
    
    
    @objc func updateTimeDisplay(){
        let time = UInt(CMTimeGetSeconds(movieOutput.recordedDuration))
        
        print(time)
        timeLabel.text = time.formattedCurrentTime()
    }
    
    func stopTimer(){
        updateTimer.invalidate()
        updateTimer = nil
        // Update UI
        timeLabel.text = UInt(0).formattedCurrentTime()
    }
    
}
