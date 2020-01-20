//
//  RDImageViewerController.swift
//  Pods-RDImageViewerController
//
//  Created by Akira Matsuda on 2019/04/07.
//

import UIKit

public protocol HudBehaviour
{
    func updateLabel(label: UILabel, pagingView: PagingView, denominator: Int)
    func updateLabel(label: UILabel, numerator: Int, denominator: Int)
}

public protocol PagingBehaviour
{
    func updatePageIndex(_ index: Int, pagingView: PagingView)
}

public protocol SliderBehaviour
{
    func updateSliderPosition(slider: UISlider, value: Float, pagingView: PagingView)
    func snapSliderPosition(slider: UISlider, pagingView: PagingView)
}

extension UISlider
{
    public func trueSliderValue(value: Float, pagingView: PagingView) -> Float {
        return pagingView.scrollDirection == .right ? value : 1 - value
    }
    
    public func setTrueSliderValue(value: Float, pagingView: PagingView, animated: Bool = false) {
        let position = trueSliderValue(value: value, pagingView: pagingView)
        setValue(position, animated: animated)
    }
}

open class SinglePageBehaviour: HudBehaviour, SliderBehaviour, PagingBehaviour
{
    public init() {}
    
    open func updateLabel(label: UILabel, pagingView: PagingView, denominator: Int) {
        label.text = "\(pagingView.currentPageIndex.primaryIndex() + 1)/\(denominator)"
    }
    
    open func updateLabel(label: UILabel, numerator: Int, denominator: Int) {
        label.text = "\(numerator)/\(denominator)"
    }
    
    open func updateSliderPosition(slider: UISlider, value: Float, pagingView: PagingView) {
        let position = value / Float(pagingView.numberOfPages - 1)
        slider.setTrueSliderValue(value: Float(position), pagingView: pagingView)
    }
    
    open func snapSliderPosition(slider: UISlider, pagingView: PagingView) {
        if pagingView.scrollDirection.isVertical() {
            return
        }
        let value = Float(pagingView.currentPageIndex.primaryIndex()) / Float(pagingView.numberOfPages - 1)
        slider.setTrueSliderValue(value:value, pagingView: pagingView)
    }
    
    open func updatePageIndex(_ index: Int, pagingView: PagingView) {
        pagingView.currentPageIndex = index.single()
    }
}

open class DoubleSpreadPageBehaviour: HudBehaviour, SliderBehaviour, PagingBehaviour
{
    public init() {}
    
    open func updateLabel(label: UILabel, pagingView: PagingView, denominator: Int) {
        var pageString = pagingView.visiblePageIndexes.sorted().map({ (index) -> String in
            return String(index + 1)
            }).joined(separator: " - ")
        if pagingView.visiblePageIndexes.count > 1 {
            pageString = "[" + pageString + "]"
        }
        label.text = "\(pageString)/\(denominator)"
    }
    
    open func updateLabel(label: UILabel, numerator: Int, denominator: Int) {
        // do nothing
    }
    
    open func updateSliderPosition(slider: UISlider, value: Float, pagingView: PagingView) {
        let snapPosition = (value - 0.5) * 2
        if pagingView.numberOfPages % 2 == 1 {
            if snapPosition > Float(pagingView.numberOfPages - 4) {
                let position = value * 2 / Float(pagingView.numberOfPages - 2)
                slider.setTrueSliderValue(value: position, pagingView: pagingView, animated: true)
            }
            else {
                let position = value * 2 / Float(pagingView.numberOfPages - 1)
                slider.setTrueSliderValue(value: Float(position), pagingView: pagingView, animated: true)
            }
        }
        else {
            let position = value * 2 / Float(pagingView.numberOfPages - 2)
            slider.setTrueSliderValue(value: Float(position), pagingView: pagingView)
        }
    }
    
    open func snapSliderPosition(slider: UISlider, pagingView: PagingView) {
        if pagingView.scrollDirection.isVertical() {
            return
        }
        if case let .double(indexes) = pagingView.currentPageIndex, indexes.count > 0 {
            if pagingView.numberOfPages % 2 == 1 {
                let index = indexes.sorted().first!
                let value = Float(index + index % 2) / Float(pagingView.numberOfPages - 1)
                slider.setTrueSliderValue(value:value, pagingView: pagingView)
            }
            else {
                let index = indexes.sorted().first!
                let value = Float(index + index % 2) / Float(pagingView.numberOfPages - 2)
                slider.setTrueSliderValue(value:value, pagingView: pagingView)
            }
        }
    }
    
