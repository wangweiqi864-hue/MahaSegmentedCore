//
//  MahaSegmentedIndicatorGradientView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/16.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

/// 整个背景是一个渐变色layer，通过gradientMaskLayer遮罩显示不同位置，达到不同文字底部有不同的渐变色。
open class MahaSegmentedIndicatorGradientView: MahaSegmentedIndicatorBaseView {
    @available(*, deprecated, renamed: "indicatorWidthIncrement")
    open var gradientViewWidthIncrement: CGFloat = 20 {
        didSet {
            indicatorWidthIncrement = gradientViewWidthIncrement
        }
    }

    /// 渐变colors
    open var gradientColors = [CGColor]()
    /// 渐变CAGradientLayer，通过它设置startPoint、endPoint等其他属性
    open var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }

    public let gradientMaskLayer: CAShapeLayer = CAShapeLayer()
    open class override var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private var gradientMaskFrame: CGRect = .zero

    open override func commonInit() {
        super.commonInit()

        indicatorWidthIncrement = 20
        indicatorHeight = 26
        indicatorPosition = .center
        verticalOffset = 0

        gradientColors = [UIColor(red: 194.0/255, green: 229.0/255, blue: 156.0/255, alpha: 1).cgColor, UIColor(red: 100.0/255, green: 179.0/255, blue: 244.0/255, alpha: 1).cgColor]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        layer.mask = gradientMaskLayer
    }

    open override func refreshIndicatorState(model: MahaSegmentedIndicatorSelectedParams) {
        super.refreshIndicatorState(model: model)

        gradientLayer.colors = gradientColors
        gradientMaskFrame = indicatorFrame(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        updateGradientMaskPath(
            frame: gradientMaskFrame,
            cornerRadius: getIndicatorCornerRadius(itemFrame: model.currentSelectedItemFrame),
            disableActions: true
        )
        if let collectionViewContentSize = model.collectionViewContentSize {
            frame = CGRect(x: 0, y: 0, width: collectionViewContentSize.width, height: collectionViewContentSize.height)
        }
    }

    open override func contentScrollViewDidScroll(model: MahaSegmentedIndicatorTransitionParams) {
        super.contentScrollViewDidScroll(model: model)

        guard canHandleTransition(model: model) else {
            return
        }

        let leftItemFrame = model.leftItemFrame
        let rightItemFrame = model.rightItemFrame
        let percent = model.percent
        let leftWidth = getIndicatorWidth(itemFrame: leftItemFrame, itemContentWidth: model.leftItemContentWidth)
        let rightWidth = getIndicatorWidth(itemFrame: rightItemFrame, itemContentWidth: model.rightItemContentWidth)
        let leftX = centeredIndicatorX(itemFrame: leftItemFrame, indicatorWidth: leftWidth)
        let rightX = centeredIndicatorX(itemFrame: rightItemFrame, indicatorWidth: rightWidth)
        let targetX = MahaSegmentedViewTool.interpolate(from: leftX, to: rightX, percent: percent)
        var targetWidth = leftWidth
        if indicatorWidth == MahaSegmentedViewAutomaticDimension {
            targetWidth = MahaSegmentedViewTool.interpolate(from: leftWidth, to: rightWidth, percent: percent)
        }

        gradientMaskFrame.origin.x = targetX
        gradientMaskFrame.size.width = targetWidth
        updateGradientMaskPath(
            frame: gradientMaskFrame,
            cornerRadius: getIndicatorCornerRadius(itemFrame: leftItemFrame),
            disableActions: true
        )
    }

    open override func selectItem(model: MahaSegmentedIndicatorSelectedParams) {
        super.selectItem(model: model)

        let targetWidth = getIndicatorWidth(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        var targetFrame = gradientMaskFrame
        targetFrame.origin.x = centeredIndicatorX(itemFrame: model.currentSelectedItemFrame, indicatorWidth: targetWidth)
        targetFrame.size.width = targetWidth
        let cornerRadius = getIndicatorCornerRadius(itemFrame: model.currentSelectedItemFrame)
        let targetPath = UIBezierPath(roundedRect: targetFrame, cornerRadius: cornerRadius)
        if canSelectedWithAnimation(model: model) {
            gradientMaskLayer.removeAnimation(forKey: "path")
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = gradientMaskLayer.path
            animation.toValue = targetPath.cgPath
            animation.duration = scrollAnimationDuration
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            gradientMaskLayer.add(animation, forKey: "path")
            gradientMaskLayer.path = targetPath.cgPath
        } else {
            updateGradientMaskPath(frame: targetFrame, cornerRadius: cornerRadius, disableActions: true)
        }
        gradientMaskFrame = targetFrame
    }

    private func updateGradientMaskPath(frame: CGRect, cornerRadius: CGFloat, disableActions: Bool) {
        let path = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
        CATransaction.begin()
        CATransaction.setDisableActions(disableActions)
        gradientMaskLayer.path = path.cgPath
        CATransaction.commit()
    }
}
