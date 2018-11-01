//
//  ViewController.swift
//  PenguinCam
//
//  Created by dengjiangzhou on 2018/6/20.
//  Copyright © 2018年 dengjiangzhou. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


class ViewController: UIViewController {

    
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var thumbnail: UIButton!
    @IBOutlet weak var flashLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var modePicker: UIPickerView!
    @IBOutlet weak var captureButton: UIButton!
    
    
    // 添加实例， adding some instances
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    // 切换 camera 前后用， 记录变量， 使用方便
    // 聚焦也有用到
    // 曝光
    
    let imageOutput = AVCapturePhotoOutput()
    
    
    let movieOutput = AVCaptureMovieFileOutput()
    let videoQueue = DispatchQueue.global(qos: .default)
    
    var focusMarker: UIImageView = UIImageView.imageViewWithImage(name: "Focus_Point")
    var exposureMarker: UIImageView = UIImageView.imageViewWithImage(name: "Exposure_Point")
    // exposure image 曝光 图像, 就是 提高照片的明亮度
    
    var resetMarker: UIImageView = UIImageView.imageViewWithImage(name: "Reset_Point")
    
    private var adjustingExposureContext: String = "Exposure"
    
    private let kExposure = "adjustingExposure"
    
    var modeData = ["Photo", "Video"]
    var captureMode: CaptureMode = CaptureMode.photo
    
    var outputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    var updateTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if setupSession(){
            setupPreview()
            startSession()
            setupCaptureMode(mode: .photo)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QuickLookSegue" {
            let quickLookController = segue.destination as! QuickLookViewController
            
            if let image = thumbnail.backgroundImage(for: .normal){
                quickLookController.photoImage = image
            }
            else{
                quickLookController.photoImage = UIImage(named: "bg")
            }
        }
    }
    
    // MARK: - Configure  ,  配置 拍照 ，前拍， 后拍
    // 之前， have got the back camera working,
    // let us add support for the front-facing camera.
    // take selfies
    @IBAction func switchCameras(_ sender: UIButton) {
        //   https://stackoverflow.com/questions/39894630/how-to-get-front-camera-back-camera-and-audio-with-avcapturedevicediscoverysess
        // 录视频中， 切摄像头，有点怪
        guard movieOutput.isRecording == false else{
            return
        }
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front), let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else{
            return;
        }

        // Create new input and update capture session.
        do{
            var input: AVCaptureDeviceInput?
            if activeInput.device == frontCamera{
                input = try AVCaptureDeviceInput(device: backCamera)
            }
            else{
                input = try AVCaptureDeviceInput(device: frontCamera)
            }
            captureSession.beginConfiguration()
            // Remove input for active camera.
            captureSession.removeInput(activeInput)
            // Add input for new camera.
            if captureSession.canAddInput(input!){
                captureSession.addInput(input!)
                activeInput = input
            }
            captureSession.commitConfiguration()
        }catch{
            print("Error , switching cameras: \(String(describing: error))")
        }

    }
    
    // MARK: - 手电筒  ,  配置 闪光灯
    
    @IBAction func onFlashOrTorchButton(_ sender: UIButton) {
        if captureMode == .photo {
           setFlashMode()
        }
        else{
            setTorchMode()
        }
    }
    
    func requestAuthorizationHander(_ status: PHAuthorizationStatus){
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func onCaptureButton(_ sender: UIButton) {
        switch captureMode {
        case .photo:
            capturePhoto()
            modePicker.isUserInteractionEnabled = true
            modePicker.alpha = 1
        case .movie:
            captureMovie()
            
        }
        
    }
    
    // MARK: - Capture photo
    // capture a still image.
   func capturePhoto() {
        guard PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized else{
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHander)
            return
        }
    
        // Next, a still image is captured from a sample buffer from the image output connection,
        let settings = AVCapturePhotoSettings(from: outputSetting)
        //      imageOutPut.isHighResolutionCaptureEnabled = true
        imageOutput.capturePhoto(with: settings, delegate: self)

    }// capturePhoto(_ sender: UIButton)
    
    
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}




extension ViewController{
    
