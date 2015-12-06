import UIKit

class RecordngsTableView: UITableViewController {
    
    var recordings:[Recording] = []
    override func viewDidLoad() {
        loadRecordings()
    }
    func loadRecordings(){
        RKObjectManager.sharedManager().getObjectsAtPath("/api/v1/recordings", parameters: nil, success: { (operation, result) -> Void in
            self.recordings = result.array() as! [Recording]
            self.tableView.reloadData()
            
            }) { (operation, error) -> Void in
                //TODO failure
        }
        
        
    }
    @IBAction func refreshPressed(sender: AnyObject) {
        self.loadRecordings()
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let recording = recordings[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: recording.video)!)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let recording = recordings[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let date = NSDate(timeIntervalSince1970: Double(recording.created/1000))
        cell.textLabel!.text = date.timeAgo()
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordings.count
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
