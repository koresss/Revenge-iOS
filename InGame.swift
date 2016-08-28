import UIKit

class InGame: UIViewController {
    var vstext : String?
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var clicksLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    var input : NSInputStream?
    var output : NSOutputStream?
    let width = UIScreen.mainScreen().bounds.size.width
    let height = UIScreen.mainScreen().bounds.size.height
    var count = 3
    var gameStarted = false
    var clicks = 0
    let turns = 1
    var alert : UIAlertView!
    var finalScore = -1
    var currentScore = 0
    var concedeTime = 10
    var currentBall : UIImageView!
    var message : NSString!
    var concedeTimer : NSTimer!
    var scoreTimer : NSTimer!
    var gameFinished = false
    var screenSize : CGRect!
    var screenHeight : CGFloat!
    var screenWidth : CGFloat!
    var startTime : NSTimeInterval!
    
    @IBOutlet weak var vslabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bg : UIImageView
        bg = UIImageView(frame: CGRectMake(0, 0, width, height))
        bg.contentMode = UIViewContentMode.ScaleToFill
        if height/width<1.7{
            var x : Int? = vstext!.componentsSeparatedByString("-$-")[1].componentsSeparatedByString("\r")[0].toInt()
            switch x! {
                case 11:
                    bg.image = UIImage(named:"mvm_day.png")
                case 12:
                    bg.image = UIImage(named:"mvf_day.png")
                case 21:
                    bg.image = UIImage(named:"fvm_day.png")
                case 22:
                    bg.image = UIImage(named:"fvf_day.png")
                default:
                    println("error")
            }
        }else{
            var x : Int? = vstext!.componentsSeparatedByString("-$-")[1].componentsSeparatedByString("\r")[0].toInt()
            switch x! {
            case 11:
                bg.image = UIImage(named:"mvm_day.png")
            case 12:
                bg.image = UIImage(named:"mvf_day.png")
            case 21:
                bg.image = UIImage(named:"fvm_day.png")
            case 22:
                bg.image = UIImage(named:"fvf_day.png")
            default:
                println("error")
            }
        }
        self.view.insertSubview(bg, atIndex: 0)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let username = defaults.stringForKey("username")
        let nomos = defaults.stringForKey("nomos")
        let perioxi = defaults.stringForKey("perioxi")
        var opponentData = vstext!.componentsSeparatedByString("-$-")[0]
        var css : String = "<head><style type=\"text/css\">.strokeme{color: black;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;}</style>"
        var htmlString:String! = "\(css)<body><div class=\"strokeme\"><font color=\"00cc00\">\(username!) (\(nomos!)-\(perioxi!))<br></font><font color = red> VS </font><br><font color = \"00cc00\">\(opponentData)</font></div></body>"
        var attrStr = NSAttributedString(
            data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil,
            error: nil)
        vslabel.attributedText = attrStr
        vslabel.textAlignment = NSTextAlignment.Center
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            vslabel.font = UIFont.boldSystemFontOfSize(20)
        case .Pad:
            vslabel.font = UIFont.boldSystemFontOfSize(35)
        case .Unspecified:
            println("error")
        }
        countdownLabel.text = "3"
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "countdown", userInfo: nil, repeats: true)
        ///ONPAUSE+resume///
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "applicationWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
        center.addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        ////////////
        
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
    }
    func applicationWillResignActive(){ //ONPAUSE
        if(!gameFinished){
            self.view.makeToast(message: "Εγκατάλειψη παιχνιδιού σε 10 δευτερόλεπτα!")
            concedeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "concedeUpdater", userInfo: nil, repeats: true)
        }
    }
    internal func concedeUpdater(){
        if(concedeTime-1==0){
            finalScore = -1
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                var str = "\(self.finalScore)\n"
                var x = [UInt8](str.utf8)
                self.output!.write(&x, maxLength: x.count)
                dispatch_async(dispatch_get_main_queue()) {
                    exit(0)
                }
            }
        }else{
            --concedeTime
        }
    }
    func applicationDidBecomeActive(){ //ONRESUME
        concedeTimer.invalidate()
    }
    internal func countdown() {
        if(count-1==0 && !gameStarted){
            countdownLabel.hidden=true
            gameStarted=true
            vslabel.hidden=true
            rapidFire()
        }else{
            countdownLabel.text = "\(--count)"
        }
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = false
    }
    func rapidFire(){
        //////add target/////
        screenSize = UIScreen.mainScreen().bounds
        screenHeight = screenSize.height
        screenWidth = screenSize.width
        
        currentBall = UIImageView(frame: CGRectMake(0, 0, screenWidth*0.2,screenWidth*0.2))
        currentBall.contentMode = UIViewContentMode.ScaleAspectFit
        currentBall.image = UIImage(named:"stoxos.png")
        currentBall.center = CGPointMake(CGFloat(arc4random_uniform(UInt32(Float(screenWidth - screenWidth*0.2))))+screenWidth*0.1, CGFloat(arc4random_uniform(UInt32(Float(screenHeight - screenWidth*0.2))))+screenWidth*0.1)
        self.view.addSubview(currentBall)
        ////////////////////
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("onClick:"))
        currentBall.userInteractionEnabled = true
        currentBall.addGestureRecognizer(tapGestureRecognizer)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        scoreTimer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "updateScore", userInfo: nil, repeats: true)
    }
    internal func updateScore(){
        var s = ((String)(stringInterpolationSegment: NSDate.timeIntervalSinceReferenceDate()-startTime))
        if((s.componentsSeparatedByString(".")[0]).toInt() == 0){
            s = s.componentsSeparatedByString(".")[1]
            s = (s as NSString).substringToIndex(3)
            while((s as NSString).substringToIndex(1).toInt() == 0){
                s = (s as NSString).substringFromIndex(1)
            }
        }else if(Swift.count(s.componentsSeparatedByString(".")[0])==2){
            s = s.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            s = (s as NSString).substringToIndex(5)
        }else{
            s = s.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            s = (s as NSString).substringToIndex(4)
        }
        scoreLabel.text = "Σκορ: \(s)ms"
        currentScore = s.toInt()!
    }
    func onClick(img: AnyObject){
        clicks++
        if(clicks<turns){
            clicksLabel.text = "Clicks: \(clicks)"
            currentBall.center = CGPointMake(CGFloat(arc4random_uniform(UInt32(Float(screenWidth - screenWidth*0.2))))+screenWidth*0.1, CGFloat(arc4random_uniform(UInt32(Float(screenHeight - screenHeight*0.2))))+screenHeight*0.1)
        }else{
            scoreTimer.invalidate()
            clicksLabel.text = "Clicks: \(clicks)"
            currentBall.hidden=true
            finalScore = currentScore
            ///loading///
            self.alert = UIAlertView(title: "Περιμέντε να τελειώσει ο αντίπαλός σας...", message: "" , delegate: nil, cancelButtonTitle: nil)
            var viewBack:UIView = UIView(frame: CGRectMake(83,0,100,40))
            
            var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37))
            loadingIndicator.center = CGPoint(x:viewBack.center.x,y:viewBack.center.y-10)
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            loadingIndicator.startAnimating();
            viewBack.addSubview(loadingIndicator)
            viewBack.center = self.view.center
            alert!.setValue(viewBack, forKey: "accessoryView")
            loadingIndicator.startAnimating()
            alert!.delegate=self
            alert!.show();
            //////////////
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                var str = "\(self.finalScore)\n"
                var x = [UInt8](str.utf8)
                self.output!.write(&x, maxLength: x.count)
                self.gameFinished=true
                do{
                    //////READ CODE - READS UTF8////
                    var readByte : [UInt8] = []
                    while readByte.last != 10{   //10 = \n (println)
                        while self.input!.hasBytesAvailable {
                            var currentByte : UInt8 = 0
                            self.input!.read(&currentByte, maxLength: 1)
                            if(currentByte != 0){
                                readByte.append(currentByte)
                            }
                        }
                    }
                    var endMarker = NSData(bytes: readByte as [UInt8], length: readByte.count)
                    self.message = NSString(data: endMarker, encoding: NSUTF8StringEncoding)!
                    //////////////////////////////
                }while(self.message != nil && !self.message.containsString("gameresult") && self.finalScore != -1)

                dispatch_async(dispatch_get_main_queue()) {
                    if(self.message != nil && self.finalScore != -1){
                        self.goGameComplete()
                    }
                }
            }
        }
    }
    func goGameComplete(){
        self.alert.dismissWithClickedButtonIndex(0, animated: true)
        performSegueWithIdentifier("gameEnd", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var gameEnd: GameEnd = segue.destinationViewController as! GameEnd
        gameEnd.gameResults = self.message
        gameEnd.output = self.output
        gameEnd.input = self.input
        gameEnd.opponentUsername = self.vstext?.componentsSeparatedByString("-$-")[0]
        gameEnd.vsText = self.vstext
    }

}
