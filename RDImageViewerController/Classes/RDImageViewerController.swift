//
//  RDImageViewerController.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

public protocol HudBehaviour {
    func updateLabel(label: UILabel, pagingView: PagingView)
}

@objcMembers
public class DoubleSidedConfiguration {
    public var portrait: Bool = false
    public var landscape: Bool = false
    
    public init(portrait: Bool, landscape: Bool) {
        self.portrait = portrait
        self.landscape = landscape
    }
}

@objcMembers
open class RDImageViewerController: UIViewController {

    enum ViewTag : Int {
        case mainScrollView = 1
        case pageScrollView = 2
        case currentPageLabel = 3
    }

    static let pageHudLabelFontSize: CGFloat = 17
    
    var tempPageIndex = 0
    var viewIsDisappeared = false
    var previousPageIndex: Int = 0
    var feedbackGenerator = UISelectionFeedbackGenerator()
    var didRotate: Bool = false
    var pageHud: PageHud
    
    private var _doubleSidedConfiguration = DoubleSidedConfiguration(portrait: false, landscape: false)
    public var doubleSidedConfiguration: DoubleSidedConfiguration {
        get {
            return _doubleSidedConfiguration
        }
        set {
            _doubleSidedConfiguration = newValue
            pagingView.isDoubleSided = isDoubleSided
        }
    }
    public var isSliderEnabled: Bool = true
    public var automaticBarsHiddenDuration: TimeInterval = 0
    public var restoreBarState: Bool = true
    public var isPageNumberHudEnabled: Bool = true
    public var contents: [PageContent] = []
    public var pagingView: PagingView
    public var pageSlider: UISlider
    
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

    public var isDoubleSided: Bool {
        get {
            if UIDevice.current.orientation.isLandscape {
                return doubleSidedConfiguration.landscape
            }
            return doubleSidedConfiguration.portrait
        }
    }

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
    
    var _showPageNumberHud: Bool = false
    public var showPageNumberHud: Bool {
        set {
            setHudHidden(hidden: !newValue, animated: true)
        }
        get {
            return _showPageNumberHud
        }
    }
    
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
        print("viewWillTransition")
        didRotate = true
        
        guard let flowLayout = pagingView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let visiblePageIndex = pagingView.visiblePageIndexes.sorted().first!
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            print("viewDidTransition")
            flowLayout.invalidateLayout()
            self.pagingView.isDoubleSided = self.isDoubleSided
            self.pagingView.resizeVisiblePages()
            self.pagingView.scrollTo(index: visiblePageIndex)
            UIView.animate(withDuration: context.transitionDuration) {
                self.updateHudPosition()
            }
        }) { [unowned self] (context) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("viewDidTransition - complete \(self.pagingView.visiblePageIndexes.sorted())")
                self.updateCurrentPageHudLabel()
            }
        }
        
