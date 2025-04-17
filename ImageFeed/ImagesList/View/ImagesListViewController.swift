//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Kira on 27.12.2024.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func reloadData()
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func setIsLiked(for cell: ImagesListCell, isLiked: Bool)
    func showError(_ message: String)
    func showProgressHUD()
    func hideProgressHUD()
}

// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController {
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: UI Components
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Private Property
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
     lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    // MARK: Constructor
    
    init(presenter: ImagesListPresenterProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath else {
                print("Ошибка: не удалось передать данные. Неверный идентификатор перехода или некорректный sender.")
                return
            }
            
            let url = presenter?.largeImageURL(for: indexPath.row)
            if let url {
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

// MARK: - ImagesListViewControllerProtocol

extension ImagesListViewController: ImagesListViewControllerProtocol {
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        DispatchQueue.main.async {
            self.tableView.performBatchUpdates({
                if newCount > oldCount {
                    let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                }
            })
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func setIsLiked(for cell: ImagesListCell, isLiked: Bool) {
        let likeButtonImageName = isLiked ? "like_button_on" : "like_button_off"
        let likeButtonImage = UIImage(named: likeButtonImageName)
        cell.likeButton.setImage(likeButtonImage, for: .normal)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showProgressHUD() {
        UIBlockingProgressHUD.show()
    }
    
    func hideProgressHUD() {
        UIBlockingProgressHUD.dismiss()
    }
}

// MARK: - Private Methods

private extension ImagesListViewController {
    func calculateRowHeight(_ rowNumber: Int) -> CGFloat {
        guard let image = presenter?.photo(for: rowNumber) else {
                return 44
            }
        
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
        presenter?.numberOfRowsInSection() ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell
        else {
            return UITableViewCell()
        }
        
        if let photo = presenter?.photo(for: indexPath.row) {
            configureCell(cell, with: photo)
            setIsLiked(for: cell, isLiked: photo.isLiked)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Загружаем следующую страницу фотографий, если это последняя строка
        presenter?.loadNextPhotos(for: indexPath.row)
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
        presenter?.didTapLike(for: indexPath.row)
    }
}

// MARK: - Constants

private extension ImagesListViewController {
    
    // MARK: ImageConstants
    
    enum ImageConstants {
        static let placeholderStubImage: UIImage? = .init(named: "StubImage")
    }
}
