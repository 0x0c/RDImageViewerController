//
//  RDImageViewerController.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

@objcMembers
open class RDImageViewerController: UIViewController {

    enum ViewTag : Int {
        case mainScrollView = 1
        case pageScrollView = 2
        case currentPageLabel = 3
    }

    public var preloadCount: Int {
        set {
            pagingView.preloadCount = newValue
        }
        get {
            return pagingView.preloadCount
        }
    }
    
    public var currentPageIndex: Int {
        set {
            updateSliderValue()
            updateCurrentPageHudLabel(page: newValue + 1, denominator: numberOfPages)
            scrollAt(index: pagingView.currentPageIndex)
        }
        get {
            return pagingView.currentPageIndex
        }
    }
    
    public var numberOfPages: Int {
        get {
            return contents.count
        }
    }

    public var isPagingEnabled: Bool {
        set {
            pagingView.isPagingEnabled = newValue
        }
        get {
            return pagingView.isPagingEnabled
        }
    }
    
    var _showSlider: Bool = false
    public var showSlider: Bool {
        set {
            _showSlider = newValue
            if showSlider, pagingView.direction.isHorizontal() {
                navigationController?.setToolbarHidden(true, animated: true)
            }
            updateHudPosition()
            applySliderTintColor()
        }
        get {
            return _showSlider
        }
    }
    
    public var automaticBarsHiddenDuration: TimeInterval = 0
    public var restoreBarState: Bool = true
    
    var _showPageNumberHud: Bool = false
    public var showPageNumberHud: Bool {
        set {
            _showPageNumberHud = newValue
            if _showPageNumberHud == true {
                view.addSubview(currentPageHud)
            }
            else {
                currentPageHud.removeFromSuperview()
            }
        }
        get {
            return _showPageNumberHud
        }
    }
    
    public var contents: [RDPageContentData] = []
    
    var previousPageIndex: Int = 0
    var _statusBarHidden: Bool = false
    open var statusBarHidden: Bool {
        set {
            _statusBarHidden = newValue
            setNeedsStatusBarAppearanceUpdate()
        }
        get {
            return _statusBarHidden
        }
    }
    var feedbackGenerator = UISelectionFeedbackGenerator()
    var currentPageHudLabel: UILabel
    
    public var pagingView: RDPagingView
    public var pageSlider: UISlider
    public var currentPageHud: UIView
    
    private var _pageSliderMaximumTrackTintColor: UIColor?
    public var pageSliderMaximumTrackTintColor: UIColor? {
        set {
            _pageSliderMaximumTrackTintColor = newValue
            applySliderTintColor()
        }
        get {
            return _pageSliderMaximumTrackTintColor
        }
    }
    private var _pageSliderMinimumTrackTintColor: UIColor?
    public var pageSliderMinimumTrackTintColor: UIColor? {
        set {
            _pageSliderMinimumTrackTintColor = newValue
            applySliderTintColor()
        }
        get {
            return _pageSliderMinimumTrackTintColor
        }
    }
    
