//
//  HomeViewController.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    private let viewModel: HomeViewModel
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Photo Gallery"
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textColor = UIColor(hex: 0x1E1B1B)
        return label
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search here"
        textField.borderStyle = .none
        textField.layer.cornerRadius = 10
        textField.backgroundColor = .cyan
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        textField.isSecureTextEntry = false
        
        // add icon on the left
        let icon = UIImageView(image: UIImage(named: "ic-search"))
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 45))
        icon.center = container.center
        container.addSubview(icon)
        
        textField.leftView = container
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var tableView = UITableView(
        frame: .zero,
        style: .plain
    )
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        bindViewModel()
        setupLayout()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        viewModel.fetchingPhotoList()
    }
    
    private func setupLayout() {
        [titleLabel, searchTextField, tableView].forEach { view.addSubview($0) }
        
        [titleLabel, searchTextField, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 45),
            
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PhotoCell.self)
    }
}

// MARK: - DataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.photoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cells = tableView.dequeueReusableCell(
            withCellType: PhotoCell.self, for: indexPath)
        let item = viewModel.photoList[indexPath.row]
        cells.configure(with: item, imageService: viewModel.imageService)
        
        return cells
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate { }

