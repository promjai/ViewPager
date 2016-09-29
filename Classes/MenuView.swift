
//
//  MenuView.swift
//  ViewPagerDemo
//
//  Created by yamaguchi on 2016/08/31.
//  Copyright © 2016年 h.yamaguchi. All rights reserved.
//

import UIKit

public protocol MenuViewDelegate: class {
    func menuViewDidTapMeunItem(index: Int, direction: UIPageViewControllerNavigationDirection)
    func menuViewWillBeginDragging(scrollView: UIScrollView)
    func menuViewDidEndDragging(scrollView: UIScrollView)
}

open class MenuView: UIView {
    
    open weak var delegate: MenuViewDelegate?
    fileprivate var option = ViewPagerOption()
    fileprivate var indicatorView: UIView!
    fileprivate let factor: CGFloat = 4
    fileprivate var currentIndex: Int = 0
    fileprivate var currentOffsetX: CGFloat = 0.0
    fileprivate var currentIndicatorPointX: CGFloat = 0.0
    fileprivate var itemsWidth: CGFloat = 0.0
    fileprivate var collectionView : UICollectionView!
    fileprivate var titles = [String]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.setupViews()
    }
    
    init(titles: [String], option: ViewPagerOption) {
        super.init(frame: CGRect.zero)
        self.titles = titles
        self.option = option
        self.setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    fileprivate func setupViews() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(MenuCell.self, forCellWithReuseIdentifier: "MenuCell")
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.scrollsToTop = false
        self.collectionView.isUserInteractionEnabled = true
        self.addSubview(self.collectionView)
        
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.lightGray
        self.addSubview(shadowView)
        
        self.indicatorView = UIView()
        self.indicatorView.frame = CGRect(x: (self.frame.width / 2) - (80 / 2), y: self.frame.height - 2, width: 80, height: 2)
        self.indicatorView.backgroundColor = UIColor.blue
        self.addSubview(self.indicatorView)
        
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: self.collectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier:1.0, constant: 0),
            NSLayoutConstraint(item: self.collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.collectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        ])
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: shadowView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: shadowView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: shadowView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.5),
            NSLayoutConstraint(item: shadowView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0.5)
        ])
    }

    fileprivate func colorToRGBA(color: UIColor) -> ((red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)) {
        
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red: red, green: green, blue: blue, alpha)
    }
    
    fileprivate func changeMenuItemFontColor(ratio: CGFloat, currentIndex: Int, nextIndex: Int ) {
        
        let color = self.colorToRGBA(color: self.option.menuItemFontColor)
        let selectedColor = self.colorToRGBA(color: self.option.menuItemSelectedFontColor)
        
        let ratioAbs = fabs(ratio)
        let currentColor = UIColor(red:     color.red   * ratioAbs       + selectedColor.red    * (1 - ratioAbs),
                                   green:   color.green * ratioAbs       + selectedColor.green  * (1 - ratioAbs),
                                   blue:    color.blue  * ratioAbs       + selectedColor.blue   * (1 - ratioAbs),
                                   alpha:   color.alpha * ratioAbs       + selectedColor.alpha  * (1 - ratioAbs))
        
        let nextColor    = UIColor(red:     color.red   * (1 - ratioAbs) + selectedColor.red    * ratioAbs,
                                   green:   color.green * (1 - ratioAbs) + selectedColor.green  * ratioAbs,
                                   blue:    color.blue  * (1 - ratioAbs) + selectedColor.blue   * ratioAbs,
                                   alpha:   color.alpha * (1 - ratioAbs) + selectedColor.alpha  * ratioAbs)
        
        // Current itemFont
        let currentIndexPath = IndexPath(item: self.option.pagerType.isInfinity() ? currentIndex + self.titles.count : currentIndex, section: 0)
        if let currentCell = self.collectionView.cellForItem(at: currentIndexPath) as? MenuCell {
            currentCell.label.textColor = currentColor
            if ratioAbs < 0.5 {
                currentCell.label.font = self.option.menuItemSelectedFont
            } else {
                currentCell.label.font = self.option.menuItemFont
            }
        }
        
        // Next ItemFont
        var nextIndexPath = IndexPath(item: self.option.pagerType.isInfinity() ? nextIndex + self.titles.count : nextIndex, section: 0)
        
        if currentIndex == self.titles.count - 1 && nextIndex == 0 {
            nextIndexPath = IndexPath(item: self.titles.count * 2, section: 0)
        }
        if nextIndex == self.titles.count - 1 && currentIndex == 0 {
            nextIndexPath = IndexPath(item: self.titles.count - 1, section: 0)
        }
        
        if let nextCell = self.collectionView.cellForItem(at: nextIndexPath) as? MenuCell {
            nextCell.label.textColor = nextColor
            if ratioAbs > 0.5 {
                nextCell.label.font = self.option.menuItemSelectedFont
            } else {
                nextCell.label.font = self.option.menuItemFont
            }
        }
        
    }

    // MARK: Public
    open func scrollToMenuItemAtIndex(index: Int, animated: Bool) {
        
        self.currentIndex = self.option.pagerType.isInfinity() ? index + self.titles.count : index
        let indexPath = IndexPath(item: self.currentIndex, section: 0)
        
        if self.option.pagerType.isInfinity() {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            let itemWidth = MenuCell.cellWidth(self.titles[index], font: self.option.menuItemFont)
            // indicator
            self.indicatorView.frame = CGRect(x: (self.frame.width / 2) - (itemWidth / 2), y: self.frame.height - 2, width: itemWidth, height: 2)
        } else {
            let scrollWidth = self.collectionView.contentSize.width - self.collectionView.frame.size.width
            let ratio = CGFloat(self.currentIndex) / CGFloat(self.titles.count - 1)
//            print("終了 : \((scrollWidth * CGFloat(ratio)))")
            
            if self.collectionView.contentSize.width > self.collectionView.frame.size.width {
                self.collectionView.contentOffset.x = (scrollWidth * ratio)
            }
            
            // indicator
            var indicatorPointX: CGFloat = 0.0
            for (idx, _) in self.titles.enumerated() {
                if idx <= self.currentIndex && idx != 0 {
                    let itemWidth = MenuCell.cellWidth(self.titles[idx - 1], font: self.option.menuItemFont)
                    indicatorPointX = CGFloat(indicatorPointX) + CGFloat(itemWidth) + self.option.menuItemMargin
                }
            }
            indicatorPointX = CGFloat(indicatorPointX) - self.collectionView.contentOffset.x + self.option.menuItemMargin
            self.currentIndicatorPointX = CGFloat(indicatorPointX)
            let itemWidth = MenuCell.cellWidth(self.titles[index], font: self.option.menuItemFont)
            self.indicatorView.frame = CGRect(x: self.currentIndicatorPointX , y: self.frame.height - 2, width: itemWidth, height: 2)
        }
        
        self.currentOffsetX = self.collectionView.contentOffset.x
//        print("------------------ \(self.currentOffsetX)")
        
        self.collectionView.visibleCells.forEach { (cell) in
            if let cell = cell as? MenuCell {
                if self.currentIndex % self.titles.count  == cell.label.tag % self.titles.count {
                    cell.label.textColor = self.option.menuItemSelectedFontColor
                    cell.label.font = self.option.menuItemSelectedFont
                    cell.indicator.isHidden = false
                } else {
                    cell.label.textColor = self.option.menuItemFontColor
                    cell.label.font = self.option.menuItemFont
                    cell.indicator.isHidden = true
                }
            }
        }
        self.indicatorView.isHidden = true
    }
    
    open func moveIndicator(currentIndex: Int, nextIndex: Int, offsetX: CGFloat) {
        
        self.indicatorView.isHidden = false
        self.collectionView.visibleCells.forEach { (cell) in
            if let cell = cell as? MenuCell {
                cell.indicator.isHidden = true
            }
        }
        
        if self.currentOffsetX == 0 {
            self.currentOffsetX = self.collectionView.contentOffset.x
        }
        
        if self.currentIndicatorPointX <= 0 {
            self.currentIndicatorPointX = 0
        }
        
        // scroll diff
        let diff = offsetX / self.frame.width
        
        if !self.option.pagerType.isInfinity() {
            // indicator settting
           
            if nextIndex >= 0 && nextIndex < self.titles.count {
                
                let currentItemWidth = MenuCell.cellWidth(self.titles[currentIndex], font: self.option.menuItemFont)
                let nextItemWidth = MenuCell.cellWidth(self.titles[nextIndex], font: self.option.menuItemFont)
                let diffWidth = fabs(diff) * (nextItemWidth - currentItemWidth)
                let itemWidth = currentItemWidth + diffWidth

                
                let scrollWidth = self.collectionView.contentSize.width - self.collectionView.frame.size.width
                var currentScrollWidth = scrollWidth / CGFloat(self.titles.count - 1)
                
                // check to scroll collectionView
                if self.collectionView.contentSize.width > self.collectionView.frame.size.width {
                    self.collectionView.contentOffset.x = (currentScrollWidth * diff) + self.currentOffsetX;
                    if currentIndex == 0 {
                        self.collectionView.contentOffset.x -= self.currentOffsetX
                    }

                } else {
                    currentScrollWidth = 0
                }
                
                let moveWidth = diff < 0 ? nextItemWidth : currentItemWidth
                let indicatorPointX = (moveWidth * diff)
                    + (self.option.menuItemMargin * diff)
                    - (currentScrollWidth * diff)
                    + self.currentIndicatorPointX
//                    + self.option.menuItemMargin
                self.indicatorView.frame = CGRect(x: indicatorPointX , y: self.frame.height - 2, width: itemWidth, height: 2)
            }
            
        } else {
            
            // infinity
            
            let currentItemWidth = MenuCell.cellWidth(self.titles[currentIndex], font: self.option.menuItemFont)
            let nextItemWidth = MenuCell.cellWidth(self.titles[nextIndex], font: self.option.menuItemFont)
            let diffWidth = fabs(diff) * (nextItemWidth - currentItemWidth)
            let itemWidth = currentItemWidth + diffWidth

            
            self.indicatorView.frame = CGRect(x: (self.frame.width / 2) - (itemWidth / 2), y: self.frame.height - 2, width: itemWidth, height: 2)
            let itemOffetX = (currentItemWidth / 2.0) + (nextItemWidth / 2.0)
            
            let scrollOffsetX = diff * itemOffetX
            
            self.collectionView.contentOffset.x = self.currentOffsetX + scrollOffsetX + (self.option.menuItemMargin * diff)
            
        }
        
        // menu item animation
        self.changeMenuItemFontColor(ratio: diff, currentIndex: currentIndex, nextIndex: nextIndex)

    }
    
    open func updateCollectionViewUserInteractionEnabled(userInteractionEnabled: Bool) {
        self.collectionView.isUserInteractionEnabled = userInteractionEnabled
    }
    
    open func updateIndicatorHidden(hidden: Bool) {
        self.indicatorView.isHidden = hidden
    }
}

