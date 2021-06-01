//
//  MainViewController.swift
//  TimehopChallenge
//
//  Created by Victor H. Rezende Takai on 28/05/21.
//

import UIKit
import RxSwift
import RxCocoa

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
        
//        viewModel.images
//            .asObservable()
//            .subscribe(onNext: { [weak self] images in
//                var posx = 0
//                var posy = 0
//                for (index, image) in images.enumerated() {
//                    let imageView = UIImageView(image: image)
//                    imageView.frame = CGRect(origin: CGPoint(x: posx, y: posy), size: CGSize(width: 100, height: 100))
//                    imageView.contentMode = .scaleAspectFit
//                    if posx > 300 {
//                        posx = 0
//                        posy += 100
//                    } else {
//                        posx += 100
//                    }
//                    
//                    self?.stackView.insertSubview(imageView, at: index)
//                }
//            })
//        .disposed(by: disposeBag)

        viewModel.getStories()
    }
    
}