    static let PageHudLabelFontSize: CGFloat = 17
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let sizeClass = traitCollection.verticalSizeClass
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            if self.traitCollection.verticalSizeClass != sizeClass {
                let duration = context.transitionDuration
                self.pagingView.resize(with: CGRect(x: 0, y: 0, width: size.width, height: size.height), duration: duration)
            }
            var toolbarPosition = self.view.frame.height
            if let toolbarItems = self.toolbarItems, toolbarItems.count > 0 {
                toolbarPosition = self.navigationController?.toolbar.frame.minY ?? self.view.frame.height
            }
            self.updateHudHorizontalPosition(position: toolbarPosition)
        })
    }
    
    public init(contents: [RDPageContentData], direction: RDPagingView.ForwardDirection) {
        self.currentPageHud = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        self.currentPageHudLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: RDImageViewerController.PageHudLabelFontSize))
        self.feedbackGenerator.prepare()
        self.contents = contents
        self.pagingView = RDPagingView(frame: CGRect.zero, forwardDirection: direction)
        self.pageSlider = UISlider(frame: CGRect.zero)
        super.init(nibName: nil, bundle: nil)
        self.pagingView.pagingDataSource = self
        self.pagingView.pagingDelegate = self
        self.view.addSubview(self.pagingView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        for data in contents {
            switch data.type {
            case let .class(cellClass):
                pagingView.register(cellClass, forCellWithReuseIdentifier: data.reuseIdentifier())
            case let .nib(cellNib):
                pagingView.register(cellNib, forCellWithReuseIdentifier: data.reuseIdentifier())
            }
        }
        automaticallyAdjustsScrollViewInsets = false
        
        pagingView.frame = view.bounds
        pagingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pagingView.backgroundColor = UIColor.black
        pagingView.isDirectionalLockEnabled = true
        pagingView.tag = ViewTag.pageScrollView.rawValue
        pagingView.showsHorizontalScrollIndicator = false
        pagingView.showsVerticalScrollIndicator = false
        pagingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setBarHiddenByTapGesture)))
        if pagingView.direction.isHorizontal() {
            pagingView.isPagingEnabled = true
        }
        
        pageSlider.frame = CGRect(x: 0, y: 0, width: view.frame.width - 30, height: 31)
        pageSlider.autoresizingMask = [.flexibleWidth]
        pageSlider.addTarget(self, action: #selector(sliderValueDidChange(slider:)), for: .valueChanged)
        pageSlider.addTarget(self, action: #selector(sliderDidTouchUpInside(slider:)), for: .touchUpInside)
        toolbarItems = [UIBarButtonItem(customView: pageSlider)]
        
        let x = view.center.x - currentPageHud.frame.width / 2.0
        var y = view.frame.height - currentPageHud.frame.height - 10
        if let toolbarItems = toolbarItems {
            if toolbarItems.count > 0 {
                y -= 50
            }
        }
        currentPageHud.frame = CGRect(x: x, y: y, width: currentPageHud.frame.width, height: currentPageHud.frame.height)
        currentPageHud.alpha = 0
        currentPageHud.clipsToBounds = true
        currentPageHud.layer.cornerRadius = 15
        currentPageHud.layer.borderColor = UIColor.white.cgColor
        currentPageHud.layer.borderWidth = 1
        currentPageHud.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = self.currentPageHud.bounds
        currentPageHud.addSubview(blurView)
        
        currentPageHudLabel.backgroundColor = UIColor.clear
        currentPageHudLabel.font = UIFont.systemFont(ofSize: RDImageViewerController.PageHudLabelFontSize)
        currentPageHudLabel.textColor = UIColor.white
        currentPageHudLabel.textAlignment = .center
        currentPageHudLabel.center = CGPoint(x: currentPageHud.bounds.width / 2, y: currentPageHud.bounds.height / 2)
        currentPageHudLabel.tag = ViewTag.currentPageLabel.rawValue
        currentPageHud.addSubview(currentPageHudLabel)
        
//        pagingView.reloadData()
        updateSliderValue()
        applySliderTintColor()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if restoreBarState == true {
            setBarsHidden(hidden: !showSlider, animated: animated)
            setHudHidden(hidden: !showPageNumberHud, animated: false)
        }

        updateHudPosition()
        refreshPageHud()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if automaticBarsHiddenDuration > 0 {
            perform(#selector(hideBars), with: self, afterDelay: automaticBarsHiddenDuration)
            automaticBarsHiddenDuration = 0
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelAutoBarHidden()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pagingView.pagingDataSource = nil
        pagingView.pagingDelegate = nil
    }
    
    func updateHudPosition() {
        var toolbarPosition = view.frame.height
        if let toolbarItems = toolbarItems, toolbarItems.count > 0 {
            toolbarPosition = navigationController?.toolbar.frame.minY ?? view.frame.height
        }
        updateHudHorizontalPosition(position: toolbarPosition)
    }
    
    func updateSliderValue() {
        if pagingView.direction.isHorizontal() {
            if pagingView.direction == .right {
                pageSlider.value = Float(pagingView.currentPageIndex) / Float(contents.count - 1)
            }
            else {
                pageSlider.value = 1.0 - Float(pagingView.currentPageIndex) / Float(contents.count - 1)
            }
        }
    }
    
    open func updateCurrentPageHudLabel(page: Int, denominator: Int) {
        currentPageHudLabel.text = "\(page)/\(denominator)"
    }
    
    @objc open func setBarHiddenByTapGesture() {
        cancelAutoBarHidden()
        setBarsHidden(hidden: !statusBarHidden, animated: true)
    }
    
    @objc func sliderValueDidChange(slider: UISlider) {
//        cancelAutoBarHidden()
//        let trueValue = pagingView.direction == .left ? slider.value : 1.0 - slider.value
//        let page = Int(trueValue * Float(contents.count - 1))
//        if currentPageIndex != page {
//            feedbackGenerator.selectionChanged()
//        }
//        scrollAt(index: page)
    }
    
    @objc func sliderDidTouchUpInside(slider: UISlider) {
        let value = Float(pagingView.currentPageIndex / (contents.count - 1))
        let trueValue = pagingView.direction == .right ? value : 1 - value
        slider.setValue(trueValue, animated: true)
    }
    
    public func reloadView(at index: Int) {
        if contents.count > index {
            let data = contents[index]
            data.reload()
            refreshView(at: index)
        }
    }
    
    public func refreshView(at index: Int) {
        if contents.count > index {
            pagingView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    func    scrollAt(index: Int) {
        if contents.count <= index {
            return
        }
        if pagingView.direction.isHorizontal() {
            pagingView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
        else {
            pagingView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: true)
        }
    }

    open func refreshPageHud() {
        currentPageIndex = pagingView.currentPageIndex
    }
    
    @objc open func hideBars() {
        setBarsHidden(hidden: true, animated: true)
    }
    
    open func setBarsHidden(hidden: Bool, animated: Bool) {
        if let toolbarItems = toolbarItems, toolbarItems.count > 0 {
            if showSlider, pagingView.direction.isHorizontal() {
                navigationController?.setToolbarHidden(hidden, animated: animated)
            }
        }
        
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
        setHudHidden(hidden: hidden, animated: animated)
        statusBarHidden = hidden
    }
    
    open func setHudHidden(hidden: Bool, animated: Bool) {
        var duration: CGFloat = 0
        if animated {
            duration = UINavigationController.hideShowBarDuration
        }
        UIView.animate(withDuration: TimeInterval(duration), animations: { [unowned self] in
            var toolbarPositionY = self.view.frame.height
            if let toolbarItems = self.toolbarItems, toolbarItems.count > 0 {
                toolbarPositionY = self.navigationController?.toolbar.frame.minY ?? self.view.frame.height
            }
            self.updateHudHorizontalPosition(position: toolbarPositionY)
            self.currentPageHud.alpha = hidden == true ? 0 : 1.0
        }, completion: nil)
    }
    
    func updateHudHorizontalPosition(position: CGFloat) {
        currentPageHud.frame = CGRect(x: view.center.x - currentPageHud.frame.width / 2.0, y: position - currentPageHud.frame.height - 10, width: currentPageHud.frame.width, height: currentPageHud.frame.height)
    }
    
    open func cancelAutoBarHidden() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideBars), object: self)
    }
    
    func applySliderTintColor() {
        var maximumTintColor = UIColor(red: 0, green: (122.0 / 255.0), blue: 1, alpha: 1)
        if let tintColor = pageSliderMaximumTrackTintColor {
            maximumTintColor = tintColor
        }
        
        var minimumTintColor = UIColor.white
        if let tintColor = pageSliderMinimumTrackTintColor {
            minimumTintColor = tintColor
        }
        
        pageSlider.maximumTrackTintColor = pagingView.direction == .left ? maximumTintColor : minimumTintColor
        pageSlider.minimumTrackTintColor = pagingView.direction == .left ? minimumTintColor : maximumTintColor
    }
}

extension RDImageViewerController : UICollectionViewDelegate
{
    
}

extension RDImageViewerController : UICollectionViewDataSource
{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = contents[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.reuseIdentifier(), for: indexPath) as! RDPageContentDataView & UICollectionViewCell
        cell.configure(data: data)
        if let imageScrollView = cell as? RDImageScrollView {
            pagingView.gestureRecognizers?.forEach({ (gesture) in
                if gesture is UITapGestureRecognizer {
                    imageScrollView.addGestureRecognizerPriorityHigherThanZoomGestureRecogniser(gesture: gesture)
                }
            })
        }
        
        return cell
    }
}

