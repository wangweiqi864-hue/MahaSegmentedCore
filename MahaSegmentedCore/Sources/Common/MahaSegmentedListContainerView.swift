//
//  MahaSegmentedListContainerView.swift
//  MahaSegmentedView
//
//  Created by jiaxin on 2018/12/26.
//  Copyright © 2018 jiaxin. All rights reserved.
//

import UIKit

/// 列表容器视图的类型
///- ScrollView: UIScrollView。优势：没有其他副作用。劣势：视图内存占用相对大一点。因为所有的列表视图都在UIScrollView的视图层级里面。
/// - CollectionView: 使用UICollectionView。优势：因为列表被添加到cell上，视图的内存占用更少，适合内存要求特别高的场景。劣势：因为cell重用机制的问题，导致列表下拉刷新视图(比如MJRefresh)，会因为被removeFromSuperview而被隐藏。所以，列表有下拉刷新需求的，请使用scrollView type。
public enum MahaSegmentedListContainerType {
    case scrollView
    case collectionView
}

@objc
public protocol MahaSegmentedListContainerViewListDelegate {
    /// 如果列表是VC，就返回VC.view
    /// 如果列表是View，就返回View自己
    ///
    /// - Returns: 返回列表视图
    func listView() -> UIView
    @objc optional func listWillAppear()
    @objc optional func listDidAppear()
    @objc optional func listWillDisappear()
    @objc optional func listDidDisappear()
}

@objc
public protocol MahaSegmentedListContainerViewDataSource {
    /// 返回list的数量
    func numberOfLists(in listContainerView: MahaSegmentedListContainerView) -> Int

    /// 根据index初始化一个对应列表实例，需要是遵从`MahaSegmentedListContainerViewListDelegate`协议的对象。
    /// 如果列表是用自定义UIView封装的，就让自定义UIView遵从`MahaSegmentedListContainerViewListDelegate`协议，该方法返回自定义UIView即可。
    /// 如果列表是用自定义UIViewController封装的，就让自定义UIViewController遵从`MahaSegmentedListContainerViewListDelegate`协议，该方法返回自定义UIViewController即可。
    /// 注意：一定要是新生成的实例！！！
    ///
    /// - Parameters:
    ///   - listContainerView: MahaSegmentedListContainerView
    ///   - index: 目标index
    /// - Returns: 遵从MahaSegmentedListContainerViewListDelegate协议的实例
    func listContainerView(_ listContainerView: MahaSegmentedListContainerView, initListAt index: Int) -> MahaSegmentedListContainerViewListDelegate


    /// 控制能否初始化对应index的列表。有些业务需求，需要在某些情况才允许初始化某些列表，通过通过该代理实现控制。
    @objc optional func listContainerView(_ listContainerView: MahaSegmentedListContainerView, canInitListAt index: Int) -> Bool

    /// 返回自定义UIScrollView或UICollectionView的Class
    /// 某些特殊情况需要自己处理UIScrollView内部逻辑。比如项目用了FDFullscreenPopGesture，需要处理手势相关代理。
    ///
    /// - Parameter listContainerView: MahaSegmentedListContainerView
    /// - Returns: 自定义UIScrollView实例
    @objc optional func scrollViewClass(in listContainerView: MahaSegmentedListContainerView) -> AnyClass
}

