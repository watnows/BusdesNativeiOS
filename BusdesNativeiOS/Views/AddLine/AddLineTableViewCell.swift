import UIKit

class AddLineTableViewCell: UITableViewCell {
    static let height: CGFloat = 64
    @IBOutlet private var busStopNameLabel: UILabel! {
        didSet {
            busStopNameLabel.textColor = .black
        }
    }
    @IBOutlet private var busStopKanaLabel: UILabel! {
        didSet {
            busStopKanaLabel.textColor = .gray
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureCell(_ data: AddLineTableViewCell.Data) {
        busStopNameLabel.text = data.busStopName
        busStopKanaLabel.text = data.busStopKana
    }
}

extension AddLineTableViewCell {
    struct Data {
        let busStopName: String
        let busStopKana: String
    }
}
