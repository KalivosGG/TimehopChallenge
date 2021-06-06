//
//  MainViewController.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 28/05/21.
//

import UIKit
import RxSwift
import SnapKit

class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    private let playerView = PlayerView()
    
    private let viewModel: MainViewModel
    private let imageCache: ImageCache
    private let disposeBag = DisposeBag()
    
    private var isImageHidden: Bool = false {
        didSet {
            containerView.isHidden = !isImageHidden
            imageView.isHidden = isImageHidden
        }
    }
    
    init(viewModel: MainViewModel, imageCache: ImageCache) {
        self.viewModel = viewModel
        self.imageCache = imageCache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupGestures()
        
        viewModel.media
            .skip(1)
            //.debug()
            .asObservable()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] media in
                guard let media = media else { return }
                if media.type == .image {
                    self?.showImage(url: media.url)
                } else if media.type == .video {
                    self?.playVideo(url: media.url)
                }
            })
            .disposed(by: disposeBag)

        viewModel.getStories()
    }
    
    private func setupPlayerView() {
        containerView.addSubview(playerView)
        playerView.snp.makeConstraints { maker in
            maker.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(didTap(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(didLongPress(_:)))
        longPressGesture.minimumPressDuration = 0
        longPressGesture.numberOfTouchesRequired = 1
        longPressGesture.numberOfTapsRequired = 0
        longPressGesture.delegate = self
        view.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    private func didTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(ofTouch: 0, in: view)
        if location.x < view.bounds.width * 0.3 {
            showPreviousStory()
        } else if location.x > view.bounds.width * 0.7 {
            showNextStory()
        }
    }
    
    @objc
    private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if isImageHidden {
            if [UIGestureRecognizer.State.cancelled, .ended, .failed].contains(sender.state) {
                playerView.play()
            } else {
                playerView.pause()
            }
        }
    }
    
    private func showNextStory() {
        viewModel.getNextStory()
    }
    
    private func showPreviousStory() {
        viewModel.getPreviousStory()
    }
    
    private func showImage(url: URL) {
        if let cachedImage = imageCache.getImage(key: url.path) {
            isImageHidden = false
            playerView.pause()
            imageView.image = cachedImage
        }
    }
    
    private func playVideo(url: URL) {
        isImageHidden = true
        playerView.prepareToPlay(withUrl: url)
    }
    
}

extension MainViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