    // MARK:- Set up Session and preview
    
    func setupSession() -> Bool{
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // sets the session preset.         This property enables you to customize the quality of the output.
        // The high preset is suitable for taking high resolution photos and video.
        // 高分辨率
        
        let camera = AVCaptureDevice.default(for: .video)
        // for the default camera, which is the back-facing camera. 不是自拍的。

        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            if captureSession.canAddInput(input){
                captureSession.addInput(input)
                activeInput = input
                
                // create an input object from the camera and add the input to the `captureSession`
                
            }
        } catch {
            print("Error srtting device input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: .audio)
        do{
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if captureSession.canAddInput(micInput){
                captureSession.addInput(micInput)
            }
        }catch{
            print("Error setting device audio input: \(String(describing: error.localizedDescription))")
            fatalError("DNG Mic")
            // 也不需要 return 
        }
        
        
        // set the image output to use jpeg compression, and add the output to the `captureSession`
        if captureSession.canAddOutput(imageOutput){
            captureSession.addOutput(imageOutput)
        }
        
        if captureSession.canAddOutput(movieOutput){
            captureSession.addOutput(movieOutput)
        }
        return true
    }
    
    
    // MARK: - Setup session preview
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // The preview Layer is initialized with the capture session.
        
        // AVCaptureVideoPreviewLayer is a subclass of CALayer that enables you to display video as it is being captured.
        // AVCaptureVideoPreviewLayer 是用于显示 捕捉的 视频流的

        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // The `videoGravity` determines how the video is displayed within the layer bounds.
        // We set it to preserve the video's aspect ratio, while filling the screen.
        
        camPreview.layer.addSublayer(previewLayer)
        
        // Attach tap recognizer for focus & exposure.
        let tapForFoucus = UITapGestureRecognizer(target: self, action: #selector(self.tapToFocus(recognizer:)))
        tapForFoucus.numberOfTapsRequired = 1
        camPreview.addGestureRecognizer(tapForFoucus)
        
        let tapForExposure = UITapGestureRecognizer(target: self, action: #selector(self.tapToExpose(recognizer:)))
        tapForExposure.numberOfTapsRequired = 2
        // 单指双击， `tapForExposure` is called , when tapping twice on the preview area,
        
        camPreview.addGestureRecognizer(tapForExposure)
        
        tapForFoucus.require(toFail: tapForExposure) // 这行代码 ， 好屌啊
        
        let tapForReset = UITapGestureRecognizer(target: self, action: #selector(self.resetFocusAndExposure))
        tapForReset.numberOfTapsRequired = 2
        //tap次数， 敲击次数
        tapForReset.numberOfTouchesRequired = 2
        //手指数
        camPreview.addGestureRecognizer(tapForReset)
        
        // Create marker views.
        camPreview.addSubview(focusMarker)
        camPreview.addSubview(exposureMarker)
        camPreview.addSubview(resetMarker)
    }
    
    
    // MARK: methods to manage the capture session.
    
    func startSession(){
        if !captureSession.isRunning{
            videoQueue.async {
                self.captureSession.startRunning()
                // Because this call can take some time, you will asynchronously enqueue this call to a global queue,
                // 异步加入， 线程队列
                // so you do not block the main thread. 不阻塞主线程
            }
        }
        // Check to see if the `captureSession` is not already running .
        // if not , then starts it running.
    }
    
    
    
    func stopSession(){
        if captureSession.isRunning{
            videoQueue.async {
                self.captureSession.stopRunning()
            }
        }
        // shutting down the session when it is no longer needed.
        
    }// does the opposite ( startSession )
    
    
    
    // MARK: Focus Methods
    @objc
    func tapToFocus(recognizer: UIGestureRecognizer){
        if activeInput.device.isFocusPointOfInterestSupported{
            let point = recognizer.location(in: camPreview)
            // The tap location is converted from the `GestureRecognizer` to the preview's coordinates.
            print("tapToFocus: \(point)")
            
            let pointOfInterest = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
            // Then an other conversion is made from the preview layer, to the coordinate space of the camera.
            
            
            showMarkerAtPoint(point: point, marker: focusMarker)
            focusAtPoint(pointOfInterest)
        }
    }
    
    
    // 照相机， 聚焦， 这个功能很强。
    
    func focusAtPoint(_ point: CGPoint){
        let device = activeInput.device
        // Make sure the device supports focus on POI and Auto Focus.
        // Point of Interest, 兴趣点
        
        // First , we grab the active inoput camera , and make sure that the focusing methods are supported,
        if device.isFocusPointOfInterestSupported , device.isFocusModeSupported(.autoFocus){
            do{
                // 专门处理， 锁机制
                // This allows exclusive access to the camera's hardware , preventing any background processes affecting focus in the middle of our request.

                try device.lockForConfiguration()
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
                device.unlockForConfiguration()
                // unlock the Configuration to focus
            }
            catch{
                print("Error focusing on POI: \(String(describing: error.localizedDescription))")
            }
        }
        // 自拍， 没有聚焦。
        // At this time, it is not supported on the front-facing camera.
    }
    
    // MARK: Exposure Methods
    @objc
    func tapToExpose(recognizer: UIGestureRecognizer){
        if activeInput.device.isExposurePointOfInterestSupported{
            let point = recognizer.location(in: camPreview)
            // The tap location is converted from the `GestureRecognizer` to the preview's coordinates.
            let pointOfInterest = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
            // Then , the second conversion is made for the coordinate space of the camera.

            showMarkerAtPoint(point: point, marker: exposureMarker)
            exposeAtPoint(pointOfInterest)
        }
    }
    
    
    
    func exposeAtPoint(_ point: CGPoint){
        let device = activeInput.device
        if device.isExposurePointOfInterestSupported, device.isFocusModeSupported(.continuousAutoFocus){
            do{
                try device.lockForConfiguration()
                device.exposurePointOfInterest = point
                device.exposureMode = .continuousAutoExposure
                if device.isFocusModeSupported(.locked){
                    
                    
                    //  Now let us add the illumination for the `observeValueForKeyPath` method,
                    //
                    
                    device.addObserver(self, forKeyPath: kExposure, options: .new, context: &adjustingExposureContext)

                    // 变化好了， 操作结束
                    // 状态变化的代码， 很强
                    device.unlockForConfiguration()
                    
                }
                
            }
            catch{
                print("Error Exposing on POI: \(String(describing: error.localizedDescription))")
            }
            
            
        }
        
    }
    
    // MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //  First , check to make sure that the context matches the adjusting exposure context,
        //  Otherwise, pass the observation on to super.
        
        if context == &adjustingExposureContext {
            let device = object as! AVCaptureDevice
            
            
            // then determine if the camera has stopped adjusting exposure , and if the locked mode is supported.
            
            if !device.isAdjustingExposure , device.isExposureModeSupported(.locked){
                
                
                // 一次性的回调方法， 设计很牛叉，
                // 观察属性，变化了， 一次性注入调用， 就销毁
                
                // remove self from the observer to stop subsequent notification,
                // 然后到主队列中异步配置
                device.removeObserver(self, forKeyPath: kExposure, context: &adjustingExposureContext)
                DispatchQueue.main.async {
                    do{
                        try device.lockForConfiguration()
                        device.exposureMode = .locked
                        device.unlockForConfiguration()
                    }
                    catch{
                        print("Error exposing on POI: \(String(describing: error.localizedDescription))")
                    }
                    
                }// DispatchQueue.main.async

            }// if !device.isAdjustingExposure , device.isExposureModeSupported(.locked)
            

        }// if context == &adjustingExposureContext {
        else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // MARK: Reset Focus and Exposure
    @objc
    func resetFocusAndExposure(){
        let device = activeInput.device
        let focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
        let exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
        
        let canResetFocus = device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode)
        let canResetExposure = device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode)
        
     //   let center = CGPoint(x: 0.5, y: 0.5)
        let sideWidth = previewLayer.bounds.size.width
        let sideHeight = previewLayer.bounds.size.height
        let center = CGPoint(x: 0.5 * sideWidth, y: 0.5 * sideHeight)
        print("\ncenter: \(center)\n")
        guard canResetFocus || canResetExposure else{
            fatalError("DNG， Reset")
        }
        let markerCenter = previewLayer.captureDevicePointConverted(fromLayerPoint: center)
        // showMarkerAtPoint(point: markerCenter, marker: resetMarker)
        // 被带到沟里了
        showMarkerAtPoint(point: center, marker: resetMarker)
        
        do {
            try device.lockForConfiguration()
            if canResetFocus{
                device.focusMode = focusMode
               // device.focusPointOfInterest = center
                device.focusPointOfInterest = markerCenter
            }
            if canResetExposure{
                device.exposureMode = exposureMode
               // device.exposurePointOfInterest = center
                device.exposurePointOfInterest = markerCenter
            }
            device.unlockForConfiguration()
        } catch {
            print("Error resetting focus & exposure: \(String(describing: error.localizedDescription))")
        }
        
    }
    
}



extension ViewController{
     // MARK: - Helpers
    func savePhotoToLibrary(image: UIImage) {
        let photoLibrary = PHPhotoLibrary.shared()
        
        let name = "DNG"
        var customAlbum = PHAssetCollection.findAlbum()
        if customAlbum == nil {
            
            // PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                // 这个方法， 不能单独调用，
                // 只能这么调用
            }, completionHandler: { (isV: Bool, error: Error?) in
                customAlbum = PHAssetCollection.findAlbum()
                
                print("Result: \(isV)")
                self.savePhotoToLibrary(image: image)
                return
                // 一次递归就好了
            })
            
