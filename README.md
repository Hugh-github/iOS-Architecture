# iOS-Architecture

## 개요

> **주의사항 : 코드에는 정답이 없기 때문에 참고 목적으로 사용하면 좋을 것 같습니다.**

간단한 예제를 MVC, MVVM 패턴으로 구현해 보고 느낀 점에 대해 작성한 글입니다.

|검색|제거|취소|
|---|---|---|
|![검색](https://github.com/Hugh-github/iOS-Architecture/assets/102569735/312f7e3f-0e92-4b74-89ef-545ec95f6e69)|![제거](https://github.com/Hugh-github/iOS-Architecture/assets/102569735/f86619ed-7acc-4664-9cd6-e88c135bf480)|![취소](https://github.com/Hugh-github/iOS-Architecture/assets/102569735/f98156ec-3aff-4f1a-a711-bb51315f17d4)|
---

## Architecture


IEEE에서는 소프트웨어 아키텍처에 대해 "소프트웨어를 구성하는 컴포넌트들, 이들 간의 상호작용 및 관계, 각 컴포넌트들의 특성 및 이들이 구성하는 소프트웨어의 설계 및 진화를 위한 각종 원칙들의 집합"이라고 정의합니다.

아키텍처를 프로젝트에 적용하는 과정에서 개발자마다 생각하는 방향이 다르고 지식이 다르기 때문에 정답이 없습니다. 따라서 진행하고 있는 프로젝트 성격에 따라 적절한 방법을 선택하는 게 좋습니다.

[iOS Architecutre Pattern](https://medium.com/ios-os-x-development/ios-architecture-patterns-ecba4c38de52) 글에서는 좋은 아키텍처의 기능을 3가지로 정의하고 있습니다.

1. **Balanced distribution(균형 있는 역할 분배)**
    - 단일 책임 원칙(SRP)에 따라 역할을 나눈다. 복잡한 객체를 하나의 역할만 가지는 객체로 쪼갠다.
2. **Testability(테스트 가능성)**
    - 테스트를 가능성은 첫 번째 기능에서부터 출발합니다.
    - 테스트는 런타임 이전에 문제점을 파악하기 위해 중요합니다.
3. **Easy of use(쉬운 사용)**
    - 프로젝트를 개발하거나 유지 보수하는 과정에서 비용을 고려해야 합니다.

저는 이 중에서 테스트와 비용이 아키텍처를 사용하는 목적이라고 생각합니다. 균형 있는 역할 분배를 하는 목적은 비용과 연관이 있다고 생각합니다. 개발 단계에서는 객체를 쪼개는 작업이 오래 걸리지만 유지 보수 측면에서는 장점이 있기 때문입니다.

그럼 지금부터 MVC와 MVVM 패턴에 대해 알아보겠습니다.

---

## MVC(Model-View-Controller)

<img width="776" alt="스크린샷 2023-06-27 오후 9 39 51" src="https://github.com/Hugh-github/iOS-Architecture/assets/102569735/0ab3c91d-1b70-4f70-acb6-402f645a1969">

MVC 패턴의 가장 중요한 Point는 Model과 View는 서로를 모른다는 점입니다. 그렇기 때문에 Controller를 통해 Model과 View를 업데이트 합니다.

각 객체의 역할을 정리하자면 View는 UserAction을 받을 수 있고 정보를 제공하는 화면입니다. Controller는 View와 Model 사이를 연결하는 역할을 합니다. Model은 구현에 필요한 데이터와 비즈니스 로직을 가지고 있습니다.

여기서 Model의 비즈니스 로직은 단순히 데이터를 변화시키는 로직만 포함되는지 궁금증이 생겼습니다. [MVC in iOS](https://www.kodeco.com/1000705-model-view-controller-mvc-in-ios-a-modern-approach) 예제에서는 Model의 역할을 여러 가지로 구분 짓습니다. 

1. **Network code** : 응답 및 에러 처리 같은 네트워크 요청에 개념을 추상화합니다.
2. **Persistance code** : CoreData와 같은 데이터 베이스에 데이터를 저장합니다.
3. **Parsing code** : 데이터를 저희가 사용할 Model로 파싱합니다.

예제에서는 더 많은 역할에 대해 다루고 있습니다. 저는 위 3개에 역할은 데이터를 불러오고 가공하는 역할을 하기 때문에 Model의 비즈니스 로직에 포함되기 적절하다고 생각합니다.

이번 예제 코드에서는 Network Code와 Parsing Code를 활용해 MVC 패턴을 구현해 보도록 하겠습니다.

### Network Code
```swift
class NetworkManager {
    static let shared = NetworkManager(urlSession: URLSession.shared)
    
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
```

### Parsing Code
```swift
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
```
**Network Code**를 활용해 서버에서 json 데이터를 받아올 수 있습니다. 하지만 json 데이터를 그냥 사용할 수 없기 때문에 가공이 필요합니다. **Parsing Code**를 통해 사용할 수 있는 형태로 가공을 해야 합니다.

가공한 데이터를 바로 사용할 수 있지만 화면을 구현하는 데 있어 모든 정보가 필요하지는 않습니다. 그렇다면 추가 작업을 통해 우리가 원하는 Model을 만들어 주어야 합니다. 

```swift
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

struct Item: Hashable {
    let title: String
    let lprice: String
}
```
이번 예제에서는 앱을 구현하기 위해 필요한 정보는 `title`과 `lprice`입니다. **ItemDTO**를 그대로 사용하는 것이 아니라 원하는 정보만 가지고 있는 **Item**으로 다시 Mapping을 진행할 수 있습니다.

이제 화면을 구현하기 위한 Model을 얻었습니다. 하지만 저는 Item 리스트를 관리하기 위해 객체를 하나더 만들었습니다.


**ItemStore**는 Item이 변하면 `NotificationCenter`를 이용해 Controller에 알림을 보냅니다. 또한 Item에 대한 비즈니스 로직을 가지고 있습니다.

```swift
class ItemStore {
    private var store: [Item] = [] {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("ItemStore"), object: nil)
        }
    }
    
    func appendItem(_ item: Item) {
        self.store.append(item)
    }
    
    func getItemList() -> [Item] {
        return self.store
    }
    
    func deleteItem(_ index: Int) {
        self.store.remove(at: index)
    }
    
    func deleteAllItem() {
        self.store.removeAll()
    }
}
```

### View

View를 구현하는 데 있어 확인해야 하는 체크 리스트가 존재합니다.

- **Model layer와의 상호작용 여부, 비즈니스 로직 여부**
- **UI와 관련된 작업 진행 여부** 

View와 Model은 분리되어 있기 때문에 View는 화면을 구현하는 데 집중해야 합니다.

```swift
class ItemListView: UIView {
    let itemListView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .secondarySystemBackground
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ItemListView {
    func setLayout() {
        addSubview(itemListView)
        
        NSLayoutConstraint.activate([
            self.itemListView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            self.itemListView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            self.itemListView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            self.itemListView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
```

View에서 발생하는 UserAction은 `Delegate` 패턴을 이용해 Controller에서 처리합니다. `ItemListView`에서 검색한 정보를 List 형태로 제공하기 위한 UITableView가 존재합니다. TableView에서 UserAction이 발생하면 Controller에서 처리하게 됩니다.


### Controller
```swift
final class MVCViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: View
    private let listView = ItemListView()
    
    // MARK: Model
    private let itemStore = ItemStore()
    private let apiService = ItemAPIService()
    
    enum Section: CaseIterable {
        case list
    }
    
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configureSnapshot),
            name: Notification.Name("ItemStore"),
            object: nil
        )
        setNavigation()
    }
}

extension MVCViewController {
    @objc private func configureSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(itemStore.getItemList(), toSection: .list)

        self.dataSource.apply(snapshot)
    }
}

private extension MVCViewController {
    func setNavigation() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "이름을 검색하세요."
        searchController.searchBar.delegate = self
        
        navigationItem.title = "MVC"
        navigationItem.searchController = searchController
    }
    
    func configureAlert(_ message: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: "OK",
            style: .destructive
        )
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: false)
    }
}

extension MVCViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            self.itemStore.deleteItem(indexPath.row)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension MVCViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.lowercased() else { return }
        
        Task {
            do {
                guard let list = try await apiService.getItemList(query: .init(itemName: text)) else { return }
                
                list.forEach { item in
                    self.itemStore.appendItem(item)
                }
            } catch (let error){
                guard let error = error as? NetworkingError else { return }
                
                configureAlert(error.description)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.itemStore.deleteAllItem()
    }
}

```

Controller는 View의 대리자가 됩니다. UserAction이 발생하면 Model을 업데이트합니다. 그렇기 때문에 View는 Model을 직접 알지 못해도 Model을 변화시킬 수 있습니다. Model이 업데이트 되면 Controller는 알림을 받아 View를 업데이트 합니다.

MVC 패턴이 위에서 언급한 좋은 아키텍처의 조건을 만족하는지 확인해 보겠습니다.

1. **역할 분배** : 접근하는 방식에 따라 Model의 비즈니스 로직의 범위를 설정함으로써 역할 분배가 가능합니다.
2. **테스트** : Controller가 정상적으로 동작한다면 View가 업데이트됩니다. 하지만 Controller를 테스트하기에는 너무 많은 의존성이 존재합니다. 다양한 View도 알고 있으면 Model Code들도 가지고 있기 때문에 Controller에 대해 테스트를 진행하기 어렵습니다.
3. **비용** : Controller가 비대해질 수 있기 때문에 유지 보수 측면에서는 많이 비용이 필요하다고 생각합니다. 반면 구현 단계에서 생각했을 때 Controller가 많은 역할 수행이 가능하기 때문에 쉽게 접근이 가능할 것 같습니다.

---
## MVVM(Model - View - ViewModel)
MVC 패턴의 단점 중 하나는 Controller가 너무 많은 역할을 하기 때문에 비대해지고 View와 연결되어 있기 때문에 테스트를 진행하기 어려웠습니다.

<img width="825" alt="스크린샷 2023-07-02 오후 1 41 06" src="https://github.com/Hugh-github/iOS-Architecture/assets/102569735/4d06ca66-f5ab-4ab6-8aec-2d7d4bdf6a14">

MVVM과 MVC 패턴의 차이점을 정리해보겠습니다.
1. **Binding**
    - 데이터 바인딩을 통해 View를 업데이트 합니다.
2. **Controller의 역할**
    - MVVM에서 Controller는 View로 생각합니다.

즉, View는 화면을 초기화하고 레이아웃을 다시 설정하는 역할을 합니다. 화면에 필요한 로직은 ViewModel을 통해 처리됩니다. 하지만 이 부분에 대해서는 개인이 생각하는 로직의 수준에 따라 달라진다고 생각합니다. 예를 들어 ViewModel에서 가지고 있는 Int 타입 데이터를 Label의 text로 설정하기 위해서는 String 타입으로 변환해야 합니다. 변환 작업을 ViewModel에서 진행해도 되지만 그 정도의 간단한 작업 정도는 View에서 진행해도 괜찮다고 생각하는 경우도 있습니다. 물론 각각의 장단점은 존재합니다. ViewModel에서 로직을 처리한다면 View는 오로지 화면을 그리는데 집중할 수 있습니다. 반면 View에서 해당 로직을 진행한다면 ViewModel은 자신이 가지고 있는 데이터에만 집중할 수 있습니다. 

### Binding
ViewModel은 Binding을 통해 View를 업데이트 합니다. 하지만 ViewModel 코드를 보면 View를 직접 참조하고 있지 않습니다.

Binding을 통해 View를 업데이트합니다. Binding을 구현하는 방법에 대해서 알아보겠습니다. 우선 관찰 가능한 데이터를 만들어야 합니다.

> 해당 글에서는 RxSwfit와 같은 라이브러리를 사용하지 않기 때문에 직접 구현해보겠습니다.

```swift
class Observable<T> {
    
    struct Observer<T> {
        weak var observer: AnyObject?
        let listener: (T) -> Void
    }
    
    var value: T {
        didSet {
            notifyObservers()
        }
    }
    
    private var observers = [Observer<T>]()
    
    init(_ value: T) {
        self.value = value
    }
    
    func addObserver(on observer: AnyObject, _ closure: @escaping (T) -> Void) {
        observers.append(Observer(observer: observer, listener: closure))
    }
    
    func removeObserver(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.listener(value)
        }
    }
}
```

위 코드처럼 Binding은 **Observer** 패턴으로 구현이 가능합니다. 해당 데이터를 관찰하는 객체를 저장하고 해당 객체에서 동작해야 하는 업데이트 코드를 동작시킵니다. 여기서 주의할 점은 **Observer** 패턴은 관찰자를 등록하는 코드(`addObserver`)와 제거하는 코드(`removeObserver`)가 반드시 필요합니다. 또한 어느 시점에 해당 함수들을 호출할지 고민할 필요가 있습니다.

> Observer 객체를 등록하고 해지하지 않는다면 memory leak이 발생할 수 있습니다.

그렇다면 이제 ViewModel 코드를 확인해 보겠습니다. 먼저 enum을 사용해 View에서 ViewModel에 보낼 수 있는 Action(이벤트)을 정의했습니다.
```swift
enum Action {
    case searchItem(String)
    case deleteItem(Int)
    case cancelSearch
}
```
이 부분 같은 경우는 반드시 필수가 아니라고 생각합니다. 개인적인 생각으로는 View에서 발생할 수 있는 Action을 정의하고 사용하면 View에서 각각의 이벤트가 발생할 때 필요한 함수를 직접 호출하는 게 아닌 하나의 함수를 통해 Model을 업데이트하는 로직을 실행할 수 있다고 판단했습니다.

```swift
class ItemViewModel {
    // Event
    enum Action {
        case searchItem(String)
        case deleteItem(Int)
        case cancelSearch
    }
    
    // Network Code Or Parsing Code
    private let networkManager = NetworkingManager.shared
    private let jsonManager = JSONManager.shared
    
    
    // Model
    private var itemList = Observable<[Item]>([])
    
    var errorHandling: ((String) -> ()) = { _ in } // 에러 처리
    
    func execute(action: Action) {
        switch action {
        case .searchItem(let name):
            fetchData(name)
        case .deleteItem(let index):
            delete(index)
        case .cancelSearch:
            remove()
        }
    }
    
    func subscribe(on object: AnyObject, handling: @escaping ([Item]) -> Void) {
        self.itemList.addObserver(on: object, handling)
    }
    
    func unsubscribe(on object: AnyObject) {
        self.itemList.removeObserver(observer: object)
    }
}

private extension ItemViewModel {
    func fetchData(_ name: String) {
        let endPoint = EndPoint(
            base: .naverSearch,
            query: .init(itemName: name),
            method: .get,
            header: .init()
        )
        
        Task {
            do {
                let data = try await networkManager.execute(endPoint: endPoint)
                let itemList: ItemListDTO = try jsonManager.decodeData(data)
                self.itemList.value = itemList.toDomain()
            } catch let error {
                guard let error = error as? NetworkingError else { return }
                errorHandling(error.description)
            }
        }
    }
    
    func delete(_ index: Int) {
        self.itemList.value.remove(at: index)
    }
    
    func remove() {
        self.itemList.value.removeAll()
    }
}
```

실제로 제가 작성한 ViewModel 코드를 보면 실제 Model을 업데이트 하는 함수인 `fetchData`, `delete`, `remove`는 View에서 접근이 불가능합니다.

View에서는 `execute` 함수를 호출해 사용자의 Action을 ViewModel에 전달하면 ViewModel은 Action에 따른 비즈니스 로직을 처리하고 데이터(`itemList`)를 업데이트합니다. `itemList` 가 업데이트되면 아까 위에서 확인한 **Observable**의 `notifyObservers` 함수가 호출되며 View가 업데이트됩니다.

마지막으로 Controller 코드를 확인해 보겠습니다.
```swift
class MVVMViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: CaseIterable {
        case list
    }
    
    // MARK: ViewModel
    private let viewModel = ItemViewModel()
    
    // MARK: View
    private let listView = ItemListView()
    
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
        
        self.setNavigation()
        self.setDataBinding()
        self.setErrorHandling()
    }
}

// MARK: Set ViewModel Closure
private extension MVVMViewController {
    func setNavigation() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "이름을 검색하세요."
        searchController.searchBar.delegate = self
        
        navigationItem.title = "MVVM"
        navigationItem.searchController = searchController
    }
    
    func setDataBinding() {
        self.viewModel.subscribe(on: self) { [weak self] itemList in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.configureSnapshot(itemList)
            }
        }
    }
    
    func setErrorHandling() {
        self.viewModel.errorHandling = { [weak self] message in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.configureAlert(message)
            }
        }
    }
    
    func configureSnapshot(_ items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(items, toSection: .list)
        
        self.dataSource.apply(snapshot)
    }
    
    func configureAlert(_ message: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(
            title: "OK",
            style: .destructive
        )
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: false)
    }
}

extension MVVMViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            self.viewModel.execute(action: .deleteItem(indexPath.row))
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension MVVMViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.lowercased() else { return }
        
        self.viewModel.execute(action: .searchItem(text))
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.execute(action: .cancelSearch)
    }
}
```

MVC 패턴과의 차이점은 Controller가 ViewModel과 View만 가지고 있게 된 것입니다. 또한 각각의 이벤트에 대한 비즈니스 로직을 직접 처리하는 것이 아닌 ViewModel의 함수를 호출해 처리하고 있습니다.

그럼 MVVM 패턴이 좋은 아키텍처의 조건을 만족하는지 확인해 보겠습니다.
1. **역할 분배** : MVC 패턴에서 Controller가 많은 역할을 하는 문제점은 해결할 수 있었습니다. 하지만 여전히 ViewModel에서 많은 역할을 수행하고 있다고 생각할 수 있습니다.
2. **테스트** : ViewModel은 View를 직접적으로 가지고 있지 않기 때문에 테스트 가능합니다. 하지만 너무 많은 의존성을 가지고 있다면 테스트 진행이 힘들 수 있습니다.
3. **비용** : 위 예시는 간단하기 때문에 복잡하지 않다고 생각할 수 있습니다. 하지만 ViewModel과 View는 1:N 관계를 가질 수 있기 때문에 여러 View에서 하나의 ViewModel에 의존하고 있다면 분리해서 관리하는 것이 효율적일 것입니다. 그렇다면 좀 더 다양한 객체를 관리하고 구현해야 하기 때문에 개발 단계에서는 많은 비용이 필요할 것이라고 생각합니다. 하지만 유지 보수 과정에서는 그만큼 큰 이점이 존재할 것이라고 생각합니다.

> **주의 : 개인적인 의견이 포함되어 있습니다.**

MVVM 패턴을 사용한다면 테스트 부분에서 큰 이점을 가질 수 있습니다. 저도 이 부분이 MVVM 패턴에 가장 큰 장점이라고 생각합니다.

어떻게 테스트 코드를 작성해야 하고 어떤 테스트를 진행해야 하는지에 대해서 알아보겠습니다.

---
## Test
테스트 코드를 작성하기 위해서는 **Test Double, Dependency Injection, 추상화, Side Effect** 등 몇 가지 고려해야 할 사항이 존재합니다.

**Test Double의 종류**에 대해 알아보겠습니다.
+ **Dummy** : 가장 기본적인 테스트 방법이다. 인스턴스화 된 객체가 필요하지만 기능은 필요하지 않은 경우에 사용한다.
+ **Fake** : 복잡한 로직이나 객체 내부에서 필요로 하는 다른 외부 객체들의 동작을 단순화하여 구현한 객체를 사용해 테스트 하는 방법이다.
+ **Stub** : Dummy 객체가 실제로 동작하는 것 처럼 보이게 만들어 놓은 객체를 이용해 테스트 하는 방법이다. 테스트에서 호출된 요청에 대해 미리 준비해둔 결과를 제공한다.
+ **Spy** : Stub의 역할을 가지면서 호출된 내용에 대해 약간의 정보를 기록한다. 실제 객체처럼 동작시킬 수도 있고, 필요한 부분에 대해서는 Stub으로 만들어서 동작을 지정할 수도 있다.
+ **Mock** : 호출에 대한 기대를 명세하고 내용에 따라 동작하도록 프로그래밍 된 객체를 이용해 테스트하는 방법이다.

Mock, Stub을 이용해 ViewModel 테스트를 진행하도록 하겠습니다. 그 외 나머지 고려해야 하는 부분에 대해서는 코드를 보며 얘기해 보겠습니다.

### Network Test

```swift
protocol URLSessionProtocol {
    func data(for: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }

class MockURLSession: URLSessionProtocol {
    var statusCode: Int
    
    init(
        statusCode: Int
    ) {
        self.statusCode = statusCode
    }
    
    func data(for: URLRequest) async throws -> (Data, URLResponse) {
        guard let url = Bundle.main.url(forResource: "MockItemList", withExtension: "json") else {
            throw NetworkingError.unknownError
        }
        
        let data = try Data(contentsOf: url)
        
        let httpURLResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )! as URLResponse
        
        return (data, httpURLResponse)
    }
}
```

위 코드를 보면 `URLSessionProtocol`이 한 가지 함수를 정의했습니다. 함수는 실제 URLSession에 있는 `data(for: URLRequest) async throws -> (Data, URLResponse)`입니다. 그렇기 때문에 코드에서처럼 URLSession에서 프로토콜을 채택해도 문제가 없음을 확인할 수 있습니다.

프로토콜을 채택한 `MockURLSession`을 만들어 테스트를 하기 위한 데이터와 응답을 제공할 수 있습니다. 위 코드에서는 서버에서 제공하는 응답 코드를 주입시켜 테스트를 진행하도록 코드를 작성했습니다. 즉, statusCode가 200번이라면 성공했다고 판단해 데이터를 확인할 수 있고 아니라면 각각 상황에 맞는 에러를 확인할 수 있습니다.

> 서버가 없는 상태에서도 개발을 진행하며 테스트를 해야할 경우 가짜 URLSession을 이용해 테스트가 가능합니다.

```swift
class NetworkManager {
    static let shared = NetworkManager(urlSession: URLSession.shared)
    
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

```
`NetworkManager` 코드를 보면 의존성 주입을 통해 URLSessionProtocol을 주입받고 있습니다. 실제 구현 시에는 URLSession을 사용하고 테스트 시에는 MockURLSession을 사용할 수 있습니다.

정리하자면 추상화를 통해 필요한 기능을 정의하고 추상화한 프로토콜을 채택한 객체를 구현해 실제 테스트를 진행할 객체에서 의존성 주입을 통해 상황에 맞게 사용할 수 있습니다. (정리 필요)

```swift
final class MockNetworkingTests: XCTestCase {
    var networkManger: NetworkManager? = nil
    var mockURLSession: MockURLSession? = nil
    var apiService: ItemAPIService? = nil
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        self.mockURLSession = MockURLSession(
            statusCode: 200
        )
        
        self.networkManger = NetworkManager(
            urlSession: mockURLSession!
        )
        
        self.apiService = ItemAPIService(
            networkManager: networkManger!
        )
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        self.mockURLSession = nil
        self.networkManger = nil
        self.apiService = nil
    }
    
    func test_응답이_성공일때_Data가_같은지_확인() async throws {
        let expectation = XCTestExpectation(description: "APIPrivoderTaskExpectation")
        let query = RequestQuery(itemName: "아이폰")
        
        let result = [
            Item(title: "아이폰 11", lprice: "1500"),
            Item(title: "아이폰 12", lprice: "1600"),
            Item(title: "아이폰 13", lprice: "1700"),
            Item(title: "아이폰 14", lprice: "1800"),
            Item(title: "아이폰 15", lprice: "1900")
        ]
        
        let data = try await apiService?.getItemList(query: query)
        expectation.fulfill()
                
        XCTAssertEqual(result, data)
    }
    
    func test_서버에서_응답으로_300번을_보내면_정상적으로_처리하는지_확인() async throws {
        let expectation = XCTestExpectation(description: "APIPrivoderTaskExpectation")
        let query = RequestQuery(itemName: "아이폰")
        
        self.mockURLSession?.statusCode = 300
        self.networkManger = NetworkManager(urlSession: mockURLSession!)
        self.apiService = ItemAPIService(networkManager: networkManger!)
        
        do {
            let _ = try await apiService?.getItemList(query: query)
            expectation.fulfill()
        } catch (let error) {
            XCTAssertEqual(error as! NetworkingError, NetworkingError.clientError)
        }
    }
}
```

Network, Parsing을 담당하고 있는 APIServie에 대해 테스트를 진행했습니다. 테스트는 항상 성공하는 상황보다 실패할 수 있는 상황에 대해서도 진행해야 합니다. 저는 여기서 2가지의 테스트를 진행했습니다. 첫 번째는 정상적으로 데이터를 불러왔을 때 예상한 결과와 일치하는지 확인하는 테스트와 만약 서버에서 300번 응답을 보냈을 때 정상적으로 에러를 반환하는지 확인했습니다. (정리 필요)

또한 서버와 통신해 데이터를 가져오는 과정이 비동기적으로 동작하기 때문에 몇가지 설정이 필요합니다. 
<img width="443" alt="스크린샷 2023-07-07 오후 1 12 18" src="https://github.com/Hugh-github/iOS-Architecture/assets/102569735/dd7677d8-a260-4286-b228-31c5f7544f29">

`XCTestExpectation`은 사진처럼 비동기 테스트에서 예상되는 결과입니다. 해당 객체를 선언한 뒤 `fullfill()` 함수를 호출해 정상적으로 작업이 완료됐는지 확인해야 합니다.

### ViewModel Test
다음으로는 ViewModel 테스트를 진행해 보도록 하겠습니다. ViewModel 코드를 보면 APIService를 사용해 Model을 불러 옵니다. 즉 저희는 가짜 Model을 불러와 줄 Stub 객체가 필요합니다.

네트워크 테스트와 마찬가지로 추상화하 의존성 주입을 통해 StubAPIService를 사용해 ViewModel 테스트를 진행할 수 있습니다.

```swift 
protocol APIService {
    var networkManager: NetworkManager { get }
    
    func getItemList(query: RequestQuery) async throws -> [Item]?
}

class StubItemAPIService: APIService {
    private let items: [Item]
    var networkManager: NetworkManager
    
    init(
        items: [Item],
        networkManager: NetworkManager = NetworkManager.shared
    ) {
        self.items = items
        self.networkManager = networkManager
    }
    
    func getItemList(query: RequestQuery) async throws -> [Item]? {
        return items
    }
}

```

`APIService`에서 반드시 정의해야 하는 것은 두 가지 입니다. 하나는 서버와 통신하기 위한 `NetworkManager` 그리고 저희가 Model로 사용할 [Item] 을 반환하는 함수 `getItemList` 입니다.

그러면 `NetworkManager`는 MockURLSession을 주입받아 사용해야 한다고 생각할 수 있습니다. 하지만 저는 `NetworkManager.shared`를 사용하기 때문에 실제 `URLSession`을 사용하고 있습니다. 이미 네트워크 테스트를 통해 정상적으로 동작하는지 확인을 진행하였고 크게 중요한 부분은 아니라고 생각합니다. 여기서 중요한 점은 Stub 객체를 통해 ViewModel에서 필요한 Model을 불러오는 것입니다.

그러면 ViewModel 테스트 코드를 확인해 보겠습니다.
```swift
final class StubViewModelTest: XCTestCase {
    var viewModel: ItemViewModel! = nil
    var stubAPIService: APIService! = nil
    
    var data = [
        Item(title: "아이폰 11", lprice: "1500"),
        Item(title: "아이폰 12", lprice: "1600"),
        Item(title: "아이폰 13", lprice: "1700"),
        Item(title: "아이폰 14", lprice: "1800"),
        Item(title: "아이폰 15", lprice: "1900")
    ]
    

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        self.stubAPIService = StubItemAPIService(items: data)
        self.viewModel = ItemViewModel(apiService: stubAPIService)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        self.stubAPIService = nil
        self.viewModel = nil
    }

    func test_검색이_완료되면_원하는_결과를_가져오는지_확인() async {
        let expectation = XCTestExpectation(description: "ViewModelTest")
        viewModel.execute(action: .searchItem("아이폰"))
        expectation.fulfill()
        wait(for: [expectation], timeout: 3.0)
        
        print(viewModel.itemList.value)
        
        XCTAssertEqual(viewModel.itemList.value, data)
    }
    
    func test_Swipe를_액션을_통해_특정_index의_데이터_제거하는지_확인() {
        let expectation = XCTestExpectation(description: "ViewModelTest")
        viewModel.execute(action: .searchItem("아이폰"))
        expectation.fulfill()
        wait(for: [expectation], timeout: 3.0)
        
        viewModel.execute(action: .deleteItem(2))
        self.data.remove(at: 2)
        
        XCTAssertEqual(viewModel.itemList.value, data)
    }
    
    func test_취소버튼_눌렸을때_모든_데이터를_제거하는지_확인() {
        let expectation = XCTestExpectation(description: "ViewModelTest")
        viewModel.execute(action: .searchItem("아이폰"))
        expectation.fulfill()
        wait(for: [expectation], timeout: 3.0)
        
        viewModel.execute(action: .cancelSearch)
        
        XCTAssertTrue(viewModel.itemList.value.isEmpty)
    }
}
```

View에서 ViewModel에 전달하는 Event는 3가지 입니다. 각각의 Event에 따라 Model을 정상적으로 업데이트 하는지 확인하는 테스트를 진행했습니다. 또한 네트워크 테스트와 마찬가지로 APIService 자체는 비동기적으로 동작하기 때문에 `XCTestExpectaion`을 이용해 진행했습니다.

정리하자면 MVVM 패턴의 ViewModel은 MVC 패턴의 Controller와 다르게 테스트가 가능합니다. View에서 이벤트를 전달할 뿐 직접적으로 연결되어 있지 않기 때문입니다.

> 테스트 코드를 작성하기 위해서는 많은 것을 고려해야 합니다. 특히 추상화와 의존성 주입을 통해 가짜 객체를 주입시킴으로써 실제 저희가 테스트하고자 하는 객체를 동작시키는 것이 중요한 것 같습니다.

---
## 참고 자료
+ MVVM
    + [MVVM in iOS Swift](https://medium.com/@abhilash.mathur1891/mvvm-in-ios-swift-aa1448a66fb4)
    + [iOS Architecture Patterns](https://medium.com/ios-os-x-development/ios-architecture-patterns-ecba4c38de52)

+ MVC
    + [MVC in iOS](https://www.kodeco.com/1000705-model-view-controller-mvc-in-ios-a-modern-approach)
    + [Cocoa MVC](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html)

+ Test
    + [TestDouble을 알아보자](https://tecoble.techcourse.co.kr/post/2020-09-19-what-is-test-double/)
    + [[Swift] Mock 을 이용한 Network Unit Test 하기](https://sujinnaljin.medium.com/swift-mock-%EC%9D%84-%EC%9D%B4%EC%9A%A9%ED%95%9C-network-unit-test-%ED%95%98%EA%B8%B0-a69570defb41)
    + [Applying Unit Tests to MVVM with Swift](https://medium.com/@koromikoneo/applying-unit-tests-to-mvvm-with-swift-ba5a79df8a18)
