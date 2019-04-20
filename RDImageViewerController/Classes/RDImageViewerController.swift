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
            pagingView.currentPageIndex = newValue
            updateCurrentPageHudLabel()
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
    
    public var isSliderEnabled: Bool = true
    var _showSlider: Bool = false
    public var showSlider: Bool {
        set {
            if pagingView.direction.isHorizontal() {
                setToolBarHidden(hidden: !newValue, animated: true)
            }
            else {
                setToolBarHidden(hidden: true, animated: true)
            }
            applySliderTintColor()
        }
        get {
            return _showSlider
        }
    }
    
    public var automaticBarsHiddenDuration: TimeInterval = 0
    public var restoreBarState: Bool = true
    
    public var isPageNumberHudEnabled: Bool = true
    var _showPageNumberHud: Bool = false
    public var showPageNumberHud: Bool {
        set {
            setHudHidden(hidden: !newValue, animated: true)
        }
        get {
            return _showPageNumberHud
        }
    }
    private func registerPageNumberHud(_ register: Bool) {
        if register == true {
            view.addSubview(currentPageHud)
        }
        else {
            currentPageHud.removeFromSuperview()
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
    var didRotate: Bool = false
    
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
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let offset = pagingView.contentOffset
        let width  = pagingView.bounds.size.width

        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        pagingView.setContentOffset(newOffset, animated: false)
        pagingView.reloadData()
        didRotate = true
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            self.pagingView.reloadData()
            self.pagingView.setContentOffset(newOffset, animated: false)
            UIView.animate(withDuration: context.transitionDuration, animations: {
                self.updateHudPosition()
                self.updateCurrentPageHudLabel()
            })
        })
    }

    static let pageHudLabelFontSize: CGFloat = 17
    public init(contents: [RDPageContentData], direction: RDPagingView.ForwardDirection) {
        self.currentPageHud = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        self.currentPageHudLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: RDImageViewerController.pageHudLabelFontSize))
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
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setBarHiddenByTapGesture)))
        
        pagingView.frame = view.bounds
        pagingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pagingView.backgroundColor = UIColor.black
        pagingView.isDirectionalLockEnabled = true
        pagingView.tag = ViewTag.pageScrollView.rawValue
        pagingView.showsHorizontalScrollIndicator = false
        pagingView.showsVerticalScrollIndicator = false
        if pagingView.direction.isHorizontal() {
            pagingView.isPagingEnabled = true
        }
        
        if #available(iOS 11.0, *) {
            pagingView.contentInsetAdjustmentBehavior = .never
        }
        else {
            automaticallyAdjustsScrollViewInsets = false
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
        currentPageHudLabel.font = UIFont.systemFont(ofSize: RDImageViewerController.pageHudLabelFontSize)
        currentPageHudLabel.textColor = UIColor.white
        currentPageHudLabel.textAlignment = .center
        currentPageHudLabel.center = CGPoint(x: currentPageHud.bounds.width / 2, y: currentPageHud.bounds.height / 2)
        currentPageHudLabel.tag = ViewTag.currentPageLabel.rawValue
        currentPageHud.addSubview(currentPageHudLabel)
        
        currentPageIndex = 0
        registerContents()
        applySliderTintColor()
        updateSliderValue()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        if restoreBarState == true {
            setNavigationBarHidden(hidden: navigationController?.isNavigationBarHidden ?? false, animated: true)
            setToolBarHidden(hidden: !showSlider, animated: true)
            setHudHidden(hidden: !showPageNumberHud, animated: false)
        }
        updateCurrentPageHudLabel()
        registerPageNumberHud(true)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if automaticBarsHiddenDuration > 0 {
            perform(#selector(hideBars), with: self, afterDelay: automaticBarsHiddenDuration)
            automaticBarsHiddenDuration = 0
        }
    }
    
    var tempPageIndex = 0
    var viewIsDisappeared = false
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelAutoBarHidden()
        tempPageIndex = currentPageIndex
        viewIsDisappeared = true
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if viewIsDisappeared {
            currentPageIndex = tempPageIndex
            viewIsDisappeared = false
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if didRotate {
            let offset = pagingView.contentOffset
            let width = pagingView.bounds.size.width
            
            let index = Int(round(offset.x / width))
            currentPageIndex = numberOfPages - index
            updateCurrentPageHudLabel()
            updateSliderValue()
            didRotate = false
        }
        else {
            updateCurrentPageHudLabel()
        }
    }

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
        updateHudPosition()
        updateCurrentPageHudLabel()
        updateSliderValue()
    }
    
    open func update(contents newContents: [RDPageContentData]) {
        contents = newContents
        reloadData()
    }
    
    func updateHudPosition() {
        var toolbarPosition = view.frame.height
        if isSliderEnabled, showSlider, let toolbarItems = toolbarItems, toolbarItems.count > 0 {
            toolbarPosition = navigationController?.toolbar.frame.minY ?? view.frame.height
        }
        updateHudHorizontalPosition(position: toolbarPosition)
    }
    
    func updateSliderValue() {
        if pagingView.direction.isHorizontal() {
            if pagingView.direction == .left {
                pageSlider.value = 1.0 - Float(currentPageIndex) / Float(numberOfPages - 1)
            }
            else {
                pageSlider.value = Float(currentPageIndex) / Float(numberOfPages - 1)
            }
        }
    }
    
    func trueSliderValue(value: Float) -> Float {
        if pagingView.isLegacyLayoutSystem {
            return value
        }
        return pagingView.direction == .right ? value : 1 - value
    }
    
    open func updateCurrentPageHudLabel() {
        updateCurrentPageHudLabel(page: currentPageIndex + 1, denominator: numberOfPages)
    }
    
    open func updateCurrentPageHudLabel(page: Int, denominator: Int) {
        currentPageHudLabel.text = "\(page)/\(denominator)"
    }
    
    @objc open func setBarHiddenByTapGesture() {
        cancelAutoBarHidden()
        setBarsHidden(hidden: !statusBarHidden, animated: true)
    }
    
    @objc func sliderValueDidChange(slider: UISlider) {
        cancelAutoBarHidden()
        let position = trueSliderValue(value: slider.value)
        let pageIndex = position * Float(numberOfPages - 1)
        let truePageIndex = Int(pageIndex + 0.5)
        if currentPageIndex != truePageIndex {
            feedbackGenerator.selectionChanged()
        }
        
        if pagingView.isLegacyLayoutSystem {
            let newPageIndex = (1.0 - position) * Float(numberOfPages - 1)
            pagingView.scrollTo(index: Int(newPageIndex + 0.5))
            slider.setValue(position, animated: false)
            updateCurrentPageHudLabel()
        }
        else {
            currentPageIndex = truePageIndex
        }
    }
    
    @objc func sliderDidTouchUpInside(slider: UISlider) {
        let position = trueSliderValue(value: Float(currentPageIndex) / Float(numberOfPages - 1))
        if pagingView.isLegacyLayoutSystem {
            slider.setValue(1.0 - ((1.0 / Float(numberOfPages - 1)) * Float(currentPageIndex)), animated: false)
        }
        else {
            slider.setValue(position, animated: false)
        }
    }
    
    public func reloadView(at index: Int) {
        if numberOfPages > index {
            let data = contents[index]
            data.reload()
            refreshView(at: index)
        }
    }
    
    public func refreshView(at index: Int) {
        if numberOfPages > index {
            pagingView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    @objc open func hideBars() {
        setBarsHidden(hidden: true, animated: true)
    }
    
    open func setNavigationBarHidden(hidden: Bool, animated: Bool) {
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }
    
    open func setToolBarHidden(hidden: Bool, animated: Bool) {
        _showSlider = !hidden
        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration), animations: { [unowned self] in
                self.updateHudPosition()
            })
        }
        else {
            updateHudPosition()
        }
        if isSliderEnabled == false {
            return
        }
        if let toolbarItems = toolbarItems, toolbarItems.count > 0 {
            navigationController?.setToolbarHidden(hidden, animated: animated)
        }
    }
    
    open func setBarsHidden(hidden: Bool, animated: Bool) {
        setToolBarHidden(hidden: hidden, animated: animated)
        setNavigationBarHidden(hidden: hidden, animated: animated)
        setHudHidden(hidden: hidden, animated: animated)
        statusBarHidden = hidden
    }
    
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
            self.currentPageHud.alpha = hidden == true ? 0 : 1.0
            self.updateHudPosition()
        })
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
        
        if pagingView.direction == .left || pagingView.isLegacyLayoutSystem {
            pageSlider.maximumTrackTintColor = maximumTintColor
            pageSlider.minimumTrackTintColor = minimumTintColor
        }
        else {
            pageSlider.maximumTrackTintColor = minimumTintColor
            pageSlider.minimumTrackTintColor = maximumTintColor
        }
    }
}

