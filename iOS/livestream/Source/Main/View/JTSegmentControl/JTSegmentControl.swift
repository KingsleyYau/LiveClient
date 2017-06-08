//
//  JTSegmentControl.swift
//  JTSegmentControlDemo
//
//  Created by xia on 16/11/13.
//  Copyright © 2016年 JT. All rights reserved.
//

import UIKit

fileprivate class JTSliderView : UIView {
    
    fileprivate var color : UIColor? {
        didSet{
            self.backgroundColor = color
        }
    }
}

fileprivate enum JTItemViewState : Int {
    case Normal
    case Selected
}

fileprivate class JTItemView : UIView {
    
    fileprivate func itemWidth() -> CGFloat {
        
        if let text = titleLabel.text {
            let string = text as NSString
            let size = string.size(attributes: [NSFontAttributeName:selectedFont!])
            return size.width + JTSegmentPattern.itemBorder
        }
        
        return 0.0
    }
    
    fileprivate let titleLabel = UILabel()
    fileprivate lazy var bridgeView : CALayer = {
        let view = CALayer()
        let width = JTSegmentPattern.bridgeWidth
        view.bounds = CGRect(x: 0.0, y: 0.0, width: width, height: width)
        view.backgroundColor = JTSegmentPattern.bridgeColor.cgColor
        view.cornerRadius = view.bounds.size.width * 0.5
        return view
    }()
    
    fileprivate func showBridge(show:Bool){
        self.bridgeView.isHidden = !show
    }
    
    fileprivate var state : JTItemViewState = .Normal {
        didSet{
            updateItemView(state: state)
        }
    }
    
    fileprivate var font : UIFont?{
        didSet{
            if state == .Normal {
                self.titleLabel.font = font
            }
        }
    }
    fileprivate var selectedFont : UIFont?{
        didSet{
            if state == .Selected {
                self.titleLabel.font = selectedFont
            }
        }
    }
    
    fileprivate var text : String?{
        didSet{
            self.titleLabel.text = text
        }
    }
    
    fileprivate var textColor : UIColor?{
        didSet{
            if state == .Normal {
                self.titleLabel.textColor = textColor
            }
        }
    }
    fileprivate var selectedTextColor : UIColor?{
        didSet{
            if state == .Selected {
                self.titleLabel.textColor = selectedTextColor
            }
        }
    }
    
    fileprivate var itemBackgroundColor : UIColor?{
        didSet{
            if state == .Normal {
                self.backgroundColor = itemBackgroundColor
            }
        }
    }
    fileprivate var selectedBackgroundColor : UIColor?{
        didSet{
            if state == .Selected {
                self.backgroundColor = selectedBackgroundColor
            }
        }
    }
    
    fileprivate var textAlignment = NSTextAlignment.center {
        didSet{
            self.titleLabel.textAlignment = textAlignment
        }
    }
    
    private func updateItemView(state:JTItemViewState){
        switch state {
        case .Normal:
            self.titleLabel.font = self.font
            self.titleLabel.textColor = self.textColor
            self.backgroundColor = self.itemBackgroundColor
        case .Selected:
            self.titleLabel.font = selectedFont
            self.titleLabel.textColor = self.selectedTextColor
            self.backgroundColor = self.selectedBackgroundColor
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
        
        bridgeView.isHidden = true
        layer.addSublayer(bridgeView)
        
        layer.masksToBounds = true
    }
    
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.sizeToFit()
        
        titleLabel.center.x = bounds.size.width * 0.5
        titleLabel.center.y = bounds.size.height * 0.5
        
        let width = bridgeView.bounds.size.width
        let x:CGFloat = titleLabel.frame.maxX
        bridgeView.frame = CGRect(x: x, y: bounds.midY - width, width: width, height: width)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc public protocol JTSegmentControlDelegate {
    @objc optional func didSelected(segement:JTSegmentControl, index: Int)
}

open class JTSegmentControl: UIControl {
    
    fileprivate struct Constants {
        static let height : CGFloat = 40.0
    }
    
    open weak var delegate : JTSegmentControlDelegate?
    
    open var autoAdjustWidth = false {
        didSet{
            
        }
    }
    
    //recomend to use segmentWidth(index:Int)
    open func segementWidth() -> CGFloat {
        return bounds.size.width / (CGFloat)(itemViews.count)
    }
    //when autoAdjustWidth is true, the width is not necessarily the same
    open func segmentWidth(index:Int) -> CGFloat {
        guard index >= 0 && index < itemViews.count else {
            return 0.0
        }
        if autoAdjustWidth {
            return itemViews[index].itemWidth()
        }else{
            return segementWidth()
        }
    }
    
    open var selectedIndex = 0 {
        willSet{
            let originItem = self.itemViews[selectedIndex]
            originItem.state = .Normal
            
            let selectItem = self.itemViews[newValue]
            selectItem.state = .Selected
        }
    }
    
    //MARK - color set
    open var itemTextColor = JTSegmentPattern.itemTextColor{
        didSet{
            self.itemViews.forEach { (itemView) in
                itemView.textColor = itemTextColor
            }
        }
    }
    
    open var itemSelectedTextColor = JTSegmentPattern.itemSelectedTextColor{
        didSet{
            self.itemViews.forEach { (itemView) in
                itemView.selectedTextColor = itemSelectedTextColor
            }
        }
    }
    open var itemBackgroundColor = JTSegmentPattern.itemBackgroundColor{
        didSet{
            self.itemViews.forEach { (itemView) in
                itemView.itemBackgroundColor = itemBackgroundColor
            }
        }
    }
    
    open var itemSelectedBackgroundColor = JTSegmentPattern.itemSelectedBackgroundColor{
        didSet{
            self.itemViews.forEach { (itemView) in
                itemView.selectedBackgroundColor = itemSelectedBackgroundColor
            }
        }
    }
    
    open var sliderViewColor = JTSegmentPattern.sliderColor{
        didSet{
            self.sliderView.color = sliderViewColor
        }
    }
    
    //MAR - font
    open var font = JTSegmentPattern.textFont{
        didSet{
            self.itemViews.forEach { (itemView) in
                itemView.font = font
            }
        }
    }
    
    open var selectedFont = JTSegmentPattern.selectedTextFont{
        didSet{
            self.itemViews.forEach { (itemView) in
                itemView.selectedFont = selectedFont
            }
        }
    }
    
    open var items : [String]?{
        didSet{
            guard items != nil && items!.count > 0 else {
                fatalError("Items cannot be empty")
            }
            
            self.removeAllItemView()
            
            
            for title in items! {
                let view = self.createItemView(title: title)
                self.itemViews.append(view)
                self.contentView.addSubview(view)
            }
            self.selectedIndex = 0
            
            self.contentView.bringSubview(toFront: self.sliderView)
        }
    }
    
    open func showBridge(show:Bool, index:Int){
        
        guard index < itemViews.count && index >= 0 else {
            return
        }
        
        itemViews[index].showBridge(show: show)
    }
    
    
    //when true, scrolled the itemView to a point when index changed
    open var autoScrollWhenIndexChange = true
    
    open var scrollToPointWhenIndexChanged = CGPoint(x: 0.0, y: 0.0)
    
    open var bounces = false {
        didSet{
            self.scrollView.bounces = bounces
        }
    }
    
    fileprivate func removeAllItemView() {
        itemViews.forEach { (label) in
            label.removeFromSuperview()
        }
        itemViews.removeAll()
    }
    private var itemWidths = [CGFloat]()
    private func createItemView(title:String) -> JTItemView {
        return createItemView(title: title,
                              font: self.font,
                              selectedFont: self.selectedFont,
                              textColor: self.itemTextColor,
                              selectedTextColor: self.itemSelectedTextColor,
                              backgroundColor: self.itemBackgroundColor,
                              selectedBackgroundColor: self.itemSelectedBackgroundColor
        )
    }
    
    private func createItemView(title:String, font:UIFont, selectedFont:UIFont, textColor:UIColor, selectedTextColor:UIColor, backgroundColor:UIColor, selectedBackgroundColor:UIColor) -> JTItemView {
        let item = JTItemView()
        item.text = title
        item.textColor = textColor
        item.textAlignment = .center
        item.font = font
        item.selectedFont = selectedFont
        
        item.itemBackgroundColor = backgroundColor
        item.selectedTextColor = selectedTextColor
        item.selectedBackgroundColor = selectedBackgroundColor
        
        item.state = .Normal
        return item
    }
    
    fileprivate lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()
    fileprivate lazy var contentView = UIView()
    fileprivate lazy var sliderView : JTSliderView = JTSliderView()
    fileprivate var itemViews = [JTItemView]()
    
    fileprivate var numberOfSegments : Int {
        return itemViews.count
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
        scrollToPointWhenIndexChanged = scrollView.center
    }
    
    fileprivate func setupViews() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(sliderView)
        sliderView.color = sliderViewColor
        
        scrollView.frame = bounds
        contentView.frame = scrollView.bounds
        
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addTapGesture()
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSegement(tapGesture:)))
        
        contentView.addGestureRecognizer(tap)
    }
    
    @objc private func didTapSegement(tapGesture:UITapGestureRecognizer) {
        let index = selectedTargetIndex(gesture: tapGesture)
        move(to: index)
    }
    
    open func move(to index:Int){
        move(to: index, animated: true)
    }
    
    open func move(to index:Int, animated:Bool) {
        
        let position = centerX(with: index)
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.sliderView.center.x = position
                self.sliderView.bounds = CGRect(x: 0.0, y: 0.0, width: self.segmentWidth(index: index), height: self.sliderView.bounds.height)
            })
        }else{
            self.sliderView.center.x = position
            self.sliderView.bounds = CGRect(x: 0.0, y: 0.0, width: self.segmentWidth(index: index), height: self.sliderView.bounds.height)
        }
        
        delegate?.didSelected?(segement: self, index: index)
        selectedIndex = index
        
        if autoScrollWhenIndexChange {
            scrollItemToPoint(index: index, point: scrollToPointWhenIndexChanged)
        }
    }
    
    fileprivate func currentItemX(index:Int) -> CGFloat {
        if autoAdjustWidth {
            var x:CGFloat = 0.0
            for i in 0..<index {
                x += segmentWidth(index: i)
            }
            return x
        }
        return segementWidth() * CGFloat(index)
    }
    
    fileprivate func centerX(with index:Int) -> CGFloat {
        if autoAdjustWidth {
            return currentItemX(index: index) + segmentWidth(index: index)*0.5
        }
        return (CGFloat(index) + 0.5)*segementWidth()
    }
    
    private func selectedTargetIndex(gesture: UIGestureRecognizer) -> Int {
        let location = gesture.location(in: contentView)
        var index = 0
        
        if autoAdjustWidth {
            for (i,itemView) in itemViews.enumerated() {
                if itemView.frame.contains(location) {
                    index = i
                    break
                }
            }
        }else{
            index = Int(location.x / sliderView.bounds.size.width)
        }
        
        if index < 0 {
            index = 0
        }
        if index > numberOfSegments - 1 {
            index = numberOfSegments - 1
        }
        return index
    }
    
    private func scrollItemToCenter(index : Int) {
        scrollItemToPoint(index: index, point: CGPoint(x: scrollView.bounds.size.width * 0.5, y: 0))
    }
    
    private func scrollItemToPoint(index : Int,point:CGPoint) {
        
        let currentX = currentItemX(index: index)
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        var scrollX = currentX - point.x + segmentWidth(index: index) * 0.5
        
        let maxScrollX = scrollView.contentSize.width - scrollViewWidth
        
        if scrollX > maxScrollX {
            scrollX = maxScrollX
        }
        if scrollX < 0.0 {
            scrollX = 0.0
        }
        
        scrollView.setContentOffset(CGPoint(x: scrollX, y: 0.0), animated: true)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard itemViews.count > 0 else {
            return
        }
        
        var x:CGFloat = 0.0
        let y:CGFloat = 0.0
        var width:CGFloat = segmentWidth(index: selectedIndex)
        let height:CGFloat = bounds.size.height
        
        sliderView.frame = CGRect(x: currentItemX(index: selectedIndex), y: contentView.bounds.size.height - JTSegmentPattern.sliderHeight, width: width, height: JTSegmentPattern.sliderHeight)
        
        var contentWidth:CGFloat = 0.0
        
        for (index,item) in itemViews.enumerated() {
            x = contentWidth
            width = segmentWidth(index: index)
            item.frame = CGRect(x: x, y: y, width: width, height: height)
            
            contentWidth += width
        }
        contentView.frame = CGRect(x: 0.0, y: 0.0, width: contentWidth, height: contentView.bounds.height)
        scrollView.contentSize = contentView.bounds.size
    }
}
