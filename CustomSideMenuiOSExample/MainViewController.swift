//
//  ContainerViewController.swift
//  CustomSideMenuiOSExample
//
//  Created by John Codeos on 2/8/21.
//

import SafariServices
import UIKit

class MainViewController: UIViewController {
    var mainView: UINavigationController?

    var sideMenuViewController: SideMenuViewController!
    var sideMenuShadowView: UIView!
    private var navigationBar = UINavigationBar()

    var sideMenuRevealWidth: CGFloat = 260

    var paddingForRotation: CGFloat = 150

    var isExpanded: Bool = false
    
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    private var swipeVelocity: CGFloat = 550

    // We expand/collapse the side menu changing the constant of the layout constraint below
    var sideMenuTrailingConstraint: NSLayoutConstraint!

    var panGestureRecognizer: UIPanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Default Main View
        self.showNavViewController(storyboardId: "HomeNavID")

        // Side Menu View
        let main = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.sideMenuViewController = main.instantiateViewController(withIdentifier: "SideMenuID") as? SideMenuViewController
        self.sideMenuViewController.defaultHighlightedCell = 0 // Default Highlighted Cell
        self.sideMenuViewController.selectedCell = { [weak self] row in
            self?.mainViews(row)
        }
        view.insertSubview(self.sideMenuViewController!.view, at: 1)
        addChild(self.sideMenuViewController!)
        self.sideMenuViewController!.didMove(toParent: self)

        // Side Menu View AutoLayout
        self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.sideMenuTrailingConstraint = self.sideMenuViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.sideMenuRevealWidth - self.paddingForRotation)
        self.sideMenuTrailingConstraint.isActive = true
        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        // Gestures

        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(self.panGestureRecognizer)
    }

    // Keep the state of the side menu (expanded/collapse) when you rotate the phone
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            if self.isExpanded {
                self.sideMenuTrailingConstraint.constant = 0
            }
            else {
                self.sideMenuTrailingConstraint.constant = -self.sideMenuRevealWidth - self.paddingForRotation
            }
            self.view.layoutIfNeeded()
        }
    }

    func animateMainView(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.sideMenuTrailingConstraint.constant = targetPosition
            self.view.layoutIfNeeded()
        }, completion: completion)
    }

    @IBAction open func revealSideMenu() {
        if self.isExpanded {
            // Close Side Menu
            self.animateSideMenu(expanded: false)
        }
        else {
            // Open Side Menu
            self.animateSideMenu(expanded: true)
        }
    }

    func animateSideMenu(expanded: Bool) {
        if expanded {
            self.animateMainView(targetPosition: 0) { _ in
                self.isExpanded = true
            }
        }
        else {
            self.animateMainView(targetPosition: -self.sideMenuRevealWidth - self.paddingForRotation) { _ in
                self.isExpanded = false
            }
        }
    }

    // Close Side menu when you tap outside
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        let touch = touches.first
//        guard let location = touch?.location(in: sideMenuViewController.view) else { return }
//        if !sideMenuViewController.view.frame.contains(location), isExpanded == true {
//            animateSideMenu(expanded: false)
//        }
//    }

    func mainViews(_ row: Int) {
        let main = UIStoryboard(name: "Main", bundle: Bundle.main)
        switch row {
        case 0:
            // Home
            self.showNavViewController(storyboardId: "HomeNavID")
        case 1:
            // Music
            self.showNavViewController(storyboardId: "MusicNavID")
        case 2:
            // Movies
            self.showNavViewController(storyboardId: "MoviesNavID")
        case 3:
            // Books
            self.showNavViewController(storyboardId: "BooksNavID")
        case 4:
            // Profile
            let profileModalVC = main.instantiateViewController(withIdentifier: "ProfileModalID") as? ProfileViewController
            present(profileModalVC!, animated: true, completion: nil)
        case 5:
            // Settings
            self.showNavViewController(storyboardId: "SettingsNavID")
        case 6:
            // Like us on facebook
            let safariVC = SFSafariViewController(url: URL(string: "https://www.facebook.com/johncodeos")!)
            present(safariVC, animated: true)
        default:
            break
        }

        // Close side menu
        DispatchQueue.main.async { self.animateSideMenu(expanded: false) }
    }

    func showNavViewController(storyboardId: String) {
        // Remove the previous View
        for subview in view.subviews {
            if subview == self.mainView?.view {
                subview.removeFromSuperview()
            }
        }
        let main = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.mainView = main.instantiateViewController(withIdentifier: storyboardId) as? UINavigationController
        view.insertSubview(self.mainView!.view, at: 0)
        addChild(self.mainView!)
        self.mainView?.didMove(toParent: self)
    }
    
//    func showViewController(storyboardId: String) {
//        for subview in view.subviews {
//            if subview == self.mainView?.view {
//                subview.removeFromSuperview()
//            }
//        }
//        let main = UIStoryboard(name: "Main", bundle: Bundle.main)
//        self.mainView = main.instantiateViewController(withIdentifier: storyboardId) as? UIViewController
//        view.insertSubview(self.mainView!.view, at: 0)
//        addChild(self.mainView!)
//        self.mainView?.didMove(toParent: self)
//    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension MainViewController: UIGestureRecognizerDelegate {
    @objc private func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let position: CGFloat = sender.translation(in: self.view).x
        let velocity: CGFloat = sender.velocity(in: self.view).x

        switch sender.state {
        case .began:

            // If the user tries to expand the menu more than the reveal width, then cancel the pan gesture
            if velocity > 0, self.isExpanded {
                self.panGestureRecognizer?.state = .cancelled
                return
            }

            // If the user swipes right but the side menu hasn't expanded yet, enable dragging
            if velocity > 0, !self.isExpanded {
                self.draggingIsEnabled = true
            }
            // If user swipes left and the side menu is already expanded, so enable dragging(Suppose they collapsing the side menu)
            else if velocity < 0, self.isExpanded {
                self.draggingIsEnabled = true
            }

            // Check if the swipe is too fast, if it is, then expand/collapse the side menu with animation instead of dragging
            if self.draggingIsEnabled {
                if velocity > self.swipeVelocity {
                    self.animateSideMenu(expanded: true)
                    self.draggingIsEnabled = false
                    return
                } else if velocity < -self.swipeVelocity {
                    self.animateSideMenu(expanded: false)
                    self.draggingIsEnabled = false
                    return
                }
            }

            if self.draggingIsEnabled {
                self.panBaseLocation = 0.0
                if self.isExpanded {
                    self.panBaseLocation = self.sideMenuRevealWidth
                }
            }

        case .changed:
            print("Changed")
            if self.draggingIsEnabled {
                let xLocation: CGFloat = self.panBaseLocation + position
                if xLocation <= self.sideMenuRevealWidth {
                    self.sideMenuTrailingConstraint.constant = xLocation - self.sideMenuRevealWidth
                }
            }
        case .ended:
            self.draggingIsEnabled = false
            print("Ended")

            let hasMovedGreaterThanHalfway = self.sideMenuTrailingConstraint.constant > -(self.sideMenuRevealWidth * 0.5)
            self.animateSideMenu(expanded: hasMovedGreaterThanHalfway)
        default:
            break
        }
    }
}
