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
        textField.backgroundColor = .lightGray
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
    
    private let paginationView = PaginationView()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            
            if self.viewModel.isLoading || self.viewModel.photoList.isEmpty {
                self.tableView.tableFooterView = nil
            } else {
                self.showPaginationIfNeeded()
            }
        }
    }
    
    private func showPaginationIfNeeded() {
        //        guard tableView.tableFooterView !== paginationView else { return }
        //
        //        paginationView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        //        tableView.tableFooterView = paginationView
        paginationView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        if tableView.tableFooterView !== paginationView {
            tableView.tableFooterView = paginationView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        bindViewModel()
        setupLayout()
        
        viewModel.fetchItemForPage(viewModel.currentPage)
    }
    
    private func setupLayout() {
        [titleLabel, searchTextField, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PhotoCell.self)
        tableView.register(PhotoCellSkeleton.self)
        tableView.register(LoadMorCell.self)
        
        paginationView.delegate = self
    }
}

// MARK: - DataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isLoading {
            return 5
        }
        print("CHECK COUNT OF DATA \(viewModel.photoList.count)")
        
        return viewModel.photoList.count + (viewModel.isPaginating ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // First load
        if viewModel.isLoading {
            return tableView.dequeueReusableCell(
                withCellType: PhotoCellSkeleton.self, for: indexPath)
        }
        
        // Bottom loading for pagination
        if viewModel.isPaginating && indexPath.row == viewModel.photoList.count {
            let cell = tableView.dequeueReusableCell(withCellType: LoadMorCell.self, for: indexPath)
            cell.textLabel?.text = "Loading..."
            cell.textLabel?.textColor = .gray
            cell.textLabel?.textAlignment = .center
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withCellType: PhotoCell.self, for: indexPath)
        
        let item = viewModel.photoList[indexPath.row]
        cell.configure(with: item, imageService: viewModel.imageService, in: tableView)
        return cell
    }
}


// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100,
           !viewModel.isLoading, !viewModel.isPaginating, !viewModel.isLastPage {
            viewModel.loadNextItem()
        }
    }
}

extension HomeViewController: PaginationViewDelegate {
    func pagincationViewChangePage(to page: Int) {
        viewModel.fetchItemForPage(page)
    }
}
