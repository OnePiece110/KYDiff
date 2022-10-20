//
//  ViewController.swift
//  KYDiff
//
//  Created by keyon on 2022/10/18.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(KYMyers.diff(old: "123".map{ $0 }, new: "088243".map{ $0 }))
        view.addSubview(testLabel)
        testLabel.attributedText = KYMyers.diff(old: "123".map{ $0 }, new: "088243".map{ $0 }).map{ $0.attributedString }.reduce(NSMutableAttributedString(), { partialResult, attr in
            partialResult.append(attr)
            return NSMutableAttributedString(attributedString: partialResult)
        })
        testLabel.sizeToFit()
        testLabel.frame = CGRect(origin: CGPoint(x: 100, y: 100), size: testLabel.frame.size)
    }

    private lazy var testLabel: UILabel = {
        let label = UILabel()
        return label
    }()


}

extension KYMyersScript where T: CustomStringConvertible {
    var attributedString: NSMutableAttributedString {
        let text = NSMutableAttributedString(string: value.description)
        switch action {
        case .delete:
            text.addAttributes([.foregroundColor: UIColor.red, .strikethroughColor: UIColor.red, .strikethroughStyle: NSUnderlineStyle.single.rawValue], range: NSRange(location: 0, length: text.length))
        case .insert:
            text.addAttributes([.foregroundColor: UIColor.green], range: NSRange(location: 0, length: text.length))
        case .same:
            break
        }
        return text
    }
}
