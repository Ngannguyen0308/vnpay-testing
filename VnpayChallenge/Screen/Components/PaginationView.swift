//
//  PaginationView.swift
//  VnpayChallenge
//
//  Created by ADMIN on 17/7/25.
//

import UIKit

protocol PaginationViewDelegate: AnyObject {
    func pagincationViewChangePage(to page: Int)
}

class PaginationView: UIView {
    weak var delegate: PaginationViewDelegate?
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Prev", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        return button
    }()
    
    private let pageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Page 1 / 10"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private var currentPage: Int = 1 {
        didSet {
            updateLayoutPaging()
            delegate?.pagincationViewChangePage(to: currentPage)
        }
    }
    
    var totalPages: Int = 10 {
        didSet {
            updateLayoutPaging()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayoutPaging()
        setupAction()
        updateLayoutPaging()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayoutPaging() {
        let stackView = UIStackView(arrangedSubviews: [previousButton, pageLabel, nextButton])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    private func setupAction() {
        previousButton.addTarget(self, action: #selector(didTapPrevious), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }
    
    private func updateLayoutPaging() {
        pageLabel.text = "Page \(currentPage) / \(totalPages)"
        previousButton.isEnabled = currentPage > 1
        nextButton.isEnabled = currentPage < totalPages
    }
    
    @objc private func didTapPrevious() {
        if currentPage > 1 {
            currentPage -= 1
        }
    }
    
    @objc private func didTapNext() {
        if currentPage < totalPages {
            currentPage += 1
        }
    }
    
    func setPage(_ page: Int) {
        guard page >= 1 && page <= totalPages else { return }
        currentPage = page
    }
    
    func getCurrentPage() -> Int {
        return currentPage
    }
}
