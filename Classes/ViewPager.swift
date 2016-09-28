//
//  ViewPager.swift
//  ViewPagerDemo
//
//  Created by yamaguchi on 2016/08/31.
//  Copyright © 2016年 h.yamaguchi. All rights reserved.
//

import UIKit

open class ViewPager: UIViewController {
    
    fileprivate var option = ViewPagerOption()
    var currentIndex: Int? {
        guard let viewController = self.pageViewController.viewControllers?.first else {
            return 0
        }
        return self.viewControllers.map{ $0 }.index(of: viewController)
    }
    var movingIndex: Int = 0
    fileprivate var isTapMenuItem = false
    fileprivate var pageViewController: UIPageViewController!
    fileprivate var menuView: MenuView!
    fileprivate var titles = [String]()
    fileprivate var viewControllers = [UIViewController]()
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init(controllers: [UIViewController], option: ViewPagerOption, parentViewController: ViewController) {
        super.init(nibName: nil, bundle: nil)
        
        parentViewController.addChildViewController(self)
        self.didMove(toParentViewController: parentViewController)
        
        self.viewControllers = controllers
        // titles
        controllers.forEach {
            guard let title = $0.title else {
                fatalError("Please set the title of the viewController")
            }
            self.titles.append(title)
        }
        self.option = option
//        parentViewController.automaticallyAdjustsScrollViewInsets = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        self.menuView.scrollToMenuItemAtIndex(index: 0, animated: false)
//        self.controllerInset()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
//        self.automaticallyAdjustsScrollViewInsets = false
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
//        self.pageViewController.view.frame = CGRectMake(0, (64 + 40), self.view.frame.width, self.view.frame.height - (64 + 40))
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)

        self.movingIndex = 0
        self.pageViewController.setViewControllers([viewControllers[self.movingIndex]], direction: .forward, animated: true, completion: nil)
        
        
//        menuView = MenuView(frame: CGRectMake(0, 64, self.view.frame.width, 40))
        self.menuView = MenuView(titles: self.titles, option: self.option)
        self.menuView.backgroundColor = UIColor.clear
        self.menuView.delegate = self
//        menuView.alpha = 0.3
        self.view.addSubview(self.menuView)
        
        for view in self.pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.scrollsToTop = false
                scrollView.delegate = self
            }
        }
        
        // layout pageController
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
//            NSLayoutConstraint(item: self.pageViewController.view, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier:1.0, constant: 0),
            NSLayoutConstraint(item: self.pageViewController.view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier:1.0, constant: 0),
            NSLayoutConstraint(item: self.pageViewController.view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.pageViewController.view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.pageViewController.view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        ])
        
        // layout menuView
        self.menuView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            NSLayoutConstraint(item: self.menuView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier:1.0, constant: 0),
            NSLayoutConstraint(item: self.menuView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.menuView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.menuView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 40)
        ])
    }
    
    // MARK: Private
    fileprivate func controllerInset() {
        
        for controller in viewControllers {
            if let controller = controller as? UITableViewController {
                controller.tableView.contentInset.top = 64 + 40
                controller.tableView.contentOffset.y = -40
//                controller.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                controller.tableView.contentOffset = CGPoint(x: 0, y: controller.tableView.contentInset.top)
                continue
            }
            if let controller = controller as? UICollectionViewController {
                controller.collectionView!.contentInset.top = 64 + 40
                controller.collectionView!.contentOffset.y = -40
                controller.view.setNeedsLayout()
                continue
            }
            
//            for view in controller.view.subviews {
////                if let view = view as? UITableView {
////                    view.contentInset.top = 64 + 40
////                    break
////                }
////                if let view = view as? UICollectionView {
////                    view.contentInset.top = 64 + 40
////                    break
////                }
//                if let view = view as? UIScrollView {
//                    view.contentInset.top = 64 + 40
//                    break
//                }
//            }
        }
    }
    
    // MARK: Public
    open func setupPageControllerAtIndex(index: Int, direction: UIPageViewControllerNavigationDirection) {
        self.isTapMenuItem = true
        
        if (index == self.currentIndex!) {
            self.isTapMenuItem = false
            self.menuView.updateCollectionViewUserInteractionEnabled(userInteractionEnabled: true)
            return
        }
        
        self.movingIndex = index
        self.pageViewController.setViewControllers([viewControllers[index]], direction: direction, animated: true) { [weak self] (isFinish) in
            
            guard let weakself = self else {
                return
            }
            
            weakself.isTapMenuItem = false
            
            // To Disable CollectionView UserInteractionEnabled
            weakself.menuView.updateCollectionViewUserInteractionEnabled(userInteractionEnabled: true)
            weakself.menuView.scrollToMenuItemAtIndex(index: weakself.currentIndex!, animated: false)
        }
    }
}

extension ViewPager: UIPageViewControllerDataSource {
     
    fileprivate func nextViewController(_ viewController: UIViewController, isAfter: Bool) -> UIViewController? {
        guard var index = viewControllers.index(of: viewController) else {
            return nil
        }

        if isAfter {
            index += 1
        } else {
            index -= 1
        }
        
        if self.option.pagerType.isInfinity() {
            if index == viewControllers.count {
                index = 0
            }
            
            if index < 0 {
                index = viewControllers.count - 1
            }
        }
        
        if index >= 0 && index < viewControllers.count {
            return viewControllers[index]
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: true)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: false)
    }
}

// MARK: - UIPageViewControllerDelegate

extension ViewPager: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

        self.isTapMenuItem = false
        // To Disable CollectionView UserInteractionEnabled
        self.menuView.updateCollectionViewUserInteractionEnabled(userInteractionEnabled: false)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            self.movingIndex = self.currentIndex!
            self.menuView.scrollToMenuItemAtIndex(index: self.currentIndex!, animated: false)
        }
        
        // To Disable CollectionView UserInteractionEnabled
        self.menuView.updateCollectionViewUserInteractionEnabled(userInteractionEnabled: true)
    }
}



extension ViewPager: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == self.view.frame.width || self.isTapMenuItem {
            return
        }

        var targetIndex = 0
        if scrollView.contentOffset.x > self.view.frame.width {
            targetIndex = self.movingIndex + 1
        } else {
            targetIndex = self.movingIndex - 1
        }
        
        // infinity setting
        if self.option.pagerType.isInfinity() {
            if targetIndex == viewControllers.count {
                targetIndex = 0
            }
            
            if targetIndex < 0 {
                targetIndex = viewControllers.count - 1
            }
        }
        
        let offsetX = scrollView.contentOffset.x - self.view.frame.width
        self.menuView.moveIndicator(currentIndex: self.movingIndex, nextIndex: targetIndex, offsetX: offsetX)
    
    }
}

extension ViewPager: MenuViewDelegate {
    public func menuViewDidTapMeunItem(index: Int, direction: UIPageViewControllerNavigationDirection) {
        self.setupPageControllerAtIndex(index: index, direction: direction)
    }
    
    public func menuViewWillBeginDragging(scrollView: UIScrollView) {
        self.pageViewController.view.isUserInteractionEnabled = false
    }
    
    public func menuViewDidEndDragging(scrollView: UIScrollView) {
        self.pageViewController.view.isUserInteractionEnabled = true
    }
}
