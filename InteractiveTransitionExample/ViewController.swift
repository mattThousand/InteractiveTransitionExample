//
//  ViewController.swift
//  InteractiveTransitionExample
//
//  Created by Matthew Buckley on 1/9/16.
//  Copyright © 2016 Matt Buckley. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var interactiveTransition: MyTransition?
    var currentSplitLocation: CGFloat = 0.0

    let colors = [
        UIColor.redColor(),
        UIColor.purpleColor(),
        UIColor.blueColor(),
        UIColor.greenColor(),
        UIColor.yellowColor(),
        UIColor.orangeColor(),
        UIColor.redColor(),
        UIColor.purpleColor(),
        UIColor.blueColor(),
        UIColor.greenColor(),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "com.testApp.reuseIdentifier")
        interactiveTransition = MyTransition(withFromViewController: self)
        let panGestureRecognizer = UIPanGestureRecognizer(target: interactiveTransition, action: "didPan:")
        tableView.addGestureRecognizer(panGestureRecognizer)
    }


    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("com.testApp.reuseIdentifier", forIndexPath: indexPath)
        cell.selectionStyle = .None
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

}

class MyTransition: UIPercentDrivenInteractiveTransition {

    var fromVC: UIViewController?
    var container: UIView?

    convenience init(withFromViewController fromVC: UIViewController) {
        self.init()
        self.fromVC = fromVC
        self.fromVC?.transitioningDelegate = self
    }

    func didPan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began:
            let destinationViewController = UIViewController()
            destinationViewController.view.backgroundColor = .greenColor()
            destinationViewController.modalPresentationStyle = .Custom
            destinationViewController.transitioningDelegate = self
            fromVC?.transitioningDelegate = self
            fromVC?.presentViewController(destinationViewController, animated: true, completion: nil)
        case .Changed:

            guard let fromVC = fromVC else {
                debugPrint("FromVC not set")
                return
            }
            let currentTouchLocation = sender.locationInView(container)

            let screenWidth = CGRectGetWidth(fromVC.view.frame)

            let transitionProgress: CGFloat = currentTouchLocation.x / screenWidth

            if transitionProgress <= 0.7 {
                self.updateInteractiveTransition(transitionProgress)
            }
            else {
                finishInteractiveTransition()
            }
        case .Ended:
            break
        default:
            break
        }
    }

}

extension MyTransition: UIViewControllerTransitioningDelegate {

    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }

}

extension MyTransition: UIViewControllerAnimatedTransitioning {

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        guard let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let fromVC = fromVC,
            let container = transitionContext.containerView() else {
                debugPrint("Transition setup failed")
                return
        }

        container.insertSubview(toVC.view, aboveSubview: fromVC.view)

        let screenWidth = CGRectGetWidth(fromVC.view.frame)

        toVC.view.transform = CGAffineTransformMakeTranslation(-screenWidth, 0.0)

        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            delay: 0.0,
            options: [UIViewAnimationOptions.CurveEaseOut],
            animations: {
                toVC.view.transform = CGAffineTransformIdentity
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 2.0
    }
    
}
