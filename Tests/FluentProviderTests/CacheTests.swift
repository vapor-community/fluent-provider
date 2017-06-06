import XCTest
@testable import FluentProvider
import SQLite

class CacheTests: XCTestCase {
    func testHappyPath() throws {
        // config specifying memory database
        var config = try Config(arguments: ["vapor", "serve", "--port=8832", "--env=debug"])
        try config.set("fluent.driver", "memory")
        try config.set("droplet.cache", "fluent")
        try config.addProvider(FluentProvider.Provider.self)
        
        // add the entity for storing fluent caches
        config.preparations.append(FluentCache.CacheEntity.self)

        // create droplet with Fluent provider
        let drop = try Droplet(config)
        
        // run the droplet
        background {
            try! drop.run()
        }
        drop.console.wait(seconds: 1)

        // test cache
        XCTAssert(drop.cache is FluentCache)

        try drop.cache.set("foo", "bar")
        XCTAssertEqual(
            try drop.cache.get("foo")?.string,
            "bar"
        )
        
        // test expiration
        let future = Date(timeIntervalSinceNow: 1)
        try drop.cache.set("hello", "world", expiration: future)
        XCTAssertEqual(
            try drop.cache.get("hello")?.string,
            "world"
        )
        drop.console.wait(seconds: 2)
        XCTAssertNil(try drop.cache.get("hello"))

        do {
            try drop.cache.set("foo", try Node(node: ["hello": "world"]))
            XCTFail("Operation should have failed.")
        } catch SQLiteDriverError.unsupported(let message) {
            // setting objects is unsupported
            print(message)
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }


    func testSkipPreparations() throws {
        // config specifying memory database
        var config = try Config(arguments: ["vapor", "serve", "--port=8833", "--env=debug"])
        try config.set("fluent.driver", "memory")
        try config.set("droplet.cache", "fluent")
        try config.set("fluent.migrationEntityName", Node.null)
        try config.addProvider(FluentProvider.Provider.self)

        // add the entity for storing fluent caches
        config.preparations.append(FluentCache.CacheEntity.self)

        // create droplet with Fluent provider
        let drop = try Droplet(config)

        // run the droplet
        background {
            try! drop.run()
        }
        drop.console.wait(seconds: 1)

        // test cache
        XCTAssert(drop.cache is FluentCache)

        do {
            try drop.cache.set("foo", "bar")
            XCTFail("Should not have set properly")
        } catch SQLite.SQLiteError.prepare {
            // pass
            // a sqlite prepare error should be thrown
            // since preparations were skipped
        }
    }


    static var allTests = [
        ("testHappyPath", testHappyPath),
        ("testSkipPreparations", testSkipPreparations),
    ]
}
