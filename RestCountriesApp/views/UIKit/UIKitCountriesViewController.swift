import UIKit
import Combine

final class UIKitCountriesViewController: UIViewController {
    
    private let viewModel: CountriesViewModel
    
    private let tableView = UITableView()
    private var cancellables = Set<AnyCancellable>()
    
    private var countries = [CountryEntity]()
    
    init(viewModel: CountriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        onLoad()
    }
    
    private func setupNavigationBar() {
        title = "UIKit Countries"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.dataSource = self
    }
    
    @MainActor
    private func onLoad() {
        Task {
            await viewModel.onLoad()
        }
        
        viewModel.$countries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countries in
                self?.countries = countries
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource

extension UIKitCountriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = countries[indexPath.row].name.common
        cell.detailTextLabel?.text = countries[indexPath.row].name.official
        return cell
    }
}
