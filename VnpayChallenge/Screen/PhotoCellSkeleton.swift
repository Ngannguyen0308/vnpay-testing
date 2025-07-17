//
//  PhotoCellSkeleton.swift
//  VnpayChallenge
//
//  Created by ADMIN on 17/7/25.
//

import UIKit

class PhotoCellSkeleton: UITableViewCell {
    
    private lazy var photoPlaceholder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var titlePlaceholder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var sizePlaceholder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        view.layer.cornerRadius = 4
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        [photoPlaceholder, titlePlaceholder, sizePlaceholder].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            photoPlaceholder.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            photoPlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            photoPlaceholder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            photoPlaceholder.heightAnchor.constraint(equalTo: photoPlaceholder.widthAnchor, multiplier: 0.5),
            
            titlePlaceholder.topAnchor.constraint(equalTo: photoPlaceholder.bottomAnchor, constant: 8),
            titlePlaceholder.leadingAnchor.constraint(equalTo: photoPlaceholder.leadingAnchor),
            titlePlaceholder.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            titlePlaceholder.heightAnchor.constraint(equalToConstant: 16),
            
            sizePlaceholder.topAnchor.constraint(equalTo: titlePlaceholder.bottomAnchor, constant: 4),
            sizePlaceholder.leadingAnchor.constraint(equalTo: titlePlaceholder.leadingAnchor),
            sizePlaceholder.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            sizePlaceholder.heightAnchor.constraint(equalToConstant: 14),
            sizePlaceholder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
