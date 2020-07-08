import UIKit
import Sonar

final class TestSonarItemView: SonarItemView {

    @IBOutlet weak var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 25
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.clipsToBounds = true
    }

}
