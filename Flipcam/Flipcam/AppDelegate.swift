
import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let host = "http://31.187.70.159:5000"
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        setupMappings()

        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func setupMappings() {
        
        let manager =  RKObjectManager(baseURL: NSURL(string: self.host))
        RKObjectManager.setSharedManager(manager)
        setupParticipant(manager)
        setupSegment(manager)
        setupRecording(manager)
        
        
    }
    
    func setupParticipant(manager:RKObjectManager){
        let mapping = RKObjectMapping(forClass: Participation.self)
        mapping.addAttributeMappingsFromDictionary(["key": "key"])
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method: .GET, pathPattern: "/api/v1/session", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        manager.addResponseDescriptor(responseDescriptor)

    }
    func setupSegment(manager:RKObjectManager){
        let mapping = RKObjectMapping(forClass: Segment.self)
        mapping.addAttributeMappingsFromDictionary(["startTimestamp": "start",
                                                    "stopTimestamp": "stop"])
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method: .GET, pathPattern: "/api/v1/segment", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        manager.addResponseDescriptor(responseDescriptor)
    }
    func setupRecording(manager:RKObjectManager){
        let mapping = RKObjectMapping(forClass: Recording.self)
        mapping.addAttributeMappingsFromDictionary(["videoUrl": "video",
            "created": "created"])
        let responseDescriptor = RKResponseDescriptor(mapping: mapping, method: .GET, pathPattern: "/api/v1/recordings", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        manager.addResponseDescriptor(responseDescriptor)
    }
}

