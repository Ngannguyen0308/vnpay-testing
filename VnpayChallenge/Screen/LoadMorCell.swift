//
//  LoadMorCell.swift
//  VnpayChallenge
//
//  Created by ADMIN on 18/7/25.
//

import UIKit

class LoadMorCell: UITableViewCell {
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            loadingLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
