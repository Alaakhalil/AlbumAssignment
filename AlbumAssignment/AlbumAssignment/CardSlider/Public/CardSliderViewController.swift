
import UIKit
import Kingfisher
/// Model for a card.
public protocol CardSliderItem {
    /// The URL for the image
    var url: String{ get }
    /// The image for the card.
    var image: UIImage? { get }
    
    /// Rating from 0 to 5. If set to nil, rating view will not be displayed for the card.
    var rating: Int? { get }
    
    /// Will be displayed in the title view below the card.
    var title: String { get }
    
    /// Will be displayed under the main title for the card.
    var subtitle: String? { get }
    
    /// Will be displayed as scrollable text in the expanded view.
    var description: String? { get }
}

public protocol CardSliderDataSource: class {
    /// CardSliderItem for the card at given index, counting from the top.
    func item(for index: Int) -> CardSliderItem
    
    /// Total number of cards.
    func numberOfItems() -> Int
}

/// A view controller displaying a slider of cards, represented by CardSliderItems.
///
/// Needs CardSliderDataSource to show data.

open class CardSliderViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var cardTitleContainer: UIView!
    @IBOutlet private var cardTitleView: CardTitleView!
    @IBOutlet private var ratingView: RatingView!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var scrollStack: UIStackView!
    @IBOutlet private var scrollPlaceholderView: UIView!
    private weak var cardSnapshot: UIView?
    private weak var cardTitleSnapshot: UIView?
    private weak var openCardCell: UICollectionViewCell?
    private var animator: UIViewPropertyAnimator?
    private let cellID = "CardCell"
    
    
    /// Instantiate CardSliderViewController.
    ///
    /// - Parameter dataSource: CardSliderDataSource
    
    public static func with(dataSource: CardSliderDataSource) -> CardSliderViewController {
        
        if let path = Bundle(for: self).path(forResource: "CardSlider", ofType: "bundle"),
           let bundle = Bundle(path: path),
           let controller = UIStoryboard(name: "Main", bundle: bundle).instantiateInitialViewController() as? CardSliderViewController {
            controller.dataSource = dataSource
            return controller
        }
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle(for: self)).instantiateInitialViewController() as? CardSliderViewController {
            
            controller.dataSource = dataSource
            return controller
        }
        
        fatalError("Failed to initialize CardSliderViewController")
    }
    
    public weak var dataSource: CardSliderDataSource!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
    }
    
    open override var title: String? {
        didSet {
            titleLabel?.text = title
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = title
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.layoutIfNeeded()
        self.prepareFirstCard()
    }
    
    private func prepareFirstCard() {
        guard let layout = collectionView.collectionViewLayout as? CardsLayout else { return }
        let item = dataSource.item(for: dataSource.numberOfItems() - layout.currentPage - 1)
        cardTitleView.set(title: CardTitle(title: item.title, subtitle: item.subtitle))
    }
    
    // MARK: - Detailed view animations
    
    /// The amount in points by which the card image will extend over the top and the sides in the expanded view.
    public var cardOversize: CGFloat = 15
    /// The amount in points by which the scroll must be pulled down for the expanded view to close.
    public var cardDismissingThreshold: CGFloat = 70
    
    private var isShowingDescription = false
    private var visibleDescriptionHeight: CGFloat {
        guard let titleSnapshot = cardTitleSnapshot else { return 0 }
        return scrollView.bounds.height - scrollPlaceholderView.bounds.height - titleSnapshot.bounds.height - scrollView.safeAreaInsets.top
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            cardSnapshot?.removeFromSuperview()
            openCardCell?.isHidden = false
            return
        }
        
        guard scrollView == self.scrollView, isShowingDescription else { return }
        guard let cardSnapshot = cardSnapshot else { return }
        
        if scrollView.contentOffset.y < -cardDismissingThreshold {
            self.hideCardDescription()
        }
        
        else if scrollView.contentOffset.y < -scrollView.safeAreaInsets.top {
            guard let cell = openCardCell else { return }
            if animator == nil {
                animator = UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.7) {
                    cardSnapshot.frame = self.view.convert(cell.frame, from: cell.superview!)
                }
            }
            animator?.fractionComplete = abs((scrollView.contentOffset.y + scrollView.safeAreaInsets.top) / visibleDescriptionHeight)
        }
        
        else {
            resetCardAnimation()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else { return }
        guard let layout = collectionView.collectionViewLayout as? CardsLayout else { return }
        let item = dataSource.item(for: dataSource.numberOfItems() - layout.currentPage - 1)
        cardTitleView.set(title: CardTitle(title: item.title, subtitle: item.subtitle))
    }
    
    private func resetCardAnimation() {
        guard let snapshot = cardSnapshot else { return }
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
        animator = nil
        let ratio = snapshot.bounds.width / snapshot.bounds.height
        let width = self.view.bounds.width + self.cardOversize * 2
        let height = width / ratio
        let offset = min(-cardOversize, -pow(scrollView.contentOffset.y - cardOversize, 0.9))
        snapshot.frame = CGRect(x: -self.cardOversize, y: -self.cardOversize + offset, width: width, height: height)
    }
    
    private func showCardDescription(for indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        openCardCell = cell
        
        let cardTitleSnapshot = cardTitleContainer.renderSnapshot()
        self.cardTitleSnapshot = cardTitleSnapshot
        
        let cardSnapshot = cell.renderSnapshot()
        self.cardSnapshot = cardSnapshot
        
        descriptionLabel.text = dataSource.item(for: dataSource.numberOfItems() - indexPath.item - 1).description
        scrollStack.insertArrangedSubview(cardTitleSnapshot, at: 1)
        scrollView.isHidden = false
        
        let cellFrame = view.convert(cell.frame, from: cell.superview!)
        cardSnapshot.frame = cellFrame
        view.insertSubview(cardSnapshot, belowSubview: cardTitleContainer)
        scrollView.center.y += visibleDescriptionHeight
        
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.center.y -= self.visibleDescriptionHeight
            self.resetCardAnimation()
        }) { _ in
            self.isShowingDescription = true
        }
        statusbarStyle = .lightContent
    }
    
    private func hideCardDescription() {
        guard !scrollView.isHidden, isShowingDescription else { return }
        isShowingDescription = false
        
        let scrollviewSnapshot = scrollView.snapshotView(afterScreenUpdates: false)!
        view.addSubview(scrollviewSnapshot)
        scrollviewSnapshot.frame = scrollView.frame
        let offset = visibleDescriptionHeight + scrollView.contentOffset.y + scrollView.safeAreaInsets.top
        scrollView.isHidden = true
        
        cardTitleContainer.isHidden = true
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.9, animations: {
            scrollviewSnapshot.center.y += offset
        }) { _ in
            scrollviewSnapshot.removeFromSuperview()
            self.scrollView.isHidden = true
            self.cardTitleContainer.isHidden = false
            self.cardTitleSnapshot?.removeFromSuperview()
        }
        
        openCardCell?.isHidden = true
        animator?.addCompletion({ _ in
            self.cardSnapshot?.removeFromSuperview()
            self.openCardCell?.isHidden = false
            self.animator = nil
        })
        animator?.startAnimation()
        statusbarStyle = .default
    }
    
    // back to albums
    @IBAction func dismissPressedButton(_ sender: Any) {
        self.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.animator?.pauseAnimation()
                self.animator?.stopAnimation(true)
                self.animator?.finishAnimation(at: .current)
            }
        }
    }
    // MARK: - View Controller
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private var statusbarStyle: UIStatusBarStyle = .default {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return statusbarStyle
    }
}

// MARK: - Collection View

extension CardSliderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CardSliderCell else { return }
        let item = dataSource.item(for: dataSource.numberOfItems() - indexPath.item - 1)
        //cell.imageView.image = item.image
        let url = URL(string: item.url)
        cell.imageView.kf.setImage(with: url)
    }
    
    
}

// MARK: - CardsLayoutDelegate

extension CardSliderViewController: CardsLayoutDelegate {
    func transition(between currentIndex: Int, and nextIndex: Int, progress: CGFloat) {
        let currentItem = dataSource.item(for: dataSource.numberOfItems() - currentIndex - 1)
        let nextItem = dataSource.item(for: dataSource.numberOfItems() - nextIndex - 1)
        //ratingView.rating = (progress > 0.5 ? nextItem : currentItem).rating
        let currentTitle = CardTitle(title: currentItem.title, subtitle: currentItem.subtitle)
        let nextTitle = CardTitle(title: nextItem.title, subtitle: nextItem.subtitle)
        cardTitleView.transition(between: currentTitle, secondTitle: nextTitle, progress: progress)
    }
}

private final class BundleToken {}
