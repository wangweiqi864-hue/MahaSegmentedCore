//
//  MahaSegmentedIndicatorImageView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/2.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedIndicatorImageView: MahaSegmentedIndicatorBaseView {
    open var image: UIImage? {
        didSet {
            layer.contents = image?.cgImage
        }
    }

    open override func commonInit() {
        super.commonInit()

        indicatorWidth = 20
        indicatorHeight = 20
        layer.contentsGravity = .resizeAspect
    }

    open override func refreshIndicatorState(model: MahaSegmentedIndicatorSelectedParams) {
        super.refreshIndicatorState(model: model)

        backgroundColor = nil
        frame = indicatorFrame(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
    }

    open override func contentScrollViewDidScroll(model: MahaSegmentedIndicatorTransitionParams) {
        super.contentScrollViewDidScroll(model: model)

        guard canHandleTransition(model: model) else {
            return
        }

        let leftItemFrame = model.leftItemFrame
        let rightItemFrame = model.rightItemFrame
        let percent = model.percent
        let targetWidth = getIndicatorWidth(itemFrame: model.leftItemFrame, itemContentWidth: model.leftItemContentWidth)
        let leftX = centeredIndicatorX(itemFrame: leftItemFrame, indicatorWidth: targetWidth)
        let rightX = centeredIndicatorX(itemFrame: rightItemFrame, indicatorWidth: targetWidth)
        let targetX = MahaSegmentedViewTool.interpolate(from: leftX, to: rightX, percent: percent)
        
        frame.origin.x = targetX
    }

    open override func selectItem(model: MahaSegmentedIndicatorSelectedParams) {
        super.selectItem(model: model)

        let targetWidth = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        var targetFrame = frame
        targetFrame.origin.x = centeredIndicatorX(itemFrame: model.currentSelectedItemFrame, indicatorWidth: targetWidth)
        if canSelectedWithAnimation(model: model) {
            UIView.animate(withDuration: scrollAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                self.frame = targetFrame
            }) { (_) in
            }
        } else {
            frame = targetFrame
        }
    }

}