extension RDImageViewerController : UICollectionViewDataSource
{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPages
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = contents[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.reuseIdentifier(), for: indexPath) as! RDPageContentDataViewProtocol & UICollectionViewCell
        cell.configure(data: data)
        cell.resize()
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
        let data = contents[indexPath.row]
        return data.size(inRect: collectionView.bounds, direction: pagingView.direction)
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
    @objc open func pagingView(pagingView: RDPagingView, willChangeIndexTo index: Int) {
        if pagingView.direction.isVertical() {
            updateCurrentPageHudLabel(page: index + 1, denominator: numberOfPages)
        }
    }
    
    @objc open func pagingView(pagingView: RDPagingView, didScrollToPosition position: CGFloat) {
        if pagingView.direction.isHorizontal() {
            if pageSlider.state == .normal {
                let value = position / CGFloat(numberOfPages - 1)
                pageSlider.value = Float(trueSliderValue(value: Float(value)))
            }
            
            let to = Int(position + 0.5)
            if pagingView.isLegacyLayoutSystem {
                updateCurrentPageHudLabel(page: numberOfPages - to, denominator: numberOfPages)
            }
            else {
                updateCurrentPageHudLabel(page: to + 1, denominator: numberOfPages)
            }
        }
    }

    @objc open func pagingViewWillBeginDragging(pagingView: RDPagingView) {
        if pagingView.isDragging == false {
            previousPageIndex = currentPageIndex
        }
    }
    
    @objc open func pagingViewDidEndDecelerating(pagingView: RDPagingView) {
        let page = currentPageIndex
        for view in pagingView.subviews {
            if view.isKind(of: UIScrollView.self) {
                let scrollView = view as! UIScrollView
                if pagingView.isPagingEnabled == true, page != previousPageIndex {
                    scrollView.zoomScale = 1.0
                }
                else if previousPageIndex == currentPageIndex - 2 || previousPageIndex == currentPageIndex + 2 {
                    scrollView.zoomScale = 1.0
                }
            }
        }
    }
}

extension RDImageViewerController: RDPagingViewDataSource
{
    open func pagingView(pagingView: RDPagingView, preloadItemAt index: Int) {
        let data = contents[index]
        if data.isPreloadable() {
            data.preload()
        }
    }
    
    open func pagingView(pagingView: RDPagingView, cancelPreloadingItemAt index: Int) {
        let data = contents[index]
        if data.isPreloadable() {
            data.stopPreload()
        }
    }
}
