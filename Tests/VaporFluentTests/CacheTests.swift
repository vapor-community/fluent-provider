import XCTest
@testable import VaporFluent

class CacheTests: XCTestCase {
    func testHappyPath() throws {
        // config specifying memory database
        var config = Config([:])
        try config.set("fluent.driver", "memory")
        try config.set("droplet.cache", "fluent")

        // create droplet with Fluent provider
        let drop = try Droplet(environment: .custom("debug"), config: config)
        
        // add the entity for storing fluent caches
        drop.preparations += FluentCache.CacheEntity.self

        // manually add provider
        let provider = VaporFluent.Provider()
        try provider.beforeRun(drop)

        XCTAssert(drop.cache is FluentCache)

        try drop.cache.set("foo", "bar")
        XCTAssertEqual(
            try drop.cache.get("foo")?.string,
            "bar"
        )
    }


    static var allTests = [
        ("testHappyPath", testHappyPath),
    ]
}
