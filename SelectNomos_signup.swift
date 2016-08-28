import UIKit

class SelectNomos_signup: UITableViewController {
    var NOMOI = ["ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ", "ΑΡΓΟΛΙΔΑΣ", "ΑΡΚΑΔΙΑΣ", "ΑΡΤΑΣ", "ΑΤΤΙΚΗΣ", "ΑΧΑΙΑΣ", "ΒΟΙΩΤΙΑΣ", "ΓΡΕΒΕΝΩΝ", "ΔΡΑΜΑΣ", "ΔΩΔΕΚΑΝΗΣΟΥ", "ΕΒΟΙΑΣ", "ΕΒΡΟΥ", "ΕΥΡΥΤΑΝΙΑΣ", "ΖΑΚΥΝΘΟΥ", "ΗΛΕΙΑΣ", "ΗΜΑΘΙΑΣ", "ΗΡΑΚΛΕΙΟΥ", "ΘΕΣΠΡΩΤΙΑΣ", "ΘΕΣΣΑΛΟΝΙΚΗΣ", "ΙΩΑΝΝΙΝΩΝ", "ΚΑΒΑΛΑΣ", "ΚΑΡΔΙΤΣΑΣ", "ΚΑΣΤΟΡΙΑΣ", "ΚΕΡΚΥΡΑΣ", "ΚΕΦΑΛΛΗΝΙΑΣ", "ΚΙΛΚΙΣ", "ΚΟΖΑΝΗΣ", "ΚΟΡΙΝΘΙΑΣ", "ΚΥΚΛΑΔΩΝ", "ΛΑΚΩΝΙΑΣ", "ΛΑΡΙΣΑΣ", "ΛΑΣΙΘΙΟΥ", "ΛΕΣΒΟΥ", "ΛΕΥΚΑΔΑΣ", "ΜΑΓΝΗΣΙΑΣ", "ΜΕΣΣΗΝΙΑΣ", "ΞΑΝΘΗΣ", "ΠΕΛΛΑΣ", "ΠΙΕΡΙΑΣ", "ΠΡΕΒΕΖΑΣ", "ΡΕΘΥΜΝΟΥ", "ΡΟΔΟΠΗΣ", "ΣΑΜΟΥ", "ΣΕΡΡΩΝ", "ΤΡΙΚΑΛΩΝ", "ΦΘΙΩΤΙΔΑΣ", "ΦΛΩΡΙΝΑΣ", "ΦΩΚΙΔΑΣ", "ΧΑΛΚΙΔΙΚΗΣ", "ΧΑΝΙΩΝ", "ΧΙΟΥ"]
    
    @IBOutlet var table: UITableView!
    var indexSelected : Int = 0
    
    override func viewDidLoad() {
        table.backgroundView = UIImageView(image: UIImage(named: "background_cactus"))
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NOMOI.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = NOMOI[indexPath.row]
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow()
        
        indexSelected = indexPath!.row
        self.performSegueWithIdentifier("nomoiToPerioxesSignup", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var selectPerioxi : SelectPerioxi_signup = segue.destinationViewController as! SelectPerioxi_signup
        selectPerioxi.nomosSelected = indexSelected
        
    }
}
