//
//  MahaSegmentedBaseCell.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/26.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

public typealias MahaSegmentedCellSelectedAnimationClosure = (CGFloat)->()

open class MahaSegmentedBaseCell: UICollectionViewCell, MahaSegmentedViewRTLCompatible {
    open var itemModel: MahaSegmentedBaseItemModel?
    open var animator: MahaSegmentedAnimator?
    private var selectedAnimationClosureArray = [MahaSegmentedCellSelectedAnimationClosure]()

    deinit {
        animator?.stop()
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        animator?.stop()
        animator = nil
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    open func commonInit() {
        self.semanticContentAttribute = .forceLeftToRight
        contentView.semanticContentAttribute = .forceLeftToRight
//        if segmentedViewShouldRTLLayout() {
//            segmentedView(horizontalFlipForView: self)
//            segmentedView(horizontalFlipForView: contentView)
//        }
    }

    open func canStartSelectedAnimation(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) -> Bool {
        var isSelectedAnimatable = false
        if itemModel.isSelectedAnimable {
            if selectedType == .scroll {
                //滚动选中且没有开启左右过渡，允许动画
                if !itemModel.isItemTransitionEnabled {
                    isSelectedAnimatable = true
                }
            }else if selectedType == .click || selectedType == .code {
                //点击和代码选中，允许动画
                isSelectedAnimatable = true
            }
        }
        return isSelectedAnimatable
    }

    open func appendSelectedAnimationClosure(closure: @escaping MahaSegmentedCellSelectedAnimationClosure) {
        selectedAnimationClosureArray.append(closure)
    }

    open func startSelectedAnimationIfNeeded(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        if itemModel.isSelectedAnimable && canStartSelectedAnimation(itemModel: itemModel, selectedType: selectedType) {
            //需要更新isTransitionAnimating，用于处理在过滤时，禁止响应点击，避免界面异常。
            itemModel.isTransitionAnimating = true
            animator?.progressClosure = {[weak self] (percent) in
                guard self != nil else {
                    return
                }
                for closure in self!.selectedAnimationClosureArray {
                    closure(percent)
                }
            }
            animator?.completedClosure = {[weak self] in
                itemModel.isTransitionAnimating = false
                self?.selectedAnimationClosureArray.removeAll()
            }
            animator?.start()
        }
    }

    open func reloadData(itemModel: MahaSegmentedBaseItemModel, selectedType: MahaSegmentedViewItemSelectedType) {
        if segmentedViewShouldRTLLayout() {
//            segmentedView(horizontalFlipForView: self)
            segmentedView(horizontalFlipForView: contentView)
        }else{
            self.transform = .identity
            contentView.transform = .identity
        }
        
        self.itemModel = itemModel

        if itemModel.isSelectedAnimable {
            selectedAnimationClosureArray.removeAll()
            if canStartSelectedAnimation(itemModel: itemModel, selectedType: selectedType) {
                animator = MahaSegmentedAnimator()
                animator?.duration = itemModel.selectedAnimationDuration
            }else {
                animator?.stop()
                animator = nil
            }
        }
        
        
    }
    
    open override var isSelected: Bool {
        didSet {
            setSelectedStyle(isSelected: isSelected)
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            setSelectedStyle(isSelected: isHighlighted)
        }
    }
    
    func setSelectedStyle(isSelected: Bool) {
        
    }
}
