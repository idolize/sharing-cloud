#if canImport(AppKit) || canImport(UIKit) || canImport(WatchKit)
import Foundation
import SharingCloud
import Testing

@Suite struct InMemoryiCloudKVStoreTests {
  @Test func setAndGetObject() {
    let store = InMemoryiCloudKVStore()
    store.set("hello", forKey: "k")
    #expect(store.object(forKey: "k") as? String == "hello")
  }

  @Test func setNilRemovesKey() {
    let store = InMemoryiCloudKVStore()
    store.set("hello", forKey: "k")
    store.set(nil, forKey: "k")
    #expect(store.object(forKey: "k") == nil)
  }

  @Test func removeObject() {
    let store = InMemoryiCloudKVStore()
    store.set(42, forKey: "k")
    store.removeObject(forKey: "k")
    #expect(store.object(forKey: "k") == nil)
  }

  @Test func stringAccessorReturnsString() {
    let store = InMemoryiCloudKVStore()
    store.set("hi", forKey: "k")
    #expect(store.string(forKey: "k") == "hi")
  }

  @Test func stringAccessorReturnsNilForNonString() {
    let store = InMemoryiCloudKVStore()
    store.set(42, forKey: "k")
    #expect(store.string(forKey: "k") == nil)
  }

  @Test func synchronizeAlwaysSucceeds() {
    #expect(InMemoryiCloudKVStore().synchronize())
  }

  @Test func independentInstancesDoNotShareState() {
    let a = InMemoryiCloudKVStore()
    let b = InMemoryiCloudKVStore()
    a.set("only-in-a", forKey: "k")
    #expect(a.object(forKey: "k") as? String == "only-in-a")
    #expect(b.object(forKey: "k") == nil)
  }
}
#endif