//        let offset = pagingView.contentOffset
//        let width  = pagingView.bounds.size.width
//
//        let index = round(offset.x / width)
//        didRotate = true
//        coordinator.animate(alongsideTransition: { [unowned self] (context) in
//            for cell in self.pagingView.visibleCells {
//                let cell = cell as! RDPageViewProtocol & UICollectionViewCell
//                cell.resize()
//            }
//
//            self.pagingView.scrollTo(index: Int(index))
//
//            UIView.animate(withDuration: context.transitionDuration, animations: {
//                self.updateHudPosition()
//                self.updateCurrentPageHudLabel()
//            })
//        })
    }

    public init(contents: [PageContent], direction: PagingView.ForwardDirection) {
        self.pageHud = PageHud(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        self.feedbackGenerator.prepare()
        self.contents = contents
        self.pagingView = PagingView(frame: CGRect.zero, forwardDirection: direction)
        self.pageSlider = UISlider(frame: CGRect.zero)
        super.init(nibName: nil, bundle: nil)
        self.pagingView.pagingDataSource = self
        self.pagingView.pagingDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        updateHudPosition()
        view.addSubview(pagingView)
        view.addSubview(pageHud)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setBarHiddenByTapGesture)))
        
        pagingView.frame = view.bounds
        pagingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pagingView.backgroundColor = UIColor.black
        pagingView.isDirectionalLockEnabled = true
        pagingView.tag = ViewTag.pageScrollView.rawValue
        pagingView.showsHorizontalScrollIndicator = false
        pagingView.showsVerticalScrollIndicator = false
        pagingView.isDoubleSided = isDoubleSided
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
        let sliderItem = UIBarButtonItem(customView: pageSlider)
        toolbarItems = [sliderItem]
        
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
        tempPageIndex = currentPageIndex
        viewIsDisappeared = true
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if viewIsDisappeared {
            // update slider position
            pageSlider.frame = CGRect(x: pageSlider.frame.minX, y: pageSlider.frame.minY, width: view.frame.width - 30, height: 31)
            
            // update hud position
            updateHudPosition()
            
            if pagingView.direction.isHorizontal() {
                // restore page index
                currentPageIndex = tempPageIndex
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
        if didRotate {
            // update cell size
            pagingView.resizeVisiblePages()
            
            if viewIsDisappeared == false {
                // restore page index when rotate
                let offset = pagingView.contentOffset
                let width = pagingView.bounds.size.width
                let index = Int(round(offset.x / width))
                currentPageIndex = numberOfPages - index
                updateSliderValue()
            }
            else if pagingView.direction.isHorizontal() {
                currentPageIndex = pagingView.currentPageIndex
                updateCurrentPageHudLabel()
                updateSliderValue()
            }
            
            didRotate = false
        }
        else {
            updateCurrentPageHudLabel()
        }
        
        if viewIsDisappeared {
            viewIsDisappeared = false
        }
    }
    
    @available(iOS 11.0, *)
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateHudPosition()
    }
    
    // MARK: - slider
    @objc func sliderValueDidChange(slider: UISlider) {
        cancelAutoBarHidden()
        let position = trueSliderValue(value: slider.value)
        let pageIndex = position * Float(numberOfPages - 1)
        let truePageIndex = Int(pageIndex + 0.5)
        if currentPageIndex != truePageIndex {
            feedbackGenerator.selectionChanged()
        }
        currentPageIndex = truePageIndex
    }
    
    @objc func sliderDidTouchUpInside(slider: UISlider) {
        let position = trueSliderValue(value: Float(currentPageIndex) / Float(numberOfPages - 1))
        slider.setValue(position, animated: false)
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
        return pagingView.direction == .right ? value : 1 - value
    }
    
    // MARK: - bars
    @objc open func setBarHiddenByTapGesture() {
        cancelAutoBarHidden()
        setBarsHidden(hidden: !statusBarHidden, animated: true)
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
    
    open func cancelAutoBarHidden() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideBars), object: self)
    }
    
    // MARK: - hud
    open func updateCurrentPageHudLabel() {
        if isDoubleSided {
            var pageString = pagingView.visiblePageIndexes.sorted().map({ (index) -> String in
                return String(index + 1)
                }).joined(separator: " - ")
            if pagingView.visiblePageIndexes.count > 1 {
                pageString = "[" + pageString + "]"
            }
            updateCurrentPageHudLabel(pageString: pageString, denominator: numberOfPages)
        }
        else {
            updateCurrentPageHudLabel(page: currentPageIndex + 1, denominator: numberOfPages)
        }
    }
    
    open func updateCurrentPageHudLabel(page: Int, denominator: Int) {
        pageHud.label.text = "\(page)/\(denominator)"
    }
    
    open func updateCurrentPageHudLabel(pageString: String, denominator: Int) {
        pageHud.label.text = "\(pageString)/\(denominator)"
    }
    
    func updateHudPosition() {
        var toolbarPosition = view.frame.height
        if isSliderEnabled, showSlider, let toolbarItems = toolbarItems, toolbarItems.count > 0 {
            toolbarPosition = navigationController?.toolbar.frame.minY ?? view.frame.height
        }
        else if #available(iOS 11.0, *) {
            toolbarPosition = toolbarPosition - bottomLayoutGuide.length
        }
        updateHudVerticalPosition(position: toolbarPosition)
    }

    func updateHudVerticalPosition(position: CGFloat) {
        let horizontalPosition = view.center.x - pageHud.frame.width / 2.0
        let verticalPosition = position - pageHud.frame.height - 10
        pageHud.frame = CGRect(x: horizontalPosition, y: verticalPosition, width: pageHud.frame.width, height: pageHud.frame.height)
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
            self.pageHud.alpha = hidden == true ? 0 : 1.0
            self.updateHudPosition()
        })
    }
        
    // MARK: - appearance
    func applySliderTintColor() {
        var maximumTintColor = UIColor(red: 0, green: (122.0 / 255.0), blue: 1, alpha: 1)
        if let tintColor = pageSliderMaximumTrackTintColor {
            maximumTintColor = tintColor
        }
        
        var minimumTintColor = UIColor.white
        if let tintColor = pageSliderMinimumTrackTintColor {
            minimumTintColor = tintColor
        }
        
        if pagingView.direction == .left {
            pageSlider.maximumTrackTintColor = maximumTintColor
            pageSlider.minimumTrackTintColor = minimumTintColor
        }
        else {
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
        updateHudPosition()
        updateCurrentPageHudLabel()
        updateSliderValue()
    }
    
    open func update(contents newContents: [PageContent]) {
        contents = newContents
        reloadData()
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
    
    open func changeDirection(_ forwardDirection: PagingView.ForwardDirection) {
        pagingView.changeDirection(forwardDirection)
        if pagingView.direction.isHorizontal() {
            pagingView.isPagingEnabled = true
        }
        else {
            pagingView.isPagingEnabled = false
        }
    }
}

// MARK: - UICollectionViewDataSource
extension RDImageViewerController : UICollectionViewDataSource
{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPages
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = contents[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.reuseIdentifier(), for: indexPath) as! PageViewProtocol & UICollectionViewCell
        cell.configure(data: data, pageIndex: indexPath.row, traitCollection: traitCollection, doubleSided: isDoubleSided)
        cell.resize()
        if let imageScrollView = cell as? ImageScrollView {
            pagingView.gestureRecognizers?.forEach({ (gesture) in
                if gesture is UITapGestureRecognizer {
                    imageScrollView.addGestureRecognizerPriorityHigherThanZoomGestureRecogniser(gesture: gesture)
                }
            })
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RDImageViewerController : UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = contents[indexPath.row]
        return data.size(inRect: collectionView.bounds, direction: pagingView.direction, traitCollection: traitCollection, doubleSided: isDoubleSided)
    }
}

// MARK: - RDPagingViewDelegate
extension RDImageViewerController: RDPagingViewDelegate
{
    @objc open func pagingView(pagingView: PagingView, willChangeIndexTo index: Int) {
        if pagingView.direction.isVertical() {
            if isDoubleSided {
                updateCurrentPageHudLabel()
            }
            else {
                updateCurrentPageHudLabel(page: index + 1, denominator: numberOfPages)
            }
        }
    }
    
    @objc open func pagingView(pagingView: PagingView, didScrollToPosition position: CGFloat) {
        if pagingView.direction.isHorizontal() {
            if pageSlider.state == .normal {
                let value = position / CGFloat(numberOfPages - 1)
                pageSlider.value = Float(trueSliderValue(value: Float(value)))
            }
            
            let to = Int(position + 0.5)
            updateCurrentPageHudLabel(page: to + 1, denominator: numberOfPages)
        }
    }

    @objc open func pagingViewWillBeginDragging(pagingView: PagingView) {
        if pagingView.isDragging == false {
            previousPageIndex = currentPageIndex
        }
    }
    
    @objc open func pagingViewDidEndDecelerating(pagingView: PagingView) {
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

// MARK: - RDPagingViewDataSource
extension RDImageViewerController: RDPagingViewDataSource
{
    open func pagingView(pagingView: PagingView, preloadItemAt index: Int) {
        let data = contents[index]
        if data.isPreloadable() && !data.isPreloading() {
            data.preload()
        }
    }
    
    open func pagingView(pagingView: PagingView, cancelPreloadingItemAt index: Int) {
        let data = contents[index]
        if data.isPreloadable(), data.isPreloading() {
            data.stopPreload()
        }
    }
}

// MARK: - ViewController
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
