import Foundation

class FileUploader: NSObject {
    
    var file:NSURL
    let client:AFHTTPClient
    let path:String
    let key:String
    
    init(url:NSURL, path:String, file:NSURL, key:String) {
        client = AFHTTPClient(baseURL: url)
        self.file = file
        self.path = path
        self.key = key
    }
    
    func start(completion: () -> Void, progress: (progress:Float) -> Void ) {
        let request = client.multipartFormRequestWithMethod("POST", path: path, parameters: ["key": self.key]) { (data) -> Void in
            data.appendPartWithFileData(NSData(contentsOfURL: self.file), name: "video", fileName: "video", mimeType: "video/quicktime")
        }
        
        let operation = AFHTTPRequestOperation(request: request)
        operation.completionBlock = completion
        operation.setUploadProgressBlock { (written, totalWritten, expected) -> Void in
            progress(progress: Float(totalWritten)/Float(expected))
        }
        
        self.client.enqueueHTTPRequestOperation(operation)
        print("uploading video \(path)")
    }
}
