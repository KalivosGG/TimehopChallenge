//
//  MainViewController.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 28/05/21.
//

import UIKit
import RxSwift
import RxCocoa
import AVKit
import AVFoundation
import SnapKit

class MainViewController: UIViewController {

    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let playerView = PlayerView()
    var isPlaying = false
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        
        viewModel.media
            .debug()
            .asObservable()
            .subscribe(onNext: { [weak self] media in
                guard let media = media, let strongSelf = self else {
                    return
                }
                
                if let url = media.url,
                   media.type == .video,
                   !strongSelf.isPlaying {
                    strongSelf.playVideo(url: url)
                }
            })
            .disposed(by: disposeBag)

        viewModel.getStories()
    }
    
    private func setupPlayerView() {
        view.backgroundColor = .white
        view.addSubview(containerView)
        containerView.snp.makeConstraints { maker in
            maker.top.bottom.leading.trailing.equalToSuperview()
        }
               
        containerView.addSubview(playerView)
        playerView.snp.makeConstraints { maker in
            maker.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func playVideo(url: URL) {
        isPlaying = true
        playerView.prepareToPlay(withUrl: url)
    }
    
}

