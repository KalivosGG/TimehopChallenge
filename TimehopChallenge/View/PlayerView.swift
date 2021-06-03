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

    private var assetPlayer: AVPlayer? {
        didSet {
            DispatchQueue.main.async {
                if let layer = self.layer as? AVPlayerLayer {
                    layer.player = self.assetPlayer
                }
            }
        }
    }
    private func startLoading(_ asset: AVURLAsset) {
        var error: NSError?
        let status: AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: &error)
        if status == AVKeyValueStatus.loaded {
            let item = AVPlayerItem(asset: asset)
            playerItem = item

            let player = AVPlayer(playerItem: item)
            assetPlayer = player
            player.play()
        }
    }
    
    func play() {
        guard assetPlayer?.isPlaying == false else { return }
        DispatchQueue.main.async {
            self.assetPlayer?.play()
        }
    }
    
    func pause() {
        guard assetPlayer?.isPlaying == true else { return }
        DispatchQueue.main.async {
            self.assetPlayer?.pause()
        }
    }
    
    func cleanUp() {
        pause()
        urlAsset?.cancelLoading()
        urlAsset = nil
        assetPlayer = nil
    }
    
    deinit {
        cleanUp()
    }
    
}
