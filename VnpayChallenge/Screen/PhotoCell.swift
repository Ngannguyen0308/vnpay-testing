//
//  PhotoCell.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import UIKit


class PhotoCell: UITableViewCell {
    
    private var imageService: ImageService?
    private var currentImageURL: URL?
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: 0x1E1B1B)
        return label
    }()
    
    private lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(hex: 0x1E1B1B)
        return label
    }()
    
    private var aspectRatioConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        currentImageURL = nil
        if let constraint = aspectRatioConstraint {
            photoImageView.removeConstraint(constraint)
        }
    }
    
    private func setupViews() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sizeLabel)
        
        [photoImageView, titleLabel, sizeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor),
            
            sizeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            sizeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            sizeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            sizeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with item: PhotoItem, imageService: ImageService, in tableView: UITableView?) {
        self.imageService = imageService
        
        titleLabel.text = item.author
        sizeLabel.text = "Size: \(item.width) x \(item.height)"
        
        // Setup placeholder
        if let constraint = aspectRatioConstraint {
            photoImageView.removeConstraint(constraint)
        }
        let aspectRatio = CGFloat(item.height) / CGFloat(item.width)
        let ratioConstraint = photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: aspectRatio)
        ratioConstraint.priority = .required
        ratioConstraint.isActive = true
        self.aspectRatioConstraint = ratioConstraint
        
        photoImageView.image = nil
        
        guard let url = URL(string: item.downloadURL) else {
            return
        }
        
        currentImageURL = url
        
        imageService.downloadImg(from: url) { [weak self] result in
            guard let self = self, self.currentImageURL == url else { return }
            
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    UIView.transition(with: self.photoImageView, duration: 0.3, options: .transitionCrossDissolve) {
                        self.photoImageView.image = image
                    }
                }
                
            case .failure:
                DispatchQueue.main.async {
                    self.photoImageView.image = nil
                }
            }
        }
    }
}
