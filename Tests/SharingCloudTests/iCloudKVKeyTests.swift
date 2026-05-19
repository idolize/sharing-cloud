#if canImport(AppKit) || canImport(UIKit) || canImport(WatchKit)
import Dependencies
import Foundation
import Sharing
import SharingCloud
import Testing

@Suite struct iCloudKVKeyTests {
  @Dependency(\.defaultiCloudKVStore) var store

  @Test func defaultIsUsedAsInMemoryStoreInTests() {
    #expect(store is InMemoryiCloudKVStore)
  }

  @Test func bool() {
    @Shared(.iCloudKV("bool")) var bool = true
    #expect(store.object(forKey: "bool") as? Bool == true)
    $bool.withLock { $0 = false }
    #expect(store.object(forKey: "bool") as? Bool == false)
    #expect(bool == false)
  }

  @Test func int() {
    @Shared(.iCloudKV("int")) var int = 42
    #expect(store.object(forKey: "int") as? Int == 42)
    $int.withLock { $0 = 1729 }
    #expect(store.object(forKey: "int") as? Int == 1729)
    #expect(int == 1729)
  }

  @Test func double() {
    @Shared(.iCloudKV("double")) var double = 1.2
    #expect(store.object(forKey: "double") as? Double == 1.2)
    $double.withLock { $0 = 3.4 }
    #expect(store.object(forKey: "double") as? Double == 3.4)
    #expect(double == 3.4)
  }

  @Test func string() {
    @Shared(.iCloudKV("string")) var string = "Blob"
    #expect(store.string(forKey: "string") == "Blob")
    $string.withLock { $0 = "Blob, Jr." }
    #expect(store.string(forKey: "string") == "Blob, Jr.")
    #expect(string == "Blob, Jr.")
  }

  @Test func url() {
    let initial = URL(fileURLWithPath: "/dev")
    let updated = URL(fileURLWithPath: "/tmp")
    @Shared(.iCloudKV("url")) var url = initial
    #expect(store.string(forKey: "url") == initial.absoluteString)
    $url.withLock { $0 = updated }
    #expect(store.string(forKey: "url") == updated.absoluteString)
    #expect(url == updated)
  }

  @Test func data() {
    @Shared(.iCloudKV("data")) var data = Data([4, 2])
    #expect(store.object(forKey: "data") as? Data == Data([4, 2]))
    $data.withLock { $0 = Data([1, 7, 2, 9]) }
    #expect(store.object(forKey: "data") as? Data == Data([1, 7, 2, 9]))
    #expect(data == Data([1, 7, 2, 9]))
  }

  @Test func date() {
    let initial = Date(timeIntervalSinceReferenceDate: 0)
    let updated = Date(timeIntervalSince1970: 0)
    @Shared(.iCloudKV("date")) var date = initial
    #expect(store.object(forKey: "date") as? Date == initial)
    $date.withLock { $0 = updated }
    #expect(store.object(forKey: "date") as? Date == updated)
    #expect(date == updated)
  }

  @Test func rawRepresentableInt() {
    struct ID: RawRepresentable, Equatable {
      var rawValue: Int
    }
    @Shared(.iCloudKV("raw-int")) var id = ID(rawValue: 42)
    #expect(store.object(forKey: "raw-int") as? Int == 42)
    $id.withLock { $0 = ID(rawValue: 1729) }
    #expect(store.object(forKey: "raw-int") as? Int == 1729)
    #expect(id == ID(rawValue: 1729))
  }

  @Test func rawRepresentableString() {
    struct Name: RawRepresentable, Equatable {
      var rawValue: String
    }
    @Shared(.iCloudKV("raw-string")) var name = Name(rawValue: "Blob")
    #expect(store.string(forKey: "raw-string") == "Blob")
    $name.withLock { $0 = Name(rawValue: "Blob, Jr.") }
    #expect(store.string(forKey: "raw-string") == "Blob, Jr.")
    #expect(name == Name(rawValue: "Blob, Jr."))
  }

  @Test func optionalStartsNil() {
    @Shared(.iCloudKV("opt-bool")) var bool: Bool?
    #expect(bool == nil)
    #expect(store.object(forKey: "opt-bool") == nil)
  }

  @Test func optionalRoundTripsAndClears() {
    @Shared(.iCloudKV("opt-int")) var int: Int? = 1
    #expect(store.object(forKey: "opt-int") as? Int == 1)
    $int.withLock { $0 = 2 }
    #expect(store.object(forKey: "opt-int") as? Int == 2)
    $int.withLock { $0 = nil }
    #expect(store.object(forKey: "opt-int") == nil)
    #expect(int == nil)
  }

  @Test func optionalURL() {
    let initial = URL(fileURLWithPath: "/dev")
    @Shared(.iCloudKV("opt-url")) var url: URL? = initial
    #expect(store.string(forKey: "opt-url") == initial.absoluteString)
    $url.withLock { $0 = nil }
    #expect(store.object(forKey: "opt-url") == nil)
    #expect(url == nil)
  }

  @Test func explicitStoreOverride() {
    let custom = InMemoryiCloudKVStore()
    @Shared(.iCloudKV("override", store: custom)) var value = "explicit"
    #expect(custom.string(forKey: "override") == "explicit")
    #expect(store.object(forKey: "override") == nil)
  }

  @Test func dependencyOverride() {
    let custom = InMemoryiCloudKVStore()
    withDependencies {
      $0.defaultiCloudKVStore = custom
    } operation: {
      @Shared(.iCloudKV("dep-override")) var value = 99
      #expect(custom.object(forKey: "dep-override") as? Int == 99)
    }
    #expect(store.object(forKey: "dep-override") == nil)
  }

  @Test func separateTestsGetIsolatedStores() {
    // Side-effect: write a value that we'll assert is NOT visible in other tests.
    @Shared(.iCloudKV("isolation")) var int = 7
    #expect(store.object(forKey: "isolation") as? Int == 7)
  }

  @Test func separateTestsGetIsolatedStoresControl() {
    // If dependency scoping is working, the side-effect from the test above is not visible here.
    #expect(store.object(forKey: "isolation") == nil)
  }

  @Test func description() {
    let key = iCloudKVKey<Int>.iCloudKV("greeting")
    #expect(String(describing: key) == #".iCloudKV("greeting")"#)
  }

  @Test func idDiffersByKey() {
    let a = iCloudKVKey<Int>.iCloudKV("a")
    let b = iCloudKVKey<Int>.iCloudKV("b")
    #expect(a.id != b.id)
  }

  @Test func idDiffersByStore() {
    let a = iCloudKVKey<Int>.iCloudKV("k", store: InMemoryiCloudKVStore())
    let b = iCloudKVKey<Int>.iCloudKV("k", store: InMemoryiCloudKVStore())
    #expect(a.id != b.id)
  }

  @Test func idEqualForSameKeyAndStore() {
    let custom = InMemoryiCloudKVStore()
    let a = iCloudKVKey<Int>.iCloudKV("k", store: custom)
    let b = iCloudKVKey<Int>.iCloudKV("k", store: custom)
    #expect(a.id == b.id)
  }
}
#endif
