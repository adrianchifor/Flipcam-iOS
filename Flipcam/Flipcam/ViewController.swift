import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var activeIndicator: UIView!
    @IBOutlet weak var cameraPreview: PreviewView!
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

    }
    func updateProgress(){
        progressView.setProgress(calculateProgress(), animated: true)
    }
    func calculateProgress() -> Float{
        i++
        return Float(i%101)/100.0
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

