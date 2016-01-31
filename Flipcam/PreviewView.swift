import AVFoundation
import UIKit

class PreviewView: UIView {
    
    var session:AVCaptureSession? {
        
        get {
            let prevLayer = layer as! AVCaptureVideoPreviewLayer
            return prevLayer.session
        }
        set {
            let prevLayer = layer as! AVCaptureVideoPreviewLayer
            prevLayer.session = newValue
        }
    }
    
    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
