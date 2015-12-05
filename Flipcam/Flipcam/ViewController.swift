import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var activeIndicator: UIView!
    @IBOutlet weak var cameraPreview: PreviewView!
    var participation:Participation?
    var currentSegment:Segment?
    var nextSegment:Segment?
    
    var timer:NSTimer?
    var i = 0
    
    @IBOutlet weak var progressView: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActiveIndicator()
        startActiveIndicator()
        
        let session = AVCaptureSession()
        let device = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)[0] as! AVCaptureDevice
        let input = try! AVCaptureDeviceInput(device: device)
        session.beginConfiguration()
        session.addInput(input)
        cameraPreview.session = session
        let previewLayer = cameraPreview.layer as! AVCaptureVideoPreviewLayer
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        session.commitConfiguration()
        session.startRunning()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
        self.currentSegment = Segment()
        self.currentSegment!.stop = Int(NSDate().timeIntervalSince1970) + 5
        self.currentSegment!.start = Int(NSDate().timeIntervalSince1970)
        RKObjectManager.sharedManager().getObjectsAtPath("/api/v1/session", parameters: ["lat": 0, "lng": 0], success: { (operation, result) -> Void in
            self.participation = (result.array()[0] as! Participation)
            self.getNextSegment()
            }) { (request, error) -> Void in
                
        }

    }
    func getNextSegment() {
        RKObjectManager.sharedManager().getObjectsAtPath("/api/v1/segment", parameters: ["key": self.participation!.key], success: { (operation, result) -> Void in
            self.nextSegment = (result.array()[0] as! Segment)
            
            }) { (request, error) -> Void in
                
        }
    }
    func updateProgress(){
        progressView.setProgress(calculateProgress(self.currentSegment!), animated: true)
    }
    func calculateProgress(let segment:Segment) -> Float{
        let current = NSDate().timeIntervalSince1970
        let progress = min((Float(current - Double(segment.start)))/Float(segment.stop - segment.start), 1.0)
        return progress
    }
    func setupActiveIndicator() {
        activeIndicator.layer.cornerRadius = activeIndicator.frame.width/2
        activeIndicator.layer.opacity = 0
    }
    
    func startActiveIndicator() {
        activeIndicator.layer.opacity = 0
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: [.Repeat, .Autoreverse], animations: { () -> Void in
                self.activeIndicator.layer.opacity = 1
            }) { (completed) -> Void in

        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    


}

