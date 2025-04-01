//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Kira on 27.12.2024.
//

import UIKit
import Kingfisher

// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController {
    
    // MARK: UI Components
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Private Property
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private let notificationCenter = NotificationCenter.default
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupImagesListServiceObserver()
        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            // Проверка URL перед передачей
            if let url = URL(string: photo.largeImageURL) {
                print("Передается URL изображения: \(url)")
                // Передача большого изображения
                viewController.fullImageUrl = url // Передаем корректный URL
            } else {
                print("Не удалось создать URL для изображения")
                super.prepare(for: segue, sender: sender)
            }
        }
    }
}

// MARK: - Private Methods

private extension ImagesListViewController {
    func calculateRowHeight(_ rowNumber: Int) -> CGFloat {
        let image = photos[rowNumber]
        
        let imageInsets = UIEdgeInsets(
            top: 4,
            left: 16,
            bottom: 4,
            right: 16
        )
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func setIsLiked(for cell: ImagesListCell, isLiked: Bool) {
        let likeButtonImageName = isLiked ? "like_button_on" : "like_button_off"
        let likeButtonImage = UIImage(named: likeButtonImageName)
        cell.likeButton.setImage(likeButtonImage, for: .normal)
    }
    
    func configureCell(_ cell: ImagesListCell, with photo: Photo) {
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity // Показываем индикатор загрузки
            print("configureCell: загружаем изображение с URL: \(url)\n")
            
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: ImageConstants.placeholderStubImage
            ) { result in
                switch result {
                case .success(let value):
                    print("configureCell: успешно загрузили изображение: \(value.source.url?.absoluteString ?? "Нет URL")")
                    // Обновляем ячейку, чтобы применить новую высоту
                    cell.updateConstraints() // или лучше обновить таблицу
                    cell.delegate = self
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                case .failure(let error):
                    print("configureCell: не удалось загрузить изображение: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        self.photos = imagesListService.photos // Обновите массив фотографий
        let newCount = photos.count
        
        print("updateTableViewAnimated: старая количество фотографий: \(oldCount), новая количество: \(newCount)\n")
        
        tableView.performBatchUpdates({
            if newCount > oldCount {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }) { _ in
            print("updateTableViewAnimated: обновлено количество фотографий: \(self.photos.count)") // Отладочное сообщение
        }
    }
    
    func setupImagesListServiceObserver() {
        imagesListServiceObserver = notificationCenter.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
            print("setupImagesListServiceObserver: наблюдатель установлен для изменения фотографий.\n")
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UI Configuration

private extension ImagesListViewController {
    
    func setupUI() {
        tableView.rowHeight = 200
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows: \(photos.count)") // Отладочное сообщение
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell
        else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        
        configureCell(cell, with: photo)
        setIsLiked(for: cell, isLiked: photo.isLiked)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Загружаем следующую страницу фотографий, если это последняя строка
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        calculateRowHeight(indexPath.row)
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        photo.isLiked.toggle() // Меняем состояние лайка
        
        print("imageListCellDidTapLike: пользователь нажал на кнопку лайка для фотографии с id: \(photo.id)\n")
        
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                print("imageListCellDidTapLike: лайк успешно обновлен для фотографии с id: \(photo.id)\n")
                
                // Обновляем состояние локально
                self.photos[indexPath.row].isLiked = photo.isLiked
                self.setIsLiked(for: cell, isLiked: photo.isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                print("imageListCellDidTapLike: не удалось обновить лайк для фотографии с id: \(photo.id)\n") // Обработка ошибки
                self.showError("Не удалось обновить состояние лайка. Попробуйте еще раз.") // Вызов ошибки
            }
        }
    }
}

// MARK: - Constants

private extension ImagesListViewController {
    
    // MARK: ImageConstants
    
    enum ImageConstants {
        static let placeholderStubImage: UIImage? = .init(named: "StubImage")
    }
}