    open func updatePageIndex(_ index: Int, pagingView: PagingView) {
        if index % 2 == 0 {
            pagingView.currentPageIndex = index.doubleSpread()
        }
        else {
            pagingView.currentPageIndex = (index - 1).doubleSpread()
        }
    }
}

@objcMembers
open class DoubleSpreadConfiguration {
    open var portrait: Bool = false
    open var landscape: Bool = false
    
    public init(portrait: Bool, landscape: Bool) {
        self.portrait = portrait
        self.landscape = landscape
    }
}

@objcMembers
open class RDImageViewerController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, PagingViewDelegate, PagingViewDataSource {

    enum ViewTag : Int {
        case mainScrollView = 1
        case pageScrollView = 2
    }

    static let pageHudLabelFontSize: CGFloat = 17
    
    var previousPageIndex: PagingView.VisibleIndex = .single(index: 0)
    var feedbackGenerator = UISelectionFeedbackGenerator()
    var didRotate: Bool = false
    var pageHud: PageHud
    
    open var doubleSpreadConfiguration: DoubleSpreadConfiguration = DoubleSpreadConfiguration(portrait: false, landscape: false){
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
            interfaceBehaviour().updateLabel(label: pageHud.label, pagingView: pagingView, denominator: numberOfPages)
            interfaceBehaviour().snapSliderPosition(slider: pageSlider, pagingView: pagingView)
            pagingView.currentPageIndex = newValue
        }
        get {
            return pagingView.currentPageIndex
        }
    }
    
    open var numberOfPages: Int {
        get {
            return contents.count
        }
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
        get {
            if UIDevice.current.orientation.isLandscape {
                return doubleSpreadConfiguration.landscape
            }
            return doubleSpreadConfiguration.portrait
        }
    }

    private var _showSlider: Bool = false
    open var showSlider: Bool {
        set {
            if pagingView.scrollDirection.isHorizontal() {
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
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        didRotate = true
        
        if let flowLayout = pagingView.collectionViewLayout as? PagingViewFlowLayout {
            flowLayout.invalidateLayout()
        }
        
        let previousPageIndex = currentPageIndex
        pagingView.beginRotate()
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            self.pagingView.isDoubleSpread = self.isDoubleSpread
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // restore page index
                self.pagingView.currentPageIndex = previousPageIndex
            }
            
            UIView.animate(withDuration: context.transitionDuration) {
                self.pagingView.resizeVisiblePages()
                self.updateHudPosition()
            }
        }) { [unowned self] (context) in
            self.pagingView.endRotate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // update page index
                self.interfaceBehaviour().snapSliderPosition(slider: self.pageSlider, pagingView: self.pagingView)
                self.interfaceBehaviour().updateLabel(label: self.pageHud.label, pagingView: self.pagingView, denominator: self.numberOfPages)
            }
        }
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
        }
        else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        updateHudPosition()
        view.addSubview(pageHud)
        
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
        interfaceBehaviour().updateLabel(label: pageHud.label, pagingView: pagingView, denominator: numberOfPages)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelAutoBarHidden()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if didRotate {
            // update cell size
            pagingView.resizeVisiblePages()

            // update slider position
            interfaceBehaviour().snapSliderPosition(slider: pageSlider, pagingView: pagingView)
            
            didRotate = false
        }
    }
    
    @available(iOS 11.0, *)
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateHudPosition()
    }
    
    // MARK: - slider
    private var previousSliderValue: Float = 0
    @objc func sliderValueDidChange(slider: UISlider) {
        cancelAutoBarHidden()
        let position = pageSlider.trueSliderValue(value: slider.value, pagingView: pagingView)
        let pageIndex = position * Float(numberOfPages - 1)
        let truePageIndex = Int(pageIndex + 0.5)
        let newIndex = truePageIndex.convert(double: isDoubleSpread)
        if currentPageIndex.contains(newIndex) == false, previousSliderValue != slider.value {
            previousSliderValue = slider.value
            feedbackGenerator.selectionChanged()
            pagingView(pagingView: pagingView, willChangeIndexTo: newIndex)
        }
        currentPageIndex = newIndex
    }
    
    @objc func sliderDidTouchUpInside(slider: UISlider) {
        // snap
        interfaceBehaviour().snapSliderPosition(slider: slider, pagingView: pagingView)
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
    
    @objc func scrollDidEnd() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        interfaceBehaviour().updateLabel(label: pageHud.label, pagingView: pagingView, denominator: numberOfPages)
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
        
        if pagingView.scrollDirection == .left {
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
        interfaceBehaviour().snapSliderPosition(slider: pageSlider, pagingView: pagingView)
        interfaceBehaviour().updateLabel(label: pageHud.label, pagingView: pagingView, denominator: numberOfPages)
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
        if pagingView.scrollDirection.isHorizontal() {
            pagingView.isPagingEnabled = true
        }
        else {
            pagingView.isPagingEnabled = false
        }
    }

    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPages
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = contents[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.reuseIdentifier(), for: indexPath) as! PageViewProtocol & UICollectionViewCell
        cell.configure(data: data, pageIndex: indexPath.row, scrollDirection: pagingView.scrollDirection, traitCollection: traitCollection, isDoubleSpread: isDoubleSpread)
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

    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = contents[indexPath.row]
        return data.size(inRect: collectionView.bounds, direction: pagingView.scrollDirection, traitCollection: traitCollection, isDoubleSpread: isDoubleSpread)
    }

    // MARK: - PagingViewDelegate
    open func pagingView(pagingView: PagingView, willChangeIndexTo index: PagingView.VisibleIndex) {
        switch index {
        case let .single(index):
            let data = contents[index]
            if data.isPreloadable(), data.isPreloading() {
                data.stopPreload()
            }
        case let .double(indexes):
            for i in indexes {
                let data = contents[i]
                if data.isPreloadable(), data.isPreloading() {
                    data.stopPreload()
                }
            }
        }
    }

    open func pagingView(pagingView: PagingView, willChangeViewSize size: CGSize, duration: TimeInterval, visibleViews: [UIView]) {
        
    }
    
    open func pagingViewDidEndDragging(pagingView: PagingView, willDecelerate decelerate: Bool) {
        
    }
    
    open func pagingViewWillBeginDecelerating(pagingView: PagingView) {
        
    }
    
    open func pagingViewDidEndScrollingAnimation(pagingView: PagingView) {
        
    }
    
    open func pagingView(pagingView: PagingView, didChangeIndexTo index: Int) {
        if pagingView.scrollDirection.isVertical() {
            interfaceBehaviour().updateLabel(label: pageHud.label, numerator: index + 1, denominator: numberOfPages)
        }
    }
    
    open func pagingView(pagingView: PagingView, didScrollToPosition position: CGFloat) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        if pagingView.scrollDirection.isHorizontal() {
            if pageSlider.state == .normal {
                interfaceBehaviour().updateSliderPosition(slider: pageSlider, value: Float(position), pagingView: pagingView)
            }
            
            let to = Int(position + 0.5)
            interfaceBehaviour().updateLabel(label: pageHud.label, numerator: to + 1, denominator: numberOfPages)
        }
    }

    open func pagingViewWillBeginDragging(pagingView: PagingView) {
        if pagingView.isDragging == false {
            previousPageIndex = currentPageIndex
        }
    }
    
    open func pagingViewDidEndDecelerating(pagingView: PagingView) {
        if isDoubleSpread {
            perform(#selector(scrollDidEnd), with: nil, afterDelay: 0.1)
        }
    }
    
    open func pagingView(pagingView: PagingView, didEndDisplaying view: UIView & PageViewProtocol, index: Int) {
        for v in view.subviews {
            if let scrollView = v as? UIScrollView {
                if pagingView.isPagingEnabled {
                    scrollView.zoomScale = 1.0
                }
            }
        }
    }

    open func pagingView(pagingView: PagingView, preloadItemAt index: Int) {
        let data = contents[index]
        if data.isPreloadable() && !data.isPreloading() {
            data.preload()
        }
    }
    
    open func pagingView(pagingView: PagingView, cancelPreloadingItemAt index: Int) {
        
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
