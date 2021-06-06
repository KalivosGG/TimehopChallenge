//
//  PlayerView.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 03/06/21.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    init() {
        super.init(frame: .zero)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        initialSetup()
    }
    
    private func initialSetup() {
        if let layer = layer as? AVPlayerLayer {
            layer.videoGravity = AVLayerVideoGravity.resizeAspect
        }
    }
    private var urlAsset: AVURLAsset?
    
    func prepareToPlay(withUrl url:URL) {
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true]
        let urlAsset = AVURLAsset(url: url, options: options)
        self.urlAsset = urlAsset
        
        let keys = ["tracks"]
        urlAsset.loadValuesAsynchronously(forKeys: keys, completionHandler: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.startLoading(urlAsset)
        })
    }
    
    private var playerItem: AVPlayerItem?

    private var queuePlayer: AVQueuePlayer? {
        didSet {
            DispatchQueue.main.async {
                if let layer = self.layer as? AVPlayerLayer {
                    layer.player = self.queuePlayer
                }
            }
        }
    }
    
    private var playerLooper: AVPlayerLooper?
    
    private func startLoading(_ asset: AVURLAsset) {
        var error: NSError?
        let status: AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
        if status == AVKeyValueStatus.loaded {
            let item = AVPlayerItem(asset: asset)
            playerItem = item

            let player = AVQueuePlayer(playerItem: item)
            queuePlayer = player
            
            let looper = AVPlayerLooper(player: player, templateItem: item)
            playerLooper = looper
            
            player.play()
        }
    }
    
    func play() {
        guard queuePlayer?.isPlaying == false else { return }
        DispatchQueue.main.async {
            self.queuePlayer?.play()
        }
    }
    
    func pause() {
        guard queuePlayer?.isPlaying == true else { return }
        DispatchQueue.main.async {
            self.queuePlayer?.pause()
        }
    }
    
    func cleanUp() {
        pause()
        urlAsset?.cancelLoading()
        urlAsset = nil
        queuePlayer = nil
        playerLooper = nil
    }
    
    deinit {
        cleanUp()
    }
    
}
