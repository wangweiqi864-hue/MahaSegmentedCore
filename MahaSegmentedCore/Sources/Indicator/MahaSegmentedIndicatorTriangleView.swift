//
//  MahaSegmentedIndicatorTriangleView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/28.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedIndicatorTriangleView: MahaSegmentedIndicatorBaseView {
    open override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    private var path = UIBezierPath()

    open override func commonInit() {
        super.commonInit()

        indicatorWidth = 14
        indicatorHeight = 10
    }

    open override func refreshIndicatorState(model: MahaSegmentedIndicatorSelectedParams) {
        super.refreshIndicatorState(model: model)

        backgroundColor = nil
        let shapeLayer = layer as! CAShapeLayer
        shapeLayer.fillColor = indicatorColor.cgColor
        frame = indicatorFrame(itemFrame: model.currentSelectedItemFrame, itemContentWidth: model.currentItemContentWidth)
        path = trianglePath(size: bounds.size)
        shapeLayer.path = path.cgPath
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

    private func trianglePath(size: CGSize) -> UIBezierPath {
        let trianglePath = UIBezierPath()
        if indicatorPosition == .bottom {
            trianglePath.move(to: CGPoint(x: 0, y: size.height))
            trianglePath.addLine(to: CGPoint(x: size.width / 2, y: 0))
            trianglePath.addLine(to: CGPoint(x: size.width, y: size.height))
        } else {
            trianglePath.move(to: CGPoint(x: 0, y: 0))
            trianglePath.addLine(to: CGPoint(x: size.width / 2, y: size.height))
            trianglePath.addLine(to: CGPoint(x: size.width, y: 0))
        }
        trianglePath.close()
        return trianglePath
    }
}