extension RDImageViewerController : UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width, height: view.bounds.height)
    }
}

extension RDImageViewerController
{
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


extension RDImageViewerController: RDPagingViewDelegate
{
    @objc public func pagingView(pagingView: RDPagingView, willChangeIndexTo index: Int) {
        updateCurrentPageHudLabel(page: index, denominator: contents.count)
    }
    
    @objc public func pagingView(pagingView: RDPagingView, didScrollToPosition position: CGFloat) {
        if pageSlider.state == .normal {
            let p = contents.count - 1
            pageSlider.value = Float(position / CGFloat(p))
        }
    }

    @objc public func pagingViewWillBeginDragging(pagingView: RDPagingView) {
        if pagingView.isDragging == false {
            previousPageIndex = currentPageIndex
        }
    }
    
    @objc public func pagingViewDidEndDecelerating(pagingView: RDPagingView) {
        let page = currentPageIndex
        for view in pagingView.subviews {
            if view.isKind(of: UIScrollView.self) {
                let scrollView = view as! UIScrollView
                if pagingView.isPagingEnabled == true, page != previousPageIndex {
                    scrollView.zoomScale = 1.0
                }
                else if previousPageIndex == pagingView.currentPageIndex - 2 || previousPageIndex == pagingView.currentPageIndex + 2 {
                    scrollView.zoomScale = 1.0
                }
            }
        }
    }
}

extension RDImageViewerController: RDPagingViewDataSource
{
    public func pagingView(pagingView: RDPagingView, preloadItemAt index: Int) {
        if contents.count > index {
            let data = contents[index]
            if data.isPreloadable() {
                data.preload()
            }
        }
    }
}
