import UIKit

class RecordngsTableView: UITableViewController {
    
    var recordings:[Recording] = []
    override func viewDidLoad() {
        loadRecordings()
    }
    func loadRecordings(){
        RKObjectManager.sharedManager().getObjectsAtPath("/recordings", parameters: nil, success: { (operation, result) -> Void in
            self.recordings = result.array() as! [Recording]
            self.tableView.reloadData()
            
            }) { (operation, error) -> Void in
                //TODO failure
        }
        
        
        
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
