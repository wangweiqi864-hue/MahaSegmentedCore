//
//  MahaSegmentedDotCell.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/28.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedDotCell: MahaSegmentedTitleCell {
    open var dotView = UIView()

    open override func commonInit() {
        super.commonInit()

        contentView.addSubview(dotView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let dotItemModel = itemModel as? MahaSegmentedDotItemModel else {
            return
        }

        dotView.center = CGPoint(x: titleLabel.frame.maxX + dotItemModel.dotOffset.x, y: titleLabel.frame.minY + dotItemModel.dotOffset.y)
    }

    open override func reloadData(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )

        guard let dotItemModel = itemModel as? MahaSegmentedDotItemModel else {
            return
        }

        applyDotStyle(using: dotItemModel)
    }

    private func applyDotStyle(using itemModel: MahaSegmentedDotItemModel) {
        dotView.backgroundColor = itemModel.dotColor
        dotView.bounds = CGRect(origin: .zero, size: itemModel.dotSize)
        dotView.isHidden = !itemModel.dotState
        dotView.layer.cornerRadius = itemModel.dotCornerRadius
    }
}
