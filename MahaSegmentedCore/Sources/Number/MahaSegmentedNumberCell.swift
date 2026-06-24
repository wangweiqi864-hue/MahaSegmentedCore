//
//  MahaSegmentedNumberCell.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/28.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedNumberCell: MahaSegmentedTitleCell {
    public let numberLabel = UILabel()

    open override func commonInit() {
        super.commonInit()

        numberLabel.isHidden = true
        numberLabel.textAlignment = .center
        numberLabel.layer.masksToBounds = true
        contentView.addSubview(numberLabel)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let numberItemModel = itemModel as? MahaSegmentedNumberItemModel else {
            return
        }

        numberLabel.sizeToFit()
        let badgeHeight = numberItemModel.numberHeight
        numberLabel.layer.cornerRadius = badgeHeight / 2
        numberLabel.bounds.size = CGSize(width: numberLabel.bounds.size.width + numberItemModel.numberWidthIncrement, height: badgeHeight)
        numberLabel.center = CGPoint(x: titleLabel.frame.maxX + numberItemModel.numberOffset.x, y: titleLabel.frame.minY + numberItemModel.numberOffset.y)
    }

    open override func reloadData(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )

        guard let numberItemModel = itemModel as? MahaSegmentedNumberItemModel else {
            return
        }

        applyNumberLabelStyle(using: numberItemModel)

        setNeedsLayout()
    }

    private func applyNumberLabelStyle(using itemModel: MahaSegmentedNumberItemModel) {
        numberLabel.backgroundColor = itemModel.numberBackgroundColor
        numberLabel.textColor = itemModel.numberTextColor
        numberLabel.text = itemModel.numberString
        numberLabel.font = itemModel.numberFont
        numberLabel.isHidden = itemModel.number == 0
    }
}
