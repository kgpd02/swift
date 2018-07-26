
import UIKit

class PDFViewController: UIViewController, URLSessionDelegate, URLSessionDownloadDelegate, UIPageViewControllerDataSource {
    
    var localPDFUrls: URL?
    var remotePDFUrls: URL?
    var pageController: UIPageViewController!
    
    var pdfDocument: CGPDFDocument?
    
    @IBOutlet weak var progressView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if localPDFUrls != nil {
            self.loadLocalPDF()
        } else if remotePDFUrls != nil {
            self.loadRemotePDF()
        }
    }
    
    func loadLocalPDF() {
        progressView.isHidden = true
        
        let pdfAsData = NSData(contentsOf: localPDFUrls!)
        let dataProvider = CGDataProvider(data: pdfAsData!)
        
        self.pdfDocument = CGPDFDocument(dataProvider!)
        
        self.navigationItem.title = localPDFUrls?.deletingPathExtension().lastPathComponent
        
        self.preparePageViewController()
    }
    
    func loadRemotePDF() {
        
        progressView.setProgress(0, animated: false)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let downloadTask = session.downloadTask(with: remotePDFUrls!)
        
        downloadTask.resume()
    
    }
    
    func preparePageViewController() {
        pageController = self.storyboard?.instantiateViewController(withIdentifier: "UIPageViewController") as! UIPageViewController
        
        self.pageController.dataSource = self
        
        self.addChildViewController(pageController)
        
        pageController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.addSubview(pageController.view)
        
        let pageVC = self.storyboard?.instantiateViewController(withIdentifier: "PDFPageViewController") as! PDFPageViewController
        
        pageVC.pdfDocument = pdfDocument
        pageVC.pageNumber = 1
        
        pageController.setViewControllers([pageVC], direction: .forward, animated: true, completion: nil)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageVC = viewController as! PDFPageViewController
        
        if pageVC.pageNumber! > 1 {
            let previousPageVC = self.storyboard?.instantiateViewController(withIdentifier: "PDFPageViewController") as! PDFPageViewController
            
            previousPageVC.pdfDocument = pdfDocument
            previousPageVC.pageNumber =  pageVC.pageNumber! - 1
            
            return previousPageVC
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageVC = viewController as! PDFPageViewController
        
        let previousPageVC = self.storyboard?.instantiateViewController(withIdentifier: "PDFPageViewController") as! PDFPageViewController
        
        previousPageVC.pdfDocument = pdfDocument
        previousPageVC.pageNumber =  pageVC.pageNumber! + 1
        
        return previousPageVC
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.localPDFUrls = location
        self.loadLocalPDF()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.progressView.setProgress(progress, animated: true)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        dump(error)
    }

}