open class MahaSegmentedListContainerView: UIView, MahaSegmentedViewListContainer, MahaSegmentedViewRTLCompatible {
    open private(set) var type: MahaSegmentedListContainerType
    open private(set) weak var dataSource: MahaSegmentedListContainerViewDataSource?
    open private(set) var scrollView: UIScrollView!
    /// 已经加载过的列表字典。key是index，value是对应的列表
    open private(set) var validListDict = [Int:MahaSegmentedListContainerViewListDelegate]()
    /// 滚动切换的时候，滚动距离超过一页的多少百分比，就触发列表的初始化。默认0.01（即列表显示了一点就触发加载）。范围0~1，开区间不包括0和1
    open var initListPercent: CGFloat = 0.01 {
        didSet {
            if initListPercent <= 0 || initListPercent >= 1 {
                assertionFailure("initListPercent值范围为开区间(0,1)，即不包括0和1")
            }
        }
    }
    open var listCellBackgroundColor: UIColor = .white
    /// 需要和segmentedView.defaultSelectedIndex保持一致，用于触发默认index列表的加载
    open var defaultSelectedIndex: Int = 0 {
        didSet {
            currentIndex = defaultSelectedIndex
        }
    }
    private var currentIndex: Int = 0
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        if let collectionViewClass = dataSource?.scrollViewClass?(in: self) as? UICollectionView.Type {
            return collectionViewClass.init(frame: CGRect.zero, collectionViewLayout: layout)
        }else {
            return UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        }
    }()
    private lazy var containerVC = MahaSegmentedListContainerViewController()
    private var pendingAppearIndex: Int = -1
    private var pendingDisappearIndex: Int = -1

    public init(dataSource: MahaSegmentedListContainerViewDataSource, type: MahaSegmentedListContainerType = .scrollView) {
        self.dataSource = dataSource
        self.type = type
        super.init(frame: CGRect.zero)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func commonInit() {
        containerVC.view.backgroundColor = .clear
        addSubview(containerVC.view)
        containerVC.viewWillAppearClosure = {[weak self] in
            self?.listWillAppear(at: self?.currentIndex ?? 0)
        }
        containerVC.viewDidAppearClosure = {[weak self] in
            self?.listDidAppear(at: self?.currentIndex ?? 0)
        }
        containerVC.viewWillDisappearClosure = {[weak self] in
            self?.listWillDisappear(at: self?.currentIndex ?? 0)
        }
        containerVC.viewDidDisappearClosure = {[weak self] in
            self?.listDidDisappear(at: self?.currentIndex ?? 0)
        }
        if type == .scrollView {
            if let scrollViewClass = dataSource?.scrollViewClass?(in: self) as? UIScrollView.Type {
                scrollView = scrollViewClass.init()
            }else {
                scrollView = UIScrollView.init()
            }
            scrollView.delegate = self
            scrollView.isPagingEnabled = true
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.scrollsToTop = false
            scrollView.bounces = false
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            if segmentedViewShouldRTLLayout() {
                segmentedView(horizontalFlipForView: scrollView)
            }else{
                scrollView.transform = .identity
            }
            containerVC.view.addSubview(scrollView)
        }else if type == .collectionView {
            collectionView.isPagingEnabled = true
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.scrollsToTop = false
            collectionView.bounces = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(MahaSegmentedRTLCollectionCell.self, forCellWithReuseIdentifier: "cell")
            if #available(iOS 10.0, *) {
                collectionView.isPrefetchingEnabled = false
            }
            if #available(iOS 11.0, *) {
                self.collectionView.contentInsetAdjustmentBehavior = .never
            }
            if segmentedViewShouldRTLLayout() {
                collectionView.semanticContentAttribute = .forceLeftToRight
                segmentedView(horizontalFlipForView: collectionView)
            }else{
                collectionView.semanticContentAttribute = .forceLeftToRight
                collectionView.transform = .identity
            }
            containerVC.view.addSubview(collectionView)
            //让外部统一访问scrollView
            scrollView = collectionView
        }
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        var next: UIResponder? = newSuperview
        while next != nil {
            if let vc = next as? UIViewController{
                vc.addChild(containerVC)
                break
            }
            next = next?.next
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        containerVC.view.frame = bounds
        guard let count = dataSource?.numberOfLists(in: self) else {
            return
        }
        if type == .scrollView {
            if scrollView.frame == CGRect.zero || scrollView.bounds.size != bounds.size {
                scrollView.frame = bounds
                scrollView.contentSize = CGSize(width: scrollView.bounds.size.width*CGFloat(count), height: scrollView.bounds.size.height)
                for (index, list) in validListDict {
                    list.listView().frame = CGRect(x: CGFloat(index)*scrollView.bounds.size.width, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
                }
                scrollView.contentOffset = CGPoint(x: CGFloat(currentIndex)*scrollView.bounds.size.width, y: 0)
            }else {
                scrollView.frame = bounds
                scrollView.contentSize = CGSize(width: scrollView.bounds.size.width*CGFloat(count), height: scrollView.bounds.size.height)
            }
        }else {
            if collectionView.frame == CGRect.zero || collectionView.bounds.size != bounds.size {
                collectionView.frame = bounds
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.setContentOffset(CGPoint(x: CGFloat(currentIndex)*collectionView.bounds.size.width, y: 0), animated: false)
            }else {
                collectionView.frame = bounds
            }
        }
    }

    //MARK: - MahaSegmentedViewListContainer

    public func contentScrollView() -> UIScrollView {
           return scrollView
       }

    public func scrolling(from leftIndex: Int, to rightIndex: Int, percent: CGFloat, selectedIndex: Int) {
    }

    open func didClickSelectedItem(at index: Int) {
        guard checkIndexValid(index) else {
            return
        }
        resetPendingTransitionIndexes()
        if currentIndex != index {
            listWillDisappear(at: currentIndex)
            listWillAppear(at: index)
            listDidDisappear(at: currentIndex)
            listDidAppear(at: index)
        }
    }

    open func reloadData() {
        guard let dataSource = dataSource else { return }
        if currentIndex < 0 || currentIndex >= dataSource.numberOfLists(in: self) {
            defaultSelectedIndex = 0
            currentIndex = 0
        }
        validListDict.values.forEach { (list) in
            if let listVC = list as? UIViewController {
                listVC.removeFromParent()
            }
            list.listView().removeFromSuperview()
        }
        validListDict.removeAll()
        if type == .scrollView {
            scrollView.contentSize = CGSize(width: scrollView.bounds.size.width*CGFloat(dataSource.numberOfLists(in: self)), height: scrollView.bounds.size.height)
            
            if segmentedViewShouldRTLLayout() {
                segmentedView(horizontalFlipForView: scrollView)
            }else{
                scrollView.transform = .identity
            }
            
        }else {
            collectionView.reloadData()
        }
        listWillAppear(at: currentIndex)
        listDidAppear(at: currentIndex)
    }

    //MARK: - Private
    func initListIfNeeded(at index: Int) {
        guard canInitializeList(at: index) else {
            return
        }
        if validListDict[index] != nil {
            return
        }
        guard let list = createList(at: index) else {
            return
        }
        mountListView(list, at: index)
    }

    private func listWillAppear(at index: Int) {
        guard checkIndexValid(index) else {
            return
        }
        let list: MahaSegmentedListContainerViewListDelegate?
        if let cachedList = validListDict[index] {
            list = cachedList
        } else {
            guard canInitializeList(at: index), let createdList = createList(at: index) else {
                return
            }
            mountListView(createdList, at: index)
            list = createdList
        }
        beginAppearance(for: list, appearing: true)
    }

    private func listDidAppear(at index: Int) {
        guard checkIndexValid(index) else {
            return
        }
        currentIndex = index
        endAppearance(for: validListDict[index], appearing: true)
    }

    private func listWillDisappear(at index: Int) {
        guard checkIndexValid(index) else {
            return
        }
        beginAppearance(for: validListDict[index], appearing: false)
    }

    private func listDidDisappear(at index: Int) {
        guard checkIndexValid(index) else {
            return
        }
        endAppearance(for: validListDict[index], appearing: false)
    }

    private func checkIndexValid(_ index: Int) -> Bool {
        guard let dataSource = dataSource else { return false }
        let count = dataSource.numberOfLists(in: self)
        if count <= 0 || index < 0 || index >= count {
            return false
        }
        return true
    }

    private func listDidAppearOrDisappear(scrollView: UIScrollView) {
        let currentIndexPercent = scrollView.contentOffset.x/scrollView.bounds.size.width
        if pendingAppearIndex != -1 || pendingDisappearIndex != -1 {
            let disappearIndex = pendingDisappearIndex
            let appearIndex = pendingAppearIndex
            if pendingAppearIndex > pendingDisappearIndex {
                //将要出现的列表在右边
                if currentIndexPercent >= CGFloat(pendingAppearIndex) {
                    resetPendingTransitionIndexes()
                    listDidDisappear(at: disappearIndex)
                    listDidAppear(at: appearIndex)
                }
            } else {
                //将要出现的列表在左边
                if currentIndexPercent <= CGFloat(pendingAppearIndex) {
                    resetPendingTransitionIndexes()
                    listDidDisappear(at: disappearIndex)
                    listDidAppear(at: appearIndex)
                }
            }
        }
    }

    private func canInitializeList(at index: Int) -> Bool {
        return dataSource?.listContainerView?(self, canInitListAt: index) != false
    }

    private func createList(at index: Int) -> MahaSegmentedListContainerViewListDelegate? {
        guard let list = dataSource?.listContainerView(self, initListAt: index) else {
            return nil
        }
        if let viewController = list as? UIViewController {
            containerVC.addChild(viewController)
        }
        validListDict[index] = list
        return list
    }

    private func mountListView(_ list: MahaSegmentedListContainerViewListDelegate, at index: Int) {
        if type == .scrollView {
            attachListViewToScrollView(list, at: index)
        } else {
            attachListViewToCollectionCell(list, at: index)
        }
    }

    private func attachListViewToScrollView(_ list: MahaSegmentedListContainerViewListDelegate, at index: Int) {
        let listView = list.listView()
        listView.frame = CGRect(x: CGFloat(index) * scrollView.bounds.size.width, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        if listView.superview !== scrollView {
            listView.removeFromSuperview()
            scrollView.addSubview(listView)
        }
        applyRTLTransformIfNeeded(to: listView)
    }

    private func attachListViewToCollectionCell(_ list: MahaSegmentedListContainerViewListDelegate, at index: Int) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) else {
            return
        }
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let listView = list.listView()
        listView.frame = cell.contentView.bounds
        cell.contentView.addSubview(listView)
    }

    private func applyRTLTransformIfNeeded(to view: UIView) {
        if segmentedViewShouldRTLLayout() {
            segmentedView(horizontalFlipForView: view)
        } else {
            view.transform = .identity
        }
    }

    private func beginAppearance(for list: MahaSegmentedListContainerViewListDelegate?, appearing: Bool) {
        if appearing {
            list?.listWillAppear?()
        } else {
            list?.listWillDisappear?()
        }
        if let viewController = list as? UIViewController {
            viewController.beginAppearanceTransition(appearing, animated: false)
        }
    }

    private func endAppearance(for list: MahaSegmentedListContainerViewListDelegate?, appearing: Bool) {
        if appearing {
            list?.listDidAppear?()
        } else {
            list?.listDidDisappear?()
        }
        if let viewController = list as? UIViewController {
            viewController.endAppearanceTransition()
        }
    }

    private func resetPendingTransitionIndexes() {
        pendingAppearIndex = -1
        pendingDisappearIndex = -1
    }
}

