//
//  RDImageViewerController.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import PureLayout
import UIKit

@objcMembers
open class RDImageViewerController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, PagingViewDelegate, PagingViewDataSource {
    enum ViewTag: Int {
        case mainScrollView = 1
        case pageScrollView = 2
    }

    static let pageHudLabelFontSize: CGFloat = 17

    var previousPageIndex: PagingView.VisibleIndex = .single(index: 0)
    var feedbackGenerator = UISelectionFeedbackGenerator()
    var didRotate: Bool = false
    var pageHud: PageHud

    open var doubleSpreadConfiguration: DoubleSpreadConfiguration = DoubleSpreadConfiguration(portrait: false, landscape: false) {
        didSet {
            pagingView.isDoubleSpread = isDoubleSpread
        }
    }

    open var isSliderEnabled: Bool = true
    open var automaticBarsHiddenDuration: TimeInterval = 0
    open var restoreBarState: Bool = true
    open var isPageNumberHudEnabled: Bool = true
    open var contents: [PageContent] = []
    open var pagingView: PagingView
    open var pageSlider: UISlider

    open func interfaceBehaviour() -> HudBehaviour & SliderBehaviour & PagingBehaviour {
        if isDoubleSpread {
            return DoubleSpreadPageBehaviour()
        }
        return SinglePageBehaviour()
    }

    open var preloadCount: Int {
        set {
            pagingView.preloadCount = newValue
        }
        get {
            return pagingView.preloadCount
        }
    }

    open var currentPageIndex: PagingView.VisibleIndex {
        set {
            switch newValue {
            case let .double(indexes):
                if indexes.isEmpty == false {
                    interfaceBehaviour().updatePageIndex(indexes.first!, pagingView: pagingView)
                }
            case let .single(index):
                interfaceBehaviour().updatePageIndex(index, pagingView: pagingView)
            }
            interfaceBehaviour().updateLabel(label: pageHud.label, numerator: pagingView.currentPageIndex, denominator: numberOfPages)
            interfaceBehaviour().snapSliderPosition(slider: pageSlider, pagingView: pagingView)
            pagingView.currentPageIndex = newValue
        }
        get {
            return pagingView.currentPageIndex
        }
    }

    open var numberOfPages: Int {
        return contents.count
    }

    open var isPagingEnabled: Bool {
        set {
            pagingView.isPagingEnabled = newValue
        }
        get {
            return pagingView.isPagingEnabled
        }
    }

    open var isDoubleSpread: Bool {
        if traitCollection.isLandscape() {
            return doubleSpreadConfiguration.landscape
        }
        return doubleSpreadConfiguration.portrait
    }

    private var _showSlider: Bool = false
    open var showSlider: Bool {
        set {
            pagingView.beginChangingBarState()
            if pagingView.scrollDirection.isHorizontal() {
                setToolBarHidden(hidden: !newValue, animated: true)
            } else {
                setToolBarHidden(hidden: true, animated: true)
            }
            pagingView.endChangingBarState()
            applySliderTintColor()
        }
        get {
            return _showSlider
        }
    }

    private var _showPageNumberHud: Bool = false
    open var showPageNumberHud: Bool {
        set {
            setHudHidden(hidden: !newValue, animated: true)
        }
        get {
            return _showPageNumberHud
        }
    }

    open var statusBarHidden: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    open var pageSliderMaximumTrackTintColor: UIColor? {
        didSet {
            applySliderTintColor()
        }
    }

