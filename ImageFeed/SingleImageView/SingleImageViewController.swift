//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Kira on 14.01.2025.
//

import UIKit
import Kingfisher

// MARK: - SingleImageViewController

final class SingleImageViewController: UIViewController {
    
    // MARK: UI Components
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    
    // MARK: Public Property
    
    var fullImageUrl: URL?
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image ?? UIImage())
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        downloadImage()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let image = imageView.image ?? ImageConstants.stubImage
        rescaleAndCenterImageInScrollView(image: image)
    }
}

// MARK: - Private Methods

private extension SingleImageViewController {
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapSaveButton() {
        guard let image else { return }
        
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    // MARK: rescaleAndCenterImageInScrollView
    
    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        guard let image else { return }
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func downloadImage() {
        guard let fullImageUrl = fullImageUrl else {
            print("fullImageUrl пустой")
            return
        }
        print("Начинаем загрузку изображения с URL: \(fullImageUrl)")
        UIBlockingProgressHUD.show()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: fullImageUrl, options: [.cacheSerializer(FormatIndicatedCacheSerializer.png)]) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                UIBlockingProgressHUD.dismiss()
                print("Изображение успешно загружено")
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
                self.showError()
            }
        }
    }
}

// MARK: - UI Configuration

private extension SingleImageViewController {
    
    func setupUI() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.view.layoutIfNeeded()
    }
}

extension SingleImageViewController {
    func showError(){
        let alert  = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Не надо", style: .default)
        let repeatAction = UIAlertAction(title: "Повторить", style: .cancel) { [weak self] _ in
            self?.downloadImage()
        }
        alert.addAction(cancelAction)
        alert.addAction(repeatAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Constants

private extension SingleImageViewController {
    
    // MARK: ImageConstants
    
    enum ImageConstants {
        static let stubImage: UIImage? = .init(named: "StubImage")
    }
}
