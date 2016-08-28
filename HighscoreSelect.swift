import UIKit

class HighscoreSelect: UIViewController {

    @IBOutlet weak var cactusMap: UIImageView!
    let width = UIScreen.mainScreen().bounds.size.width
    let height = UIScreen.mainScreen().bounds.size.height
    var maskView: UIImageView? = nil
    var mask:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bg : UIImageView
        bg = UIImageView(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.size.height, width, height-self.navigationController!.navigationBar.frame.size.height))
        bg.contentMode = UIViewContentMode.ScaleToFill
        bg.image = UIImage(named:"background_nocactus.png")
        self.view.addSubview(bg)
        //bg.center=self.view.center
        
        var bg2 : UIImageView
        bg2 = UIImageView(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.size.height, width, height-self.navigationController!.navigationBar.frame.size.height))
        bg2.contentMode = UIViewContentMode.ScaleToFill
        bg2.image = UIImage(named:"highscore_cactus.png")
        self.view.addSubview(bg2)
        //bg2.center=self.view.center
        
        
        maskView = UIImageView(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.size.height, width, height-self.navigationController!.navigationBar.frame.size.height))
        maskView!.contentMode = UIViewContentMode.ScaleToFill
        mask = UIImage(named:"highscore_cactus_map.png")
        maskView!.image = mask!
        maskView!.hidden=true
        self.view.addSubview(maskView!)
        //maskView?.center=self.view.center
        
        
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInView(maskView)
        var redval: CGFloat = 0
        var greenval: CGFloat = 0
        var blueval: CGFloat = 0
        var alphaval: CGFloat = 0
        var percentageWidth : CGFloat = location.x*UIScreen.mainScreen().scale / (width*UIScreen.mainScreen().scale)
        var percentageHeight : CGFloat = location.y*UIScreen.mainScreen().scale / ((height-self.navigationController!.navigationBar.frame.size.height)*UIScreen.mainScreen().scale)
        var color = maskView!.image!.getPixelColor(CGPoint(x: Int(maskView!.image!.size.width*percentageWidth), y: Int(maskView!.image!.size.height*percentageHeight)))
        color.getRed(&redval, green: &greenval, blue: &blueval, alpha: &alphaval)
        
        
        if redval==1.0 && greenval==0.0{ //red = general
            self.performSegueWithIdentifier("generalHighscores", sender: nil)
        }
        if redval==1.0 && greenval==1.0 && blueval==0.0{//yellow = daily
            self.performSegueWithIdentifier("dailyHighscores", sender: nil)
        }
    }
}