    open var pageSliderMinimumTrackTintColor: UIColor? {
        didSet {
            applySliderTintColor()
        }
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        didRotate = true

        if let flowLayout = pagingView.collectionViewLayout as? PagingViewFlowLayout {
            flowLayout.invalidateLayout()
        }

        let previousPageIndex = currentPageIndex
        pagingView.beginRotate()
        coordinator.animate(alongsideTransition: { [unowned self] context in
            self.pagingView.isDoubleSpread = self.isDoubleSpread
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // restore page index
                self.pagingView.currentPageIndex = previousPageIndex
            }

            UIView.animate(withDuration: context.transitionDuration) {
                self.pagingView.resizeVisiblePages()
            }
        }) { [unowned self] _ in
            self.pagingView.endRotate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // update page index
                self.interfaceBehaviour().snapSliderPosition(slider: self.pageSlider, pagingView: self.pagingView)
                self.interfaceBehaviour().updateLabel(label: self.pageHud.label, numerator: self.pagingView.currentPageIndex, denominator: self.numberOfPages)
            }
        }
    }

    public init(contents: [PageContent], direction: PagingView.ForwardDirection) {
        pageHud = PageHud(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        feedbackGenerator.prepare()
        self.contents = contents
        pagingView = PagingView(frame: CGRect.zero, forwardDirection: direction)
        pageSlider = UISlider(frame: CGRect.zero)
        super.init(nibName: nil, bundle: nil)
        pagingView.pagingDataSource = self
        pagingView.pagingDelegate = self
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setBarHiddenByTapGesture)))

        view.addSubview(pagingView)
        pagingView.translatesAutoresizingMaskIntoConstraints = false
        pagingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pagingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        pagingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pagingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        pagingView.backgroundColor = UIColor.black
        pagingView.isDirectionalLockEnabled = true
        pagingView.tag = ViewTag.pageScrollView.rawValue
        pagingView.showsHorizontalScrollIndicator = false
        pagingView.showsVerticalScrollIndicator = false
        pagingView.isDoubleSpread = isDoubleSpread
        if pagingView.scrollDirection.isHorizontal() {
            pagingView.isPagingEnabled = true
        }

        if #available(iOS 11.0, *) {
            pagingView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        view.addSubview(pageHud)
        pageHud.autoAlignAxis(toSuperviewAxis: .vertical)
        pageHud.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 10)

        pageSlider.frame = CGRect(x: 0, y: 0, width: view.frame.width - 30, height: 31)
        pageSlider.autoresizingMask = [.flexibleWidth]
        pageSlider.addTarget(self, action: #selector(sliderValueDidChange(slider:)), for: .valueChanged)
        pageSlider.addTarget(self, action: #selector(sliderDidTouchUpInside(slider:)), for: .touchUpInside)
        let sliderItem = UIBarButtonItem(customView: pageSlider)
        toolbarItems = [sliderItem]

        currentPageIndex = .single(index: 0)
        registerContents()
        applySliderTintColor()
        interfaceBehaviour().snapSliderPosition(slider: pageSlider, pagingView: pagingView)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        if restoreBarState == true {
            pagingView.beginChangingBarState()
            setNavigationBarHidden(hidden: navigationController?.isNavigationBarHidden ?? false, animated: true)
            setToolBarHidden(hidden: !showSlider, animated: true)
            setHudHidden(hidden: !showPageNumberHud, animated: false)
            pagingView.endChangingBarState()
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if automaticBarsHiddenDuration > 0 {
            perform(#selector(hideBars), with: self, afterDelay: automaticBarsHiddenDuration)
            automaticBarsHiddenDuration = 0
        }
        interfaceBehaviour().updateLabel(label: pageHud.label, numerator: pagingView.currentPageIndex, denominator: numberOfPages)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelAutoBarHidden()
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if didRotate {
            // update cell size
            pagingView.resizeVisiblePages()

            // update slider position
            interfaceBehaviour().snapSliderPosition(slider: pageSlider, pagingView: pagingView)

            didRotate = false
        }
    }

    // MARK: - slider

    private var previousSliderValue: Float = 0
    func sliderValueDidChange(slider: UISlider) {
        cancelAutoBarHidden()
        let position = pageSlider.trueSliderValue(value: slider.value, pagingView: pagingView)
        let pageIndex = position * Float(numberOfPages - 1)
        let truePageIndex = Int(pageIndex + 0.5)
        let newIndex = truePageIndex.convert(double: isDoubleSpread)
        if currentPageIndex.contains(newIndex) == false, previousSliderValue != slider.value {
            previousSliderValue = slider.value
            feedbackGenerator.selectionChanged()
            pagingView(pagingView: pagingView, willChangeIndexTo: newIndex, currentIndex: currentPageIndex)
            pagingView(pagingView: pagingView, didChangeIndexTo: newIndex)
        }
        currentPageIndex = newIndex
    }

    func sliderDidTouchUpInside(slider: UISlider) {
        // snap
        interfaceBehaviour().snapSliderPosition(slider: slider, pagingView: pagingView)
    }

    // MARK: - bars

    open func setBarHiddenByTapGesture() {
        cancelAutoBarHidden()
        setBarsHidden(hidden: !statusBarHidden, animated: true)
    }

    open func hideBars() {
        setBarsHidden(hidden: true, animated: true)
    }

    open func setNavigationBarHidden(hidden: Bool, animated: Bool) {
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }

    open func setToolBarHidden(hidden: Bool, animated: Bool) {
        _showSlider = !hidden
        if isSliderEnabled == false {
            return
        }
        if let toolbarItems = toolbarItems, toolbarItems.isEmpty == false {
            navigationController?.setToolbarHidden(hidden, animated: animated)
        }
    }

    open func setBarsHidden(hidden: Bool, animated: Bool) {
        pagingView.beginChangingBarState()
        setToolBarHidden(hidden: hidden, animated: animated)
        setNavigationBarHidden(hidden: hidden, animated: animated)
        setHudHidden(hidden: hidden, animated: animated)
        statusBarHidden = hidden
        pagingView.endChangingBarState()
    }

    open func cancelAutoBarHidden() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideBars), object: self)
    }

    // MARK: - hud

    open func setHudHidden(hidden: Bool, animated: Bool) {
        _showPageNumberHud = !hidden
        if isPageNumberHudEnabled == false {
            return
        }
        var duration: CGFloat = 0
        if animated {
            duration = UINavigationController.hideShowBarDuration
        }
        UIView.animate(withDuration: TimeInterval(duration), animations: { [unowned self] in
            self.pageHud.alpha = hidden == true ? 0 : 1.0
        })
    }

    func scrollDidEnd() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        interfaceBehaviour().updateLabel(label: pageHud.label, numerator: pagingView.currentPageIndex, denominator: numberOfPages)
    }

    // MARK: - appearance

    func applySliderTintColor() {
        var maximumTintColor = UIColor(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)
        if let tintColor = pageSliderMaximumTrackTintColor {
            maximumTintColor = tintColor
        }

        var minimumTintColor = UIColor.white
        if let tintColor = pageSliderMinimumTrackTintColor {
            minimumTintColor = tintColor
        }

        if pagingView.scrollDirection == .left {
            pageSlider.maximumTrackTintColor = maximumTintColor
            pageSlider.minimumTrackTintColor = minimumTintColor
        } else {
            pageSlider.maximumTrackTintColor = minimumTintColor
            pageSlider.minimumTrackTintColor = maximumTintColor
        }
    }

    // MARK: - page/viewer

    open func registerContents() {
        for data in contents {
            switch data.type {
            case let .class(cellClass):
                pagingView.register(cellClass, forCellWithReuseIdentifier: data.reuseIdentifier())
            case let .nib(cellNib, _):
                pagingView.register(cellNib, forCellWithReuseIdentifier: data.reuseIdentifier())
            }
        }
    }

    open func reloadData() {
        registerContents()
        pagingView.reloadData()
        interfaceBehaviour().snapSliderPosition(slider: pageSlider, pagingView: pagingView)
        interfaceBehaviour().updateLabel(label: pageHud.label, numerator: pagingView.currentPageIndex, denominator: numberOfPages)
    }

    open func update(contents newContents: [PageContent]) {
        contents = newContents
        reloadData()
    }

    public func reloadView(at index: Int) {
        if index < 0 || (numberOfPages - 1) < index {
            return
        }
        let data = contents[index]
        data.reload()
        refreshView(at: index)
    }

    public func refreshView(at index: Int) {
        if index < 0 || (numberOfPages - 1) < index {
            return
        }
        pagingView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }

    open func changeDirection(_ forwardDirection: PagingView.ForwardDirection) {
        pagingView.changeDirection(forwardDirection)
        if pagingView.scrollDirection.isHorizontal() {
            pagingView.isPagingEnabled = true
        } else {
            pagingView.isPagingEnabled = false
        }
    }

    open func configureView(_ view: PageViewProtocol & UICollectionViewCell, data: PageContentProtocol, indexPath: IndexPath) {
        view.configure(data: data, pageIndex: indexPath.row, scrollDirection: pagingView.scrollDirection, traitCollection: traitCollection, isDoubleSpread: isDoubleSpread)
        view.resize()
        if let imageScrollView = view as? ImageScrollView {
            pagingView.gestureRecognizers?.forEach { gesture in
                if gesture is UITapGestureRecognizer {
                    imageScrollView.addGestureRecognizerPriorityHigherThanZoomGestureRecogniser(gesture: gesture)
                }
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return numberOfPages
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = contents[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.reuseIdentifier(), for: indexPath) as! PageViewProtocol & UICollectionViewCell
        configureView(cell, data: data, indexPath: indexPath)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = contents[indexPath.row]
        return data.size(inRect: collectionView.bounds, direction: pagingView.scrollDirection, traitCollection: traitCollection, isDoubleSpread: isDoubleSpread)
    }

    // MARK: - PagingViewDelegate

    open func pagingView(pagingView: PagingView, willChangeIndexTo index: PagingView.VisibleIndex, currentIndex _: PagingView.VisibleIndex) {
        switch index {
        case .single:
            if pagingView.scrollDirection.isVertical() {
                interfaceBehaviour().updateLabel(label: pageHud.label, numerator: index, denominator: numberOfPages)
            }
        case .double:
            break
        }
    }

    open func pagingView(pagingView _: PagingView, willChangeViewSize _: CGSize, duration _: TimeInterval, visibleViews _: [UIView]) {}

    open func pagingViewDidEndDragging(pagingView _: PagingView, willDecelerate _: Bool) {}

    open func pagingViewWillBeginDecelerating(pagingView _: PagingView) {}

    open func pagingViewDidEndScrollingAnimation(pagingView _: PagingView) {}

    open func pagingView(pagingView: PagingView, didChangeIndexTo index: PagingView.VisibleIndex) {
        if pagingView.scrollDirection.isVertical() {
            interfaceBehaviour().updateLabel(label: pageHud.label, numerator: index, denominator: numberOfPages)
        }
    }

    open func pagingView(pagingView: PagingView, didScrollToPosition position: CGFloat) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)

        if pagingView.scrollDirection.isHorizontal() {
            if pageSlider.state == .normal {
                interfaceBehaviour().updateSliderPosition(slider: pageSlider, value: Float(position), pagingView: pagingView)
            }

            let to = Int(position + 0.5)
            interfaceBehaviour().updateLabel(label: pageHud.label, numerator: .single(index: to), denominator: numberOfPages)
        }
    }

    open func pagingViewWillBeginDragging(pagingView: PagingView) {
        if pagingView.isDragging == false {
            previousPageIndex = currentPageIndex
        }
    }

    open func pagingViewDidEndDecelerating(pagingView _: PagingView) {
        if isDoubleSpread {
            perform(#selector(scrollDidEnd), with: nil, afterDelay: 0.1)
        }
    }

    open func pagingView(pagingView: PagingView, didEndDisplaying view: UIView & PageViewProtocol, index _: Int) {
        for v in view.subviews {
            if let scrollView = v as? UIScrollView {
                if pagingView.isPagingEnabled {
                    scrollView.zoomScale = 1.0
                }
            }
        }
    }

    open func pagingView(pagingView _: PagingView, preloadItemAt index: Int) {
        if index < 0 || contents.count - 1 < index {
            return
        }
        let data = contents[index]
        if data.isPreloadable(), !data.isPreloading() {
            data.preload()
        }
    }

    open func pagingView(pagingView _: PagingView, cancelPreloadingItemAt index: Int) {
        if index < 0 || contents.count - 1 < index {
            return
        }
        let data = contents[index]
        if data.isPreloadable(), data.isPreloading() {
            data.stopPreload()
        }
    }

    // MARK: - ViewController

    override open var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    override open var shouldAutorotate: Bool {
        return true
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portraitUpsideDown
    }

    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
