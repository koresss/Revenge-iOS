import UIKit


class MainMenu: UIViewController,UIAlertViewDelegate {
    
    var maskView: UIImageView? = nil
    var mask:UIImage? = nil
    let width = UIScreen.mainScreen().bounds.size.width
    let height = UIScreen.mainScreen().bounds.size.height
    var queued = false
    var input : NSInputStream?
    var output : NSOutputStream?
    var nInput : NSInputStream?
    var alert : UIAlertView?
    var nOutput : NSOutputStream?
    var message : NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bg : UIImageView
        bg = UIImageView(frame: CGRectMake(0, 0, width, height))
        bg.contentMode = UIViewContentMode.ScaleToFill
        if height/width<1.7{
            bg.image = UIImage(named:"mainmenu.png")
        }else{
            bg.image = UIImage(named:"mainmenu16x9.png")
        }
        self.view.addSubview(bg)
        
        
        maskView = UIImageView(frame: CGRectMake(0, 0, width, height))
        maskView!.contentMode = UIViewContentMode.ScaleToFill
        if height/width<1.7{
            mask = UIImage(named:"mainmenumap.png")
        }else{
            mask = UIImage(named:"mainmenumap16x9.png")
        }
        maskView!.image = mask!
        maskView!.hidden=true
        self.view.addSubview(maskView!)
        
        ///ONPAUSE///
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "applicationWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
        ////////////
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = false

    }
    func applicationWillResignActive(){ //ONPAUSE
        if(queued){
            cancelQueue()
            self.alert!.dismissWithClickedButtonIndex(-1, animated: true)
        }
    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInView(nil)
        var redval: CGFloat = 0
        var greenval: CGFloat = 0
        var blueval: CGFloat = 0
        var alphaval: CGFloat = 0
        var percentageWidth : CGFloat = location.x*UIScreen.mainScreen().scale / (width*UIScreen.mainScreen().scale)
        var percentageHeight : CGFloat = location.y*UIScreen.mainScreen().scale / (height*UIScreen.mainScreen().scale)
        var color = maskView!.image!.getPixelColor(CGPoint(x: Int(maskView!.image!.size.width*percentageWidth), y: Int(maskView!.image!.size.height*percentageHeight)))
        color.getRed(&redval, green: &greenval, blue: &blueval, alpha: &alphaval)
        if redval==0.0 && greenval==0.0 && blueval==0.0{//black
            //todo challenge
        }
        if redval==1.0 && greenval==0.0{ //red
            queued = true
            ///loading///
            self.alert = UIAlertView(title: "Γίνεται εύρεση αντιπάλου...", message: "" , delegate: nil, cancelButtonTitle: "Ακύρωση")
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
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                var str = "game_queue\n"
                var x = [UInt8](str.utf8)
                self.output!.write(&x, maxLength: x.count)
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
                }while(!self.message.containsString("game_queue_"))
                if(self.message.containsString("ok_cancelled")){
                    //do nothing
                }else if(self.message.containsString("queue_found:")){
                    var str = "ok\n"
                    var x = [UInt8](str.utf8)
                    self.output!.write(&x, maxLength: x.count)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.alert!.dismissWithClickedButtonIndex(-1, animated: true)
                    if(self.message.containsString("queue_found:")){
                        self.goInGame();
                    }
                }
            }

        }
        if redval==1.0 && greenval==1.0 && blueval==0.0{//yellow
            self.performSegueWithIdentifier("mainToHighscores", sender: nil)
        }
        if redval==1.0 && greenval==1.0 && blueval==1.0{//white
            self.performSegueWithIdentifier("mainToFriends", sender: nil)
        }
        if redval==0.0 && greenval==0.0 && blueval==1.0{//blue
            self.performSegueWithIdentifier("mainToProfile", sender: nil)
        }
        if redval >= 0.40 && redval <= 0.65 && greenval >= 0.40 && greenval <= 0.65 && blueval >= 0.40 && blueval <= 0.65 { //grey
            self.performSegueWithIdentifier("mainToAbout", sender: nil)
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        cancelQueue()
    }
    func goInGame(){
        queued=false
        self.performSegueWithIdentifier("goIngame", sender: nil)
    }
    func cancelQueue(){
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            var str = "cancel_queue\n"
            var x = [UInt8](str.utf8)
            self.output!.write(&x, maxLength: x.count)
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }
        }
        println("cancelled queue")
        queued=false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier=="goIngame"){
            var inGame: InGame = segue.destinationViewController as! InGame
            inGame.vstext = self.message.componentsSeparatedByString(":")[1] as! String
            inGame.output = self.output
            inGame.input = self.input
        }
    }
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        
    }
}



