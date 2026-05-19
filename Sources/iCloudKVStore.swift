#if canImport(AppKit) || canImport(UIKit) || canImport(WatchKit)
import Dependencies
import Foundation

/// A type that abstracts the storage operations used by ``iCloudKVKey``.
///
/// `NSUbiquitousKeyValueStore` conforms to this protocol, and an
/// ``InMemoryiCloudKVStore`` is provided for tests and previews where the
/// `ubiquity-kvstore-identifier` entitlement is unavailable.
///
/// Override ``DependencyValues/defaultiCloudKVStore`` to control which store
/// is used by `@Shared(.iCloudKV(...))`.
public protocol iCloudKVStore: AnyObject {
  func object(forKey key: String) -> Any?
  func string(forKey key: String) -> String?
  func set(_ value: Any?, forKey key: String)
  func removeObject(forKey key: String)
  @discardableResult
  func synchronize() -> Bool
}

extension NSUbiquitousKeyValueStore: iCloudKVStore {}

/// An in-memory ``iCloudKVStore`` suitable for tests and previews.
///
/// Reads and writes go to an in-process dictionary; `synchronize()` is a
/// no-op that always succeeds.
public final class InMemoryiCloudKVStore: iCloudKVStore, @unchecked Sendable {
  private let lock = NSLock()
  private var values: [String: Any] = [:]

  public init() {}

  public func object(forKey key: String) -> Any? {
    lock.lock()
    defer { lock.unlock() }
    return values[key]
  }

  public func string(forKey key: String) -> String? {
    object(forKey: key) as? String
  }

  public func set(_ value: Any?, forKey key: String) {
    lock.lock()
    defer { lock.unlock() }
    if let value {
      values[key] = value
    } else {
      values.removeValue(forKey: key)
    }
  }

  public func removeObject(forKey key: String) {
    set(nil, forKey: key)
  }

  @discardableResult
  public func synchronize() -> Bool { true }
}

extension DependencyValues {
  /// The default iCloud key-value store used by ``SharedReaderKey/iCloudKV(_:)``.
  ///
  /// In live contexts this is `NSUbiquitousKeyValueStore.default`. In tests and previews this
  /// is an ``InMemoryiCloudKVStore`` so that features remain hermetic and the
  /// `ubiquity-kvstore-identifier` entitlement is not required.
  ///
  /// Override at app entry to opt into an in-memory store during UI testing, for example:
  ///
  /// ```swift
  /// @main
  /// struct MyApp: App {
  ///   init() {
  ///     if ProcessInfo.processInfo.environment["UITesting"] == "true" {
  ///       prepareDependencies {
  ///         $0.defaultiCloudKVStore = InMemoryiCloudKVStore()
  ///       }
  ///     }
  ///   }
  ///   // ...
  /// }
  /// ```
  public var defaultiCloudKVStore: any iCloudKVStore {
    get { self[DefaultiCloudKVStoreKey.self].wrappedValue }
    set { self[DefaultiCloudKVStoreKey.self] = UncheckedSendable(newValue) }
  }
}

private enum DefaultiCloudKVStoreKey: DependencyKey {
  static var liveValue: UncheckedSendable<any iCloudKVStore> {
    UncheckedSendable(NSUbiquitousKeyValueStore.default)
  }
  static var previewValue: UncheckedSendable<any iCloudKVStore> {
    UncheckedSendable(InMemoryiCloudKVStore())
  }
  static var testValue: UncheckedSendable<any iCloudKVStore> {
    UncheckedSendable(InMemoryiCloudKVStore())
  }
}
#endif
