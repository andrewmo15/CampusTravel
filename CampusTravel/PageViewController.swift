//
//  PageViewController.swift
//  CampusTravel
//
//  Created by Andrew Mo on 9/5/20.
//  Copyright © 2020 Andrew Mo. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private var orderedViewControllers: [UIViewController] = {
        var orderedViewControllers: [UIViewController] = []
        for num in 0...5 {
            let page = UIViewController()
            if num == 5 {
                page.view.backgroundColor = UIColor.white
            } else {
                page.view.backgroundColor = UIColor(red: 130.0 / 255.0, green: 130.0 / 255.0, blue: 130.0 / 255.0, alpha: 1)
            }
            let imageView = UIImageView(image: UIImage(named: "HowTo" + String(num + 1)))
            let picX = (0.5 * page.view.frame.width) - (page.view.frame.height / (2 * 2436.0 / 1125.0))
            imageView.frame = CGRect(x: picX, y: 0, width: (page.view.frame.height / (2436.0 / 1125.0)), height: page.view.frame.height)
            page.view.addSubview(imageView)
            if num == 5 {
                let done = UIButton()
                done.setTitle("Done", for: .normal)
                done.setTitleColor(.white, for: .normal)
                done.backgroundColor = .link
                done.layer.cornerRadius = 12
                done.layer.masksToBounds = true
                done.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
                done.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
                done.frame = CGRect(x: 50, y: page.view.frame.height - 100, width: page.view.frame.width - 100, height: 52)
                page.view.addSubview(done)
            }
            orderedViewControllers.append(page)
        }
        return orderedViewControllers
    }()
    
    var pageControl = UIPageControl()
    
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 30))
        pageControl.numberOfPages = orderedViewControllers.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.darkGray
        pageControl.currentPageIndicatorTintColor = UIColor.link
        view.addSubview(pageControl)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard orderedViewControllers.count != nextIndex else {
            return nil
        }
        guard orderedViewControllers.count > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        self.delegate = self
        configurePageControl()
        // Do any additional setup after loading the view.
    }
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}
