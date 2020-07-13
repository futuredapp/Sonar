import UIKit

public struct SonarPosition {
    let waveIndex: Int
    let itemIndex: Int
}

open class SonarItemView: UIView {
    var position: SonarPosition!
}
