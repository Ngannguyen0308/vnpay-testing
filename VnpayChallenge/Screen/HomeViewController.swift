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
        textField.leftView = HomeViewController.createSearchIcon()
        textField.leftViewMode = .always
        return textField
    }()
    
    private static func createSearchIcon() -> UIView {
        let icon = UIImageView(image: UIImage(named: "ic-search"))
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 45))
        icon.center = container.center
        container.addSubview(icon)
        return container
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    private let paginationView = PaginationView()
    
    private let refreshControl = UIRefreshControl()
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found"
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = true
        return label
    }()
    
    private var debounceWorkItem: DispatchWorkItem?
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        bindViewModel()
        setupLayout()
        setupRefreshControl()
        
        viewModel.fetchItemForPage(viewModel.currentPage)
    }
    
    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.showPaginationIfNeeded()
        }
    }
    
    private func showPaginationIfNeeded() {
        guard !viewModel.filteredPhotoList.isEmpty else {
            tableView.tableFooterView = nil
            return
        }
        
        paginationView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        tableView.tableFooterView = paginationView
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        viewModel.refreshCurrentPage()
    }
    
    private func setupLayout() {
        [titleLabel, searchTextField, tableView, noResultLabel].forEach {
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
            
            noResultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PhotoCell.self)
        tableView.register(PhotoCellSkeleton.self)
        tableView.register(LoadMorCell.self)
        
        paginationView.delegate = self
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
    
    @objc private func searchTextChanged() {
        debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            let keyword = self.searchTextField.text ?? ""
            let filtered = self.viewModel.filterPhotos(with: keyword)
            
            DispatchQueue.main.async {
                self.noResultLabel.isHidden = !filtered.isEmpty
                self.tableView.tableFooterView = filtered.isEmpty ? nil : self.paginationView
                self.tableView.reloadData()
                
                // scroll to top when searching
                if !filtered.isEmpty {
                    let topIndexPath = IndexPath(row: 0, section: 0)
                    if self.tableView.numberOfRows(inSection: 0) > 0 {
                        self.tableView.scrollToRow(at: topIndexPath, at: .top, animated: false)
                    }
                }
            }
        }
        
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }
}

// MARK: - DataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isLoading {
            return 5
        }
        return viewModel.filteredPhotoList.count + (viewModel.isPaginating ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.isLoading {
            return tableView.dequeueReusableCell(withCellType: PhotoCellSkeleton.self, for: indexPath)
        }
        
        if viewModel.isPaginating && indexPath.row == viewModel.filteredPhotoList.count {
            let cell = tableView.dequeueReusableCell(withCellType: LoadMorCell.self, for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withCellType: PhotoCell.self, for: indexPath)
        let item = viewModel.filteredPhotoList[indexPath.row]
        cell.configure(with: item, imageService: viewModel.imageService, in: tableView)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !viewModel.isLoading, !viewModel.isPaginating, !viewModel.isLastPage else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            if viewModel.currentSearchKeyword.isEmpty {
                viewModel.loadNextItem()
            }
        }
    }
}

// MARK: - Pagination
extension HomeViewController: PaginationViewDelegate {
    func pagincationViewChangePage(to page: Int) {
        viewModel.fetchItemForPage(page)
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let validated = viewModel.validateSearchInput(updatedText)
        
        textField.text = validated
        searchTextChanged()
        
        return false
    }
}

