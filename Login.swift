import UIKit

class Login: UIViewController, UIAlertViewDelegate{

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    let host = "5.55.50.38"
    let port = 4444
    let port2 = 4445
    var inp : NSInputStream?
    var out : NSOutputStream?
    
    @IBAction func login(sender: UIButton) {
        username.resignFirstResponder()
        password.resignFirstResponder()
        //todo login code
    }
    @IBAction func forgotPass(sender: UIButton) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Ανάκτηση κωδικού", message: "Εισάγετε username", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Άκυρο", style: .Cancel) { action -> Void in
            //Do nothing
        }
        actionSheetController.addAction(cancelAction)
        //Create and an option action
        var tf : UITextField?
        let nextAction: UIAlertAction = UIAlertAction(title: "Αποστολή", style: .Default) { action -> Void in
            self.view.makeToastActivity()
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                var inStreamUnmanaged:Unmanaged<CFReadStream>?
                var outStreamUnmanaged:Unmanaged<CFWriteStream>?
                CFStreamCreatePairWithSocketToHost(nil, self.host, UInt32(self.port), &inStreamUnmanaged, &outStreamUnmanaged)
                var inStreamUnmanaged2:Unmanaged<CFReadStream>?
                var outStreamUnmanaged2:Unmanaged<CFWriteStream>?
                CFStreamCreatePairWithSocketToHost(nil, self.host, UInt32(self.port2), &inStreamUnmanaged2, &outStreamUnmanaged2)
                self.inp = inStreamUnmanaged?.takeRetainedValue()
                self.out = outStreamUnmanaged?.takeRetainedValue()
                
                var inp2 : NSInputStream?
                var out2 : NSOutputStream?
                inp2 = inStreamUnmanaged2?.takeRetainedValue()
                out2 = outStreamUnmanaged2?.takeRetainedValue()
                
                self.out!.open()
                self.inp!.open()
                inp2!.open()
                out2!.open()
                
                var str = "FORGOTPASS-$-"+tf!.text+"\n"
                var x = [UInt8](str.utf8)
                self.out!.write(&x, maxLength: x.count)
                
                //////READ CODE - READS UTF8////
                var readByte : [UInt8] = []
                while readByte.last != 10{   //10 = \n (println)
                    while self.inp!.hasBytesAvailable {
                        var currentByte : UInt8 = 0
                        self.inp!.read(&currentByte, maxLength: 1)
                        if(currentByte != 0){
                            readByte.append(currentByte)
                        }
                    }
                }
                //////////////////////////////
                dispatch_async(dispatch_get_main_queue()) {
                    self.view.hideToastActivity()
                    self.view.makeToast(message: "Ο κωδικός αποστάλθηκε στο e-mail σας!")
                }
            }
        }
        actionSheetController.addAction(nextAction)
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            tf = textField
            textField.textColor = UIColor.blueColor()
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
}
