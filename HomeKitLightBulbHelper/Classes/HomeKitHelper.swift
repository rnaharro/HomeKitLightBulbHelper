import HomeKit

public class HomeKitHelper: NSObject {
    enum E : Error {
        case config(message: String)
    }

    private static var sharedInstance: HomeKitHelper!

    private init(didUpdateHomes: (() -> Void)?) {
        didUpdateHomesCompletion = didUpdateHomes
        manager = HMHomeManager()

        super.init()
        manager.delegate = self
        HomeKitHelper.sharedInstance = self
    }

    public static func shared(didUpdateHomes: (() -> Void)?) throws -> HomeKitHelper {
        switch (sharedInstance, didUpdateHomes) {
        case let (i?, nil):
            return i
        case _ where sharedInstance != nil && didUpdateHomes != nil:
            throw E.config(message: "You cannot change didUpdateHomes after initialization!")
        case let (nil, c?):
            sharedInstance = HomeKitHelper(didUpdateHomes: didUpdateHomes)
            return sharedInstance
        default:
            sharedInstance = HomeKitHelper(didUpdateHomes: nil)
            return sharedInstance
        }
    }

    private(set) var didUpdateHomesCompletion: (() -> Void)?
    private var manager: HMHomeManager
    private var primaryHome: HMHome? {
        manager.primaryHome
    }

    private var rooms : [HMRoom]? {
        guard let homeRooms = primaryHome?.rooms else {
            return nil
        }
        var roomsWithLights: [HMRoom] = []
        for room in homeRooms {
            if numberOfBulbs(for: room) > 0 {
                roomsWithLights.append(room)
            }
        }

        return roomsWithLights.count > 0 ? roomsWithLights : nil
    }

    public var hasPrimaryHome: Bool {
        primaryHome != nil
    }

    public var savedlights: [HMService]? {
        get {
            var selectedLights: [HMService]?
            if let ids = UserDefaults.standard.object(forKey: "homekitLighs") as? [String],
               let services = manager.primaryHome?.servicesWithTypes([HMServiceTypeLightbulb]) {
                let allLightsIds = services.compactMap { $0.uniqueIdentifier.uuidString }
                let selectedIds = allLightsIds.filter(ids.contains)
                selectedLights = services.filter({ selectedIds.contains($0.uniqueIdentifier.uuidString) })
            }
            return selectedLights
        }

        set {
            let ids = newValue?.compactMap({ $0.uniqueIdentifier.uuidString })
            UserDefaults.standard.setValue(ids, forKey: "homekitLighs")
        }
    }

    public var allLightbulbServices: [HMService]? {
        primaryHome?.servicesWithTypes([HMServiceTypeLightbulb])
    }

    public func numberOfRooms() -> Int {
        rooms?.count ?? 0
    }

    public func nameForRoom(at index: Int) -> String? {
        if let room = rooms?[index] {
            return room.name
        }

        return nil
    }

    public func room(at index: Int) -> HMRoom? {
        if let room = rooms?[index] {
            return room
        }

        return nil
    }

    public func numberOfBulbs(for room: HMRoom) -> Int {
        if let bulbs = lightBulbs(room: room) {
            return bulbs.count
        }

        return 0
    }

    public func lightBulbs(room: HMRoom) -> [HMService]? {
        let accessories: [HMAccessory] = room.accessories
        var hulbServices: [HMService] = []
        for accessory in accessories where accessory.isReachable {
            for service in accessory.services where service.serviceType == HMServiceTypeLightbulb && service.characteristics.contains(where: { $0.characteristicType == HMCharacteristicTypeHue || $0.characteristicType == HMCharacteristicTypeSaturation }) {
                hulbServices.append(service)
            }
        }
        return hulbServices.unique{$0.name}
    }
}

extension HomeKitHelper: HMHomeManagerDelegate {
    public func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        didUpdateHomesCompletion?()
    }
}

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}
