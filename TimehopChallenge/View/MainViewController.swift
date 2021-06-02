//
//  MainViewController.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 28/05/21.
//

import UIKit
import RxSwift
import RxCocoa
import Swime

class MainViewController: UIViewController {

    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var stackView: UIStackView!
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.id
            .skip(1)
            .asObservable()
            .subscribe(onNext: { [weak self] id in
                let filePath = FileManager.cacheFilePath(id)
                if let data = FileManager.default.contents(atPath: filePath) {
                    let mimeType = Swime.mimeType(data: data)
                    switch mimeType?.type {
                    case .jpg, .png:
                        self?.test(data: data)
                    case .mp4, .avi, .mov, .wmv, .webm:
                        // Other stuff
                        print("Video found")
                        break
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.getStories()
    }
    
    // Test
    var posx = 0
    var posy = 0
    
    private func test(data: Data) {
        let image = UIImage(data: data)
  
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPoint(x: posx, y: posy), size: CGSize(width: 100, height: 100))
        imageView.contentMode = .scaleAspectFit
        if posx > 300 {
            posx = 0
            posy += 100
        } else {
            posx += 100
        }

        stackView.insertSubview(imageView, at: 0)
    }
    
}

