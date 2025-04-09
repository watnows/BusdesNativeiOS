//import UIKit
//
//class AddLineTableViewCell: UITableViewCell {
//    static let height: CGFloat = 64
//    private var viewModel: AddLineCellViewModel!
//    @IBOutlet private var busStopNameLabel: UILabel! {
//        didSet {
//            busStopNameLabel.textColor = .black
//        }
//    }
//    @IBOutlet private var busStopKanaLabel: UILabel! {
//        didSet {
//            busStopKanaLabel.textColor = .gray
//        }
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//
//    func configure(with viewModel: AddLineCellViewModel) {
//        self.viewModel = viewModel
//        busStopNameLabel.text = viewModel.busStopName
//        busStopKanaLabel.text = viewModel.busStopKana
//    }
//}
