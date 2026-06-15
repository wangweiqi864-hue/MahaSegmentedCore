//
//  MahaSegmentedIndicatorGradientView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/2.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedComponetGradientView: UIView {
    open class override var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    open var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
}