            // customAlbum = PHAssetCollection.findAlbum()
        
        }
        else{
            photoLibrary.performChanges({
                let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetImage = result.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: customAlbum!)
                albumChangeRequest!.addAssets([assetImage!] as NSArray)
                
            }, completionHandler: { isSuccess, error in
                if isSuccess {
                    // Set thumbnail
                    self.toSetPhotoThumbnail(image: image)
                }
                else{
                    print("Error writing to photo library:  \(error!.localizedDescription)")
                }
            })// photoLibrary.performChanges
        }
    }
    
    
    
    func toSetPhotoThumbnail(image: UIImage) {
        DispatchQueue.main.async {
            self.thumbnail.contentMode = .scaleAspectFit
            self.thumbnail.setBackgroundImage(image, for: .normal)
            self.thumbnail.layer.borderColor = UIColor.white.cgColor
            self.thumbnail.layer.borderWidth = 1.0
        }
    }
    
    
    
    func showMarkerAtPoint(point: CGPoint, marker: UIImageView) {
        marker.center = point
        marker.isHidden = false
        
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
            marker.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0 )
        }, completion: {isYES in
            //  let delay = 0.5
            let popTime = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
                marker.isHidden = true
                marker.transform = .identity
            })
        })
        // The user interface is updated by adding a small icon momentarily to the tap location.
    }// func showMarkerAtPoint(point: CGPoint, marker: UIImageView)
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeLeft:
            orientation = .landscapeLeft
        case .portraitUpsideDown:
            orientation = .portraitUpsideDown
        default:
            orientation = .landscapeRight
        }
        return orientation
    }
}


extension ViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //  CMSampleBuffer: Core Media
        //  CVImageBuffer: Core Video
        
        if let imageData = photo.fileDataRepresentation(){
           
            // If the sample buffer contains data , it is then converted into a JPEG representaiton.
            
            let image = UIImage(data: imageData)
            // Then an UIImage is created , using the JPEG data
            // and it compiles it with the `penguinPhotoBomb`
            let photoBomb = image?.penguinPhotoBomb(image: image!)
            self.savePhotoToLibrary(image: photoBomb!)
            // Lastly , the composited photo is saved to the shared photo library.
        }
        else{
            print("Error capturing photo: \(String(describing: error?.localizedDescription))")
        }
    }
    
    
}

// https://stackoverflow.com/questions/46478262/taking-photo-with-custom-camera-ios-11-0-swift-4-update-error

// https://stackoverflow.com/questions/43059282/using-avcapturephotooutput-in-ios10-nsgenericexception


