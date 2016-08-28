import UIKit
import Foundation

extension String {
    var utf8Array: [UInt8] {
        return Array(utf8)
    }
}

class Signup: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var boyImage: UIImageView!
    @IBOutlet weak var girlImage: UIImageView!
    var boy : Bool = true
    let host = "89.210.0.121"
    @IBOutlet weak var signup: UIButton!
    let port = 4444
    let port2 = 4445
    var perioxi : String = ""
    var inp : NSInputStream?
    var out : NSOutputStream?
    var inp2 : NSInputStream?
    var out2 : NSOutputStream?
    var message : NSString = ""
    
    override func viewDidLoad() {
        username.delegate = self
        password.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("boyTapped:"))
        boyImage.userInteractionEnabled = true
        boyImage.highlighted=true
        boyImage.addGestureRecognizer(tapGestureRecognizer)
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:Selector("girlTapped:"))
        girlImage.userInteractionEnabled = true
        girlImage.addGestureRecognizer(tapGestureRecognizer2)
    }
    @IBAction func areaSelect(sender: UIButton) {
        self.performSegueWithIdentifier("signupSelectPerioxi", sender: nil)
    }
    @IBAction func signup(sender: UIButton) {
        username.resignFirstResponder()
        password.resignFirstResponder()
        email.resignFirstResponder()
        if username.text.isEmpty {
            self.view.makeToast(message: "Εισάγετε όνομα χρήστη")
        }else if password.text.isEmpty {
            self.view.makeToast(message: "Εισάγετε κωδικό")
        }else if email.text.isEmpty || !isValidEmail(email.text){
            self.view.makeToast(message: "Εισάγετε έγκυρο e-mail")
        }else if perioxi.isEmpty{
            self.view.makeToast(message: "Επιλέξτε περιοχή")
        }else{
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
                

                self.inp2 = inStreamUnmanaged2?.takeRetainedValue()
                self.out2 = outStreamUnmanaged2?.takeRetainedValue()
                
                self.out!.open()
                self.inp!.open()
                self.inp2!.open()
                self.out2!.open()
                
                var str = ""
                if(self.boy){
                    str = "SIGNUPIOS-$-\(self.username.text)-$-\(self.perioxi)-$-1-$-\(self.email.text)\n"
                }else{
                    str = "SIGNUPIOS-$-\(self.username.text)-$-\(self.perioxi)-$-2-$-\(self.email.text)\n"
                }
                var x = [UInt8](str.utf8)
                self.out!.write(&x, maxLength: x.count)
                
                
                //encrypt pass
                var salt = NSUUID().UUIDString
                var hashids = Hashids(salt: salt, minHashLength: 15, alphabet: nil)
                var arr = self.password.text.utf8Array
                var arr2 : [Int] = []
                for x in arr{
                    arr2.append(Int(x))
                }
                var hash = hashids.encode(arr2)
                
                //store both passwords in sharedprefs
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(self.password.text, forKey: "passwordChat")
                userDefaults.setObject(hash, forKey: "password")
                userDefaults.synchronize()
                
                //send encrypted pass + salt
                var hasharray = [UInt8](hash!.utf8)
                var hasharraysize : [UInt8] = []
                hasharraysize.append(0);
                hasharraysize.append(0);
                hasharraysize.append(0);
                hasharraysize.append(UInt8(hasharray.count))
                self.out!.write(&hasharraysize,maxLength: hasharraysize.count)
                self.out!.write(&hasharray, maxLength: hasharray.count)
                
                var saltarray = [UInt8](salt.utf8)
                var saltarraysize : [UInt8] = []
                saltarraysize.append(0);
                saltarraysize.append(0);
                saltarraysize.append(0);
                saltarraysize.append(UInt8(saltarray.count))
                self.out!.write(&saltarraysize,maxLength: saltarray.count)
                self.out!.write(&saltarray, maxLength: saltarray.count)
                
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
                var endMarker = NSData(bytes: readByte as [UInt8], length: readByte.count)
                self.message = NSString(data: endMarker, encoding: NSUTF8StringEncoding)!
                //////////////////////////////
                dispatch_async(dispatch_get_main_queue()) {
                    if self.message.containsString("SUCCESS"){
                        //store username nomos perioxi to sharedprefs
                        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                        dispatch_async(dispatch_get_global_queue(priority, 0)) {
                            var str = "requestPerioxi\n"
                            var x = [UInt8](str.utf8)
                            self.out!.write(&x, maxLength: x.count)
                            
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
                            var endMarker = NSData(bytes: readByte as [UInt8], length: readByte.count)
                            self.message = NSString(data: endMarker, encoding: NSUTF8StringEncoding)!
                            let userDefaults = NSUserDefaults.standardUserDefaults()
                            userDefaults.setObject(self.username.text, forKey: "username")
                            userDefaults.setObject(self.message.componentsSeparatedByString("666")[0], forKey: "nomos")
                            println(self.message.componentsSeparatedByString("666")[0])
                            println(self.message.componentsSeparatedByString("666")[1])
                            userDefaults.setObject(self.message.componentsSeparatedByString("666")[1].componentsSeparatedByString("\r")[0], forKey: "perioxi")
                            userDefaults.synchronize()
                            //create openfire account and dc (on android, main game screen triggers service to start for connection)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.view.hideToastActivity()
                                self.performSegueWithIdentifier("signupToMain", sender: nil)
                            }
                        }

                    }else{
                        self.view.hideToastActivity()
                        self.view.makeToast(message: "Username exists!")
                    }
                }
            }


        }
    }


    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfString("*") != nil {
            return false
        }
        if string.rangeOfString("$") != nil {
            return false
        }
        if textField == username {
            let newLength = count(textField.text.utf16) + count(string.utf16) - range.length
            return newLength <= 15 // Bool
        }
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func boyTapped(img: AnyObject)
    {
        boy = true
        girlImage.highlighted=false
        boyImage.highlighted=true
    }
    func girlTapped(img: AnyObject)
    {
        boy = false
        girlImage.highlighted=true
        boyImage.highlighted=false
    }
    @IBAction func unwindToSignup(segue: UIStoryboardSegue) {
        
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier=="signupToMain"){
            var mainMenu : MainMenu = segue.destinationViewController as! MainMenu
            mainMenu.input = self.inp!
            mainMenu.output = self.out!
            mainMenu.nInput = self.inp2!
            mainMenu.nOutput = self.out2!
        }
    }
}
