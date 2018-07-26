
import UIKit

class PDFListViewController: UITableViewController {
    
    var localPDFUrls: [URL] = []
    var remotePDFUrls: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        localPDFUrls.append(Bundle.main.url(forResource: "StarPhotography", withExtension: "pdf")!)
        localPDFUrls.append(Bundle.main.url(forResource: "GuideToPhotography", withExtension: "pdf")!)
        
        remotePDFUrls.append(URL(string: "https://drive.google.com/open?id=0B5IRR0I2rAwhLU9xakR0Wk5COW8")!)
        remotePDFUrls.append(URL(string: "http://www.arvindguptatoys.com/arvindgupta/Phoenix-25Nov2014.pdf")!)
        remotePDFUrls.append(URL(string: "http://www.astro.caltech.edu/~george/ay1/lec_pdf/Ay1_Lec12.pdf")!)
        remotePDFUrls.append(URL(string: "https://vk.com/doc485778810_470628803?hash=fcb55f5cb95695cb55&dl=7991748d289f087dcc")!)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let pdfVC = self.storyboard?.instantiateViewController(withIdentifier: "PDVViewController") as! PDFViewController
        
        if indexPath.section == 0 {
            pdfVC.localPDFUrls = localPDFUrls[indexPath.row]
        } else {
            pdfVC.remotePDFUrls = remotePDFUrls[indexPath.row]
        }
        
        self.navigationController?.pushViewController(pdfVC, animated: true)
    }

}
