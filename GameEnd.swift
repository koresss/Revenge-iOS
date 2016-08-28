import UIKit

class GameEnd: UIViewController {
    var input : NSInputStream?
    var output : NSOutputStream?
    var gameResults : NSString!
    var opponentUsername : NSString!
    var vsText : NSString! //serverReply in android
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultBIG: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
    }
    
    override func viewDidLoad() {
        var attrStr = NSAttributedString(
            data: gameResults.componentsSeparatedByString("gameresult:")[1].stringByReplacingOccurrencesOfString("Νίκη!", withString: "").stringByReplacingOccurrencesOfString("Ήττα...", withString: "").dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil,
            error: nil)
        resultLabel.attributedText = attrStr
        resultLabel.textAlignment = NSTextAlignment.Center
        resultBIG.text = gameResults.componentsSeparatedByString("gameresult:")[1].componentsSeparatedByString(" ")[0] as! String
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            resultLabel.font = UIFont.boldSystemFontOfSize(20)
            resultBIG.font = UIFont.boldSystemFontOfSize(40)
        case .Pad:
            resultLabel.font = UIFont.boldSystemFontOfSize(35)
            resultBIG.font = UIFont.boldSystemFontOfSize(70)
        case .Unspecified:
            println("error")
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            var str = "replay_decline\n"
            var x = [UInt8](str.utf8)
            self.output!.write(&x, maxLength: x.count)
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }
        }
    }
}
