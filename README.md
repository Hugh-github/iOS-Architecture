# iOS-Architecture

## 개요
> 코드에는 정답이 없기 때문에 참고 목적으로 사용하면 좋을 것 같습니다.

MVC, MVVM 패턴을 직접 구현해 보고 (수정)

---

## Architecture

IEEE에서는 소프트웨어 아키텍처에 대해 "소프트웨어를 구성하는 컴포넌트들, 이들 간의 상호작용 및 관계, 각 컴포넌트들의 특성 및 이들이 구성하는 소프트웨어의 설계 및 진화를 위한 각종 원칙들의 집합"이라고 정의합니다.

아키텍처를 프로젝트에 적용하는 과정에서 개발자마다 생각하는 방향이 다르고 지식이 다르기 때문에 정답이 없습니다. 따라서 진행하고 있는 프로젝트 성격에 따라 적절한 방법을 선택하면 됩니다.

[iOS Architecutre Pattern](https://medium.com/ios-os-x-development/ios-architecture-patterns-ecba4c38de52) 글에서는 좋은 아키텍처의 기능을 3가지로 정의하고 있습니다.
1. **Balanced distribution(균형 있는 역할 분배)**
    - 단일 책임 원칙(SRP)에 따라 역할을 나눈다. 복잡한 객체를 하나의 역할만 가지는 객체로 쪼갠다.

2. **Testability(테스트 가능성)**
    - 테스트를 가능성은 첫 번째 기능에서부터 출발합니다.
    - 테스트는 런타임 이전에 문제점을 파악하기 위해 중요합니다.

3. **Easy of use(쉬운 사용)**
    - 프로젝트를 개발하거나 유지 보수하는 과정에서 비용을 고려해야 합니다.

저는 이 중에서 테스트와 비용이 아키텍처를 사용하는 목적이라고 생각합니다. (수정)


그럼 지금부터 MVC와 MVVM 패턴에 대해 알아보겠습니다.

---

## MVC(Model-View-Controller)
MVC의 전체적인 흐름을 보자면 View에서 발생한 이벤트를 Controller에 전달합니다. Controller는 이벤트를 통해 Model을 업데이트하고 변경된 데이터를 가지고 View를 업데이트합니다.

중요한 부분은 Model과 View는 서로에 대해 알지 못합니다. 그렇기 때문에 Controller가 둘 사이의 중제자 역할을 하게 됩니다.

Model의 역할에 대해서 알아보겠습니다. 일반적으로 Model이라면 캡슐화된 데이터를 의미합니다. [MVC in iOS](https://www.kodeco.com/1000705-model-view-controller-mvc-in-ios-a-modern-approach) 예제에서는 Model의 역할을 여러 가지로 구분 짓습니다.

1. **Network code** : 응답 및 에러 처리 같은 네트워크 요청에 개념을 추상화합니다.
2. **Persistance code** : CoreData와 같은 데이터 베이스에 데이터를 저장합니다.
3. **Parsing code** : 데이터를 저희가 사용할 Model로 파싱합니다.

더 다양한 역할이 존재하지만 제가 중요하게 생각하는 부분은 위 3가지 역할입니다. Model이 화면에 필요한 캡슐화된 데이터를 가지고 있는 역할이라면 필요한 데이터를 가져오고 가공하는 작업도 Model과 같은 계층에 포함되어야 한다고 생각합니다.

```swift
// Network code
class NetworkingManager: APIService {
    static let shared = NetworkingManager(urlSession: URLSession.shared)
    
    let urlSession: URLSessionProtocol
    
    init(
        urlSession: URLSessionProtocol
    ) {
        self.urlSession = urlSession
    }
    
    func execute(endPoint: EndPoint) async throws -> Data {
        guard let request = endPoint.getRequest() else { throw NetworkingError.badRequest }
        let (data, response) = try await urlSession.data(for: request)
        try handleResponse(response)
        
        return data
    }
    
    private func handleResponse(_ response: URLResponse) throws {
        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkingError.unknownError
        }
        
        let code = urlResponse.statusCode
        
        switch code {
        case 100...199:
            return
        case 200...299:
            return
        case 300...399:
            throw NetworkingError.clientError
        case 400...499:
            throw NetworkingError.serverError
        default:
            throw NetworkingError.systemError
        }
        
    }
}

enum NetworkingError: Error {
    case badRequest
    case unknownError
    case clientError
    case serverError
    case systemError
}

// Parsing code
class JSONManager {
    static let shared = JSONManager()
    
    private init() { }
    
    private var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    func decodeData<T: Decodable>(_ data: Data) throws -> T {
        do {
            let model = try self.decoder.decode(T.self, from: data)
            return model
        } catch {
            throw JSONError.parsingError
        }
    }
}

enum JSONError: Error {
    case parsingError
}

// Model
struct Item: Hashable {
    let title: String
    let lprice: String
}

struct ItemListDTO: Decodable {
    let items: [ItemDTO]
    
    func toDomain() -> [Item] {
        return self.items.map { item in
            Item(title: item.title, lprice: item.lprice)
        }
    }
}

struct ItemDTO: Decodable {
    let title: String
    let image: String
    let lprice: String
    let hprice: String 
}
```

위 코드를 살펴보면 **NetworkManager** 객체는 서버에 데이터를 요청하고 응답을 처리하고 있습니다. 서버에서 받아온 데이터를 저희가 사용할 Model인 **Item**으로 파싱 하는 역할은 **JSONManager**가 하고 있습니다. 결과적으로 화면을 구현하는 데 필요한 **Item** 객체를 얻을 수 있습니다.

저의 예시에서는 데이터를 가지고 화면을 구현하는 View는 TableView의 Cell이기 때문에 Cell 코드를 보겠습니다.
```swift
class ItemCell: UITableViewCell {
    private let descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        adjustCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Set Cell Content
extension ItemCell {
    func setContent(text name: String, _ price: String) {
        self.nameLabel.text = name
        self.priceLabel.text = price
    }
}

// MARK: Adjust Layout
private extension ItemCell {
    func adjustCell() {
        addView()
        setLayout()
    }
    
    func addView() {
        addSubview(self.descriptionStackView)
        
        self.descriptionStackView.addArrangedSubview(self.nameLabel)
        self.descriptionStackView.addArrangedSubview(self.priceLabel)
    }
    
    func setLayout() {
        NSLayoutConstraint.activate([
            self.descriptionStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            self.descriptionStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            self.descriptionStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            self.descriptionStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

```

View를 구현하는 데 있어 확인해야 하는 체크 리스트가 존재합니다.
- **Model layer와의 상호작용 여부, 비즈니스 로직 여부**
    - `setContent` 함수를 보면 Model layer와 상호 작용이 아닌 Controller가 보내준 파라미터를 통해 Label의 text를 설정하고 있습니다.

- **UI와 관련된 작업 진행 여부**
    - Layout을 설정하는 작업을 진행하고 있습니다.

View는 오로지 화면을 구현하는 데 집중하고 있습니다.

마지막으로 Controller 코드를 확인해 보겠습니다.
```swift
final class MVCViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: CaseIterable {
        case list
    }
    
    // MARK: View
    private let listView = ItemListView()
    
    // MARK: Model
    private var itemList: [Item] = [] {
        didSet {
            configureSnapshot()
        }
    }
    
    private let jsonManager = JSONManager.shared
    private let networkingManager = NetworkingManager.shared
    
    // MARK: Create Cell
    private lazy var dataSource = DataSource(
        tableView: self.listView.itemListView
    ) { tableView, indexPath, itemIdentifier in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell else {
            return UITableViewCell()
        }
        
        let name = itemIdentifier.title
        let price = itemIdentifier.lprice
        
        cell.setContent(text: name, price)
        
        return cell
    }
    
    override func loadView() {
        self.view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.listView.itemListView.delegate = self
        setNavigation()
    }
}
```

Controller는 View와 Model에 대해 알고 있습니다. 저 같은 경우 **속성 감시자(Observer property)** 를 통해 Model이 업데이트 되면 Controller가 화면을 업데이트 하도록 코드를 구현했습니다.

화면에서 이벤트를 받아 Cell을 생성해 업데이트하는 과정을 확인해 보겠습니다.
```swift
private extension MVCViewController {
    func setNavigation() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "이름을 검색하세요."
        searchController.searchBar.delegate = self
        
        navigationItem.title = "MVC"
        navigationItem.searchController = searchController
    }
    
    func configureSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(itemList, toSection: .list)
        
        self.dataSource.apply(snapshot)
    }
}

extension MVCViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.lowercased() else { return }
        
        let endPoint = EndPoint(
            base: .naverSearch,
            query: .init(itemName: text),
            method: .get,
            header: .init()
        )
        
        Task {
            do {
                let data = try await networkingManager.execute(endPoint: endPoint)
                let itemList: ItemListDTO = try jsonManager.decodeData(data)
                self.itemList = itemList.toDomain()
            } catch {
                
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.itemList.removeAll(keepingCapacity: true)
    }
}
```
View에서 발생하는 이벤트를 Controller에 전달하는 방법은 주로 **Delegate** 패턴을 사용합니다. 실제로 Swift에서는 다양한 Delegate가 존재합니다. 위 코드 또한 Swift에서 제공하는 `UISearchBarDelegate` 를 사용하고 있습니다.

지금부터 제가 구현한 앱의 흐름을 따라가보도록 하겠습니다.
1. SearchBar를 통해 이벤트가 발생합니다.
2. 이벤트를 Controller에 전달합니다.
3. Controller는 전달받은 입력을 통해 서버 요청에 필요한 객체를 생성하고 응답을 처리해 사용할 Model을 업데이트합니다.
4. Model이 업데이트되고 Controller는 이를 확인하고 Cell을 생성해 화면을 업데이트합니다.

Controller를 통해 Model과 View를 업데이트하고 이벤트를 처리하는 것을 확인할 수 있습니다.

MVC 패턴이 위에서 언급한 좋은 아키텍처의 조건을 만족하는지 확인해 보겠습니다.
1. **역할 분배** : 접근하는 방식에 따라 충분히 역할 분배는 가능합니다. 문제는 Controller가 너무 많은 역할을 하고 있습니다. Model도 업데이트하는 동시에 View도 업데이트합니다.
2. **테스트** : Controller에 너무 많은 의존성이 존재하고 View와 연결되어 있기 때문에 Model에 관련된 코드만 테스트 가능합니다.
> NetworkManager에 대한 Mock 테스트를 진행했습니다. 테스트 코드는 MVVM 패턴에서 확인할 수 있습니다.
3. **비용** : Controller가 비대해질 수 있기 때문에 유지 보수 측면에서는 많이 비용이 필요하다고 생각합니다. 반면 구현 단계에서 생각했을 때 Controller가 많은 역할 수행이 가능하기 때문에 쉽게 접근이 가능할 것 같습니다.

다음으로는 MVVM 패턴에 대해 알아보겠습니다.

---
