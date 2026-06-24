//
//  MahaSegmentedTitleOrImageCell.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2019/1/22.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

open class MahaSegmentedTitleOrImageCell: MahaSegmentedTitleCell {
    public let imageView = UIImageView()
    private var currentImageInfo: String?

    open override func prepareForReuse() {
        super.prepareForReuse()

        currentImageInfo = nil
    }

    open override func commonInit() {
        super.commonInit()

        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        imageView.center = contentView.center
    }

    open override func reloadData(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )

        guard let titleOrImageItemModel = itemModel as? MahaSegmentedTitleOrImageItemModel else {
            return
        }

        updateDisplayState(using: titleOrImageItemModel)
        setNeedsLayout()
    }

    open override func preferredTitleZoomAnimateClosure(itemModel: MahaSegmentedTitleItemModel, baseScale: CGFloat) -> MahaSegmentedCellSelectedAnimationClosure {
        guard let titleOrImageItemModel = itemModel as? MahaSegmentedTitleOrImageItemModel else {
            return super.preferredTitleZoomAnimateClosure(itemModel: itemModel, baseScale: baseScale)
        }
        if shouldUseDefaultTitleAnimation(for: titleOrImageItemModel) {
            //当前item没有选中图片且是将要选中的时候才做动画
            return super.preferredTitleZoomAnimateClosure(itemModel: itemModel, baseScale: baseScale)
        }
        let closure: MahaSegmentedCellSelectedAnimationClosure = { [weak self] _ in
            itemModel.titleCurrentZoomScale = itemModel.isSelected ? itemModel.titleSelectedZoomScale : itemModel.titleNormalZoomScale
            let currentTransform = CGAffineTransform(scaleX: baseScale * itemModel.titleCurrentZoomScale, y: baseScale * itemModel.titleCurrentZoomScale)
            self?.titleLabel.transform = currentTransform
            self?.maskTitleLabel.transform = currentTransform
        }
        closure(0)
        return closure
    }

    open override func preferredTitleStrokeWidthAnimateClosure(itemModel: MahaSegmentedTitleItemModel, attriText: NSMutableAttributedString) -> MahaSegmentedCellSelectedAnimationClosure {
        guard let titleOrImageItemModel = itemModel as? MahaSegmentedTitleOrImageItemModel else {
            return super.preferredTitleStrokeWidthAnimateClosure(itemModel: itemModel, attriText: attriText)
        }
        if shouldUseDefaultTitleAnimation(for: titleOrImageItemModel) {
            //当前item没有选中图片且是将要选中的时候才做动画
            return super.preferredTitleStrokeWidthAnimateClosure(itemModel: itemModel, attriText: attriText)
        }
        let closure: MahaSegmentedCellSelectedAnimationClosure = { [weak self] _ in
            itemModel.titleCurrentStrokeWidth = itemModel.isSelected ? itemModel.titleSelectedStrokeWidth : itemModel.titleNormalStrokeWidth
            attriText.addAttributes([.strokeWidth: itemModel.titleCurrentStrokeWidth], range: NSRange(location: 0, length: attriText.string.count))
            self?.titleLabel.attributedText = attriText
        }
        closure(0)
        return closure
    }

    open override func preferredTitleColorAnimateClosure(itemModel: MahaSegmentedTitleItemModel) -> MahaSegmentedCellSelectedAnimationClosure {
        guard let titleOrImageItemModel = itemModel as? MahaSegmentedTitleOrImageItemModel else {
            return super.preferredTitleColorAnimateClosure(itemModel: itemModel)
        }
        if shouldUseDefaultTitleAnimation(for: titleOrImageItemModel) {
            //当前item没有选中图片且是将要选中的时候才做动画
            return super.preferredTitleColorAnimateClosure(itemModel: itemModel)
        }
        let closure: MahaSegmentedCellSelectedAnimationClosure = { [weak self] _ in
            itemModel.titleCurrentColor = itemModel.isSelected ? itemModel.titleSelectedColor : itemModel.titleNormalColor
            self?.titleLabel.textColor = itemModel.titleCurrentColor
        }
        closure(0)
        return closure
    }

    private func updateDisplayState(using itemModel: MahaSegmentedTitleOrImageItemModel) {
        let shouldDisplayImage = itemModel.isSelected && itemModel.selectedImageInfo != nil
        titleLabel.isHidden = shouldDisplayImage
        imageView.isHidden = !shouldDisplayImage
        imageView.bounds = CGRect(origin: .zero, size: itemModel.imageSize)

        guard shouldDisplayImage, let imageInfo = itemModel.selectedImageInfo, imageInfo != currentImageInfo else {
            return
        }
        currentImageInfo = imageInfo
        if let loadImageClosure = itemModel.loadImageClosure {
            loadImageClosure(imageView, imageInfo)
        } else {
            imageView.image = UIImage(named: imageInfo)
        }
    }

    private func shouldUseDefaultTitleAnimation(for itemModel: MahaSegmentedTitleOrImageItemModel) -> Bool {
        return itemModel.selectedImageInfo == nil && itemModel.isSelected
    }
}