extension MahaSegmentedListContainerView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.numberOfLists(in: self)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = listCellBackgroundColor
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let list = validListDict[indexPath.item]
        if list != nil {
            list?.listView().frame = cell.contentView.bounds
            cell.contentView.addSubview(list!.listView())
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating else {
            return
        }
        let percent = scrollView.contentOffset.x/scrollView.bounds.size.width
        let maxCount = Int(round(scrollView.contentSize.width/scrollView.bounds.size.width))
        var leftIndex = Int(floor(Double(percent)))
        leftIndex = max(0, min(maxCount - 1, leftIndex))
        let rightIndex = leftIndex + 1
        if percent < 0 || rightIndex >= maxCount {
            listDidAppearOrDisappear(scrollView: scrollView)
            return
        }
        let remainderRatio = percent - CGFloat(leftIndex)
        if rightIndex == currentIndex {
            //当前选中的在右边，用户正在从右边往左边滑动
            if validListDict[leftIndex] == nil && remainderRatio < (1 - initListPercent) {
                initListIfNeeded(at: leftIndex)
            } else if validListDict[leftIndex] != nil {
                if pendingAppearIndex == -1 {
                    pendingAppearIndex = leftIndex
                    listWillAppear(at: pendingAppearIndex)
                }
            }

            if pendingDisappearIndex == -1 {
                pendingDisappearIndex = rightIndex
                listWillDisappear(at: pendingDisappearIndex)
            }
        } else {
            //当前选中的在左边，用户正在从左边往右边滑动
            if validListDict[rightIndex] == nil && remainderRatio > initListPercent {
                initListIfNeeded(at: rightIndex)
            } else if validListDict[rightIndex] != nil {
                if pendingAppearIndex == -1 {
                    pendingAppearIndex = rightIndex
                    listWillAppear(at: pendingAppearIndex)
                }
            }
            if pendingDisappearIndex == -1 {
                pendingDisappearIndex = leftIndex
                listWillDisappear(at: pendingDisappearIndex)
            }
        }
        listDidAppearOrDisappear(scrollView: scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //滑动到一半又取消滑动处理
        if pendingAppearIndex != -1 || pendingDisappearIndex != -1 {
            listWillDisappear(at: pendingAppearIndex)
            listWillAppear(at: pendingDisappearIndex)
            listDidDisappear(at: pendingAppearIndex)
            listDidAppear(at: pendingDisappearIndex)
            resetPendingTransitionIndexes()
        }
    }
}

class MahaSegmentedListContainerViewController: UIViewController {
    var viewWillAppearClosure: (()->())?
    var viewDidAppearClosure: (()->())?
    var viewWillDisappearClosure: (()->())?
    var viewDidDisappearClosure: (()->())?
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { return false }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearClosure?()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearClosure?()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearClosure?()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewDidDisappearClosure?()
    }
}
