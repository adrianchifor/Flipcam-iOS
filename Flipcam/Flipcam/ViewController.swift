import UIKit
import AVFoundation

private var myContext = 0


class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate{
    
    @IBOutlet weak var recordingsButton: UIButton!
    
    @IBOutlet weak var startTip: UILabel!
        @IBOutlet weak var triggerButton: UIButton!
    @IBOutlet weak var activeIndicator: UIView!
    @IBOutlet weak var cameraPreview: PreviewView!
    
    var participation:Participation?
    dynamic var currentSegment:Segment?
    dynamic var nextSegment:Segment?
    
    var tempFile:NSURL?
    var timer:NSTimer?
    
    let output = AVCaptureMovieFileOutput()
    var recording = false
    var waitingStart:NSTimeInterval?
    let session = AVCaptureSession()
    @IBOutlet weak var progressView: UIProgressView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addObserver(self, forKeyPath: "currentSegment", options: .New, context: &myContext)
        self.addObserver(self, forKeyPath: "nextSegment", options: .New, context: &myContext)
        setupActiveIndicator()
        startActiveIndicator()
        resetStatusUI()
        
        let camera = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)[0] as! AVCaptureDevice
        let mic = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio)[0] as! AVCaptureDevice
        let cameraInput = try! AVCaptureDeviceInput(device: camera)
        let micInput = try! AVCaptureDeviceInput(device: mic)
        session.beginConfiguration()
        session.addInput(cameraInput)
        session.addInput(micInput)

        cameraPreview.session = session
        let previewLayer = cameraPreview.layer as! AVCaptureVideoPreviewLayer
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        session.commitConfiguration()
        self.session.startRunning()
        
        session.sessionPreset = AVCaptureSessionPreset1280x720
        
        session.addOutput(output)
        let temp = NSTemporaryDirectory()
        
        tempFile = NSURL.fileURLWithPath(temp.stringByAppendingString("movie1.mov"))
        
        
        
        
        
        
        
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        
        
        if keyPath == "currentSegment" {
            resetStatusUI()
            if let current = currentSegment {
                let currentTimestamp = NSDate().timeIntervalSince1970 * 1000
                self.startRecordingCountdown()
                let nextTime = current.start + 1000
                dispatch_after(dispatchTimstamp(nextTime), dispatch_get_main_queue(), { () -> Void in
                    if(self.recording){
                        self.fetchNextSegment()
                        print("fetching next segment")
                    }else{
                        print("next segment not fetched because stop triggered")
                    }
                })
                dispatch_after(self.dispatchTimstamp(current.stop), dispatch_get_main_queue(), { () -> Void in
                    if self.currentSegment == current {

                        self.startWaitingCountdown()
                        if(self.nextSegment == nil){
                            //no more segments
                            self.output.stopRecording()
                            UIView.animateWithDuration(0.5) { () -> Void in
                                self.startTip.layer.opacity = 1
                            }
                            
                        }
                    }
                })
            }else if let next = nextSegment{
                
                self.startWaitingCountdown()
                
            }else{
            }
            
            
            
        }else if keyPath == "nextSegment"{
            if let next = nextSegment {
                let currentTimestamp = NSDate().timeIntervalSince1970 * 1000
                
                let switchTime = dispatch_time(UInt64(next.start), Int64(-0) * Int64(NSEC_PER_SEC))
                if(Double(switchTime) > currentTimestamp){
                    dispatch_after(dispatchTimstamp(Int(switchTime)), dispatch_get_main_queue(), { () -> Void in
                        let segment = self.nextSegment
                        self.nextSegment = nil
                        self.currentSegment = segment
                        
                    })
                }else{
                    print("next is after now!!!!!!!")
                    self.nextSegment = nil
                }
            }
            
        }else{
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    func dispatchTimstamp(let timestamp:Int) ->UInt64 {
        let delta = Int64((timestamp - Int(NSDate().timeIntervalSince1970) * 1000 )) * Int64(NSEC_PER_MSEC)
        return dispatch_time(DISPATCH_TIME_NOW, delta)
        
    }
    func fetchFirstSegment() {
        let currentTimestamp = Int(NSDate().timeIntervalSince1970) * 1000
        let readyTimestamp = currentTimestamp + 1000

        RKObjectManager.sharedManager().getObjectsAtPath("/api/v1/segment", parameters: ["key": self.participation!.key, "readyTimestamp": readyTimestamp], success: { (operation, result) -> Void in
            self.session.startRunning()
            let segment = (result.array()[0] as! Segment)
            self.startWaitingCountdown()
            dispatch_after(self.dispatchTimstamp(segment.start), dispatch_get_main_queue(), { () -> Void in
                self.currentSegment = segment
            })

            }) { (request, error) -> Void in
                
        }
    }
    
    func fetchNextSegment() {
        RKObjectManager.sharedManager().getObjectsAtPath("/api/v1/segment", parameters: ["key": self.participation!.key], success: { (operation, result) -> Void in
                        self.nextSegment = (result.array()[0] as! Segment)
//            let segment = Segment()
//            segment.stop = Int(NSDate().timeIntervalSince1970) * 1000 + 21000
//            segment.start = Int(NSDate().timeIntervalSince1970) * 1000 + 14000
//            self.nextSegment = segment
            }) { (request, error) -> Void in
                
        }
    }
    
    
    func startRecordingCountdown(){
        resetStatusUI()
        self.progressView.hidden = false
        self.activeIndicator.hidden = false

        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateRecordingProgress", userInfo: nil, repeats: true)
    }
    
    func resetStatusUI(){
        timer?.invalidate()
        self.activeIndicator.hidden = true
        self.progressView.hidden = true
    }
    
    func startWaitingCountdown(){
        resetStatusUI()
        self.waitingStart = NSDate().timeIntervalSince1970 * 1000
        self.progressView.hidden = false

        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateWaitingProgress", userInfo: nil, repeats: true)
    }
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        let url:NSURL = NSURL(string: "http://31.187.70.159:5000")!
        self.startTip.layer.opacity = 1
        resetStatusUI()
        self.startTip.text = "Uploading"
        FileUploader(url: url, path: "/api/v1/upload", file:outputFileURL, key: self.participation!.key).start({ () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.clearState()
                self.startTip.text = "Tap to start another recording!"
                print("uploaded")

            })

            }, progress: {(progress) -> Void in
                let progressString = String(format: "%.0f%%", arguments: [progress*100])
                self.startTip.text = "Uploading \(progressString)"
                
                
        })
        
        
    }
    func updateRecordingProgress(){
        progressView.setProgress(calculateProgress(self.currentSegment!), animated: false)
    }
    func updateWaitingProgress(){
        if let waitingStart = waitingStart {
            if let next = self.nextSegment {
                let current = NSDate().timeIntervalSince1970 * 1000
                let progress = min((Float( current - Double(waitingStart) ))/Float(next.start - Int(waitingStart)), 1.0)
                progressView.setProgress(progress, animated: false)
                
            }
        }
    }
    func calculateProgress(let segment:Segment) -> Float{
        let current = NSDate().timeIntervalSince1970 * 1000
        
        let progress = min((Float(Double(segment.stop) - current ))/Float(segment.stop - segment.start), 1.0)
        return progress
        
        
    }
    func clearState(){
        
        self.participation = nil
        self.nextSegment = nil
        self.currentSegment = nil

        
    }
    func setupActiveIndicator() {
        activeIndicator.layer.cornerRadius = activeIndicator.frame.width/2
        activeIndicator.layer.opacity = 0
    }
    @IBAction func previewTapped(sender: AnyObject) {
        if(recording){
            recording = false
            self.startTip.layer.opacity = 1
            self.startTip.text = "Stopping... just finish your part!"
            //stop
        }else if (self.currentSegment == nil && self.nextSegment == nil ){
            recording = true
            UIView.animateWithDuration(2) { () -> Void in
                self.startTip.layer.opacity = 0
            }
            self.output.startRecordingToOutputFileURL(self.tempFile!, recordingDelegate: self)
            RKObjectManager.sharedManager().getObjectsAtPath("/api/v1/session", parameters: ["lat": 0, "lng": 0, "startedRecording" : Int(NSDate().timeIntervalSince1970*1000)], success: { (operation, result) -> Void in
                self.participation = (result.array()[0] as! Participation)
                self.fetchFirstSegment()
                }) { (request, error) -> Void in
                    UIView.animateWithDuration(2) { () -> Void in
                        self.startTip.layer.opacity = 1
                    }
                    self.recording = false
            }
        }
        
    }
    
    func startActiveIndicator() {
        activeIndicator.layer.opacity = 0
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: [.Repeat, .Autoreverse], animations: { () -> Void in
            self.activeIndicator.layer.opacity = 1
            }) { (completed) -> Void in
                
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

