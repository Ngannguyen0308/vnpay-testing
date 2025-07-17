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
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        return label
    }()
    
    private lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        return label
    }()
    
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
    }
    
    private func setupViews() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sizeLabel)
        
        [photoImageView, titleLabel, sizeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            photoImageView.widthAnchor.constraint(equalToConstant: 80),
            photoImageView.heightAnchor.constraint(equalToConstant: 80),
            sizeLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            sizeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            sizeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            sizeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            sizeLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with item: PhotoItem, imageService: ImageService) {
        self.imageService = imageService
        titleLabel.text = item.author
        sizeLabel.text = "Size: \(item.width) x \(item.height)"
        
        guard let url = URL(string: item.downloadURL) else {
            photoImageView.image = nil
            return
        }
        
        currentImageURL = url
        imageService.downloadImg(from: url) { [weak self] result in
            guard let self = self, self.currentImageURL == url else { return }
            
            switch result {
            case .success(let image):
                self.photoImageView.image = image
            case .failure:
                self.photoImageView.image = nil
            }
        }
    }
}
