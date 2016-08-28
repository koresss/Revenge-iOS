import UIKit
import SpriteKit

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

class StartMenu: UIViewController {
    
    var maskView: UIImageView? = nil
    var mask:UIImage? = nil
    let width = UIScreen.mainScreen().bounds.size.width
    let height = UIScreen.mainScreen().bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bg : UIImageView
        bg = UIImageView(frame: CGRectMake(0, 0, width, height))
        bg.contentMode = UIViewContentMode.ScaleToFill
        if height/width<1.7{
            bg.image = UIImage(named:"startmenu.png")
        }else{
            bg.image = UIImage(named:"startmenu16x9.png")
        }
        self.view.addSubview(bg)
        
        
        maskView = UIImageView(frame: CGRectMake(0, 0, width, height))
        maskView!.contentMode = UIViewContentMode.ScaleToFill
        if height/width<1.7{
            mask = UIImage(named:"startmenumap.png")
        }else{
            mask = UIImage(named:"startmenumap16x9.png")
        }
        maskView!.image = mask!
        maskView!.hidden=true
        self.view.addSubview(maskView!)
        
        
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = false
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
        
        if redval==0.0 && greenval==0.0 && blueval==0.0 && alphaval==1.0{
            self.performSegueWithIdentifier("aboutstartsegue", sender: nil)
        }
        if redval==1.0 && greenval==0.0{
            self.performSegueWithIdentifier("signupsegue", sender: nil)
        }
        if redval<=1.0 && redval>=0.9 && greenval==1.0{
            self.performSegueWithIdentifier("loginsegue", sender: nil)
        }
    }
}