// MARK: UICollectionViewDataSource
extension MenuView : UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.option.pagerType.isInfinity() {
            return self.titles.count * Int(self.factor)
        }
        return self.titles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        cell.delegate = self
        cell.setRowData(datas: self.titles, indexPath: indexPath, currentIndex: self.currentIndex, option: self.option)
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension MenuView: UICollectionViewDelegate {
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("\(scrollView.contentOffset.x)")
        if self.option.pagerType.isInfinity() {
            if self.itemsWidth == 0.0 {
                self.itemsWidth = floor(scrollView.contentSize.width / self.factor)
            }
            
            if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > self.itemsWidth * 2.0) {
                scrollView.contentOffset.x = self.itemsWidth
            }
        }

    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.indicatorView.isHidden = true
        self.collectionView.reloadData()
        self.delegate?.menuViewWillBeginDragging(scrollView: scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.menuViewDidEndDragging(scrollView: scrollView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.option.menuItemMargin
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: self.option.menuItemMargin, bottom: 0.0, right: self.option.menuItemMargin)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let index = (indexPath as NSIndexPath).row % self.titles.count
        let width = MenuCell.cellWidth(self.titles[index], font: self.option.menuItemFont)
        return CGSize(width: width, height: self.frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return self.option.menuItemMargin
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // To Disable CollectionView UserInteractionEnabled
        self.updateCollectionViewUserInteractionEnabled(userInteractionEnabled: false)
        
        let currentIndex = indexPath.row % self.titles.count
        
        if self.currentIndex % self.titles.count != currentIndex {
            self.indicatorView.isHidden = false
            self.collectionView.visibleCells.forEach { (cell) in
                if let cell = cell as? MenuCell {
                    cell.indicator.isHidden = true
                }
            }
        }
        
        var direction: UIPageViewControllerNavigationDirection = .forward
        if ((self.option.pagerType.isInfinity() && indexPath.row < self.titles.count)) || (indexPath.row < self.currentIndex) {
            direction = .reverse
        }
        
        self.currentIndex = self.option.pagerType.isInfinity() ? currentIndex + self.titles.count : currentIndex
        
        if self.option.pagerType.isInfinity() {
            let indexPath = IndexPath(item: indexPath.row, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.currentOffsetX = 0
            
            let itemWidth = MenuCell.cellWidth(self.titles[currentIndex], font: self.option.menuItemFont)
            //        self.indicatorView.frame = CGRect(x: (self.frame.width / 2) - (itemWidth / 2), y: self.frame.height - 2, width: itemWidth, height: 2)
            
            //
            UIView.animate(withDuration: 0.35) {
                self.indicatorView.frame = CGRect(x: (self.frame.width / 2) - (itemWidth / 2), y: self.frame.height - 2, width: itemWidth, height: 2)
            }
        } else {
         
            let scrollWidth = self.collectionView.contentSize.width - self.collectionView.frame.size.width
            let ratio = CGFloat(self.currentIndex) / CGFloat(self.titles.count - 1)
            //            print("終了 : \((scrollWidth * CGFloat(ratio)))")
            // indicator
            var indicatorPointX: CGFloat = 0.0
            for (idx, _) in self.titles.enumerated() {
                if idx <= self.currentIndex && idx != 0 {
                    let itemWidth = MenuCell.cellWidth(self.titles[idx - 1], font: self.option.menuItemFont)
                    indicatorPointX = CGFloat(indicatorPointX) + CGFloat(itemWidth) + self.option.menuItemMargin
                }
            }
            indicatorPointX = CGFloat(indicatorPointX) - (scrollWidth * ratio) + self.option.menuItemMargin
            self.currentIndicatorPointX = CGFloat(indicatorPointX)
            let itemWidth = MenuCell.cellWidth(self.titles[currentIndex], font: self.option.menuItemFont)

            UIView.animate(withDuration: 0.35) {
                
                if self.collectionView.contentSize.width > self.collectionView.frame.size.width {
                    self.collectionView.contentOffset.x = (scrollWidth * ratio)
                }
                
                self.indicatorView.frame = CGRect(x: self.currentIndicatorPointX , y: self.frame.height - 2, width: itemWidth, height: 2)
            }

        }
        
        self.delegate?.menuViewDidTapMeunItem(index: currentIndex, direction: direction)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    
    }
}

extension MenuView: MenuCellDelegate {
    public func menuCellDidTapItem(index: Int) {
      
    }
}
