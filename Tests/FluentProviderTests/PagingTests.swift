import XCTest
@testable import FluentProvider
import SQLite

class PagingTests: XCTestCase {
    
    static var allTests = [
        ("testTwoPages", testTwoPages),
        ("testOnePage", testOnePage),
        ("test10Items", test10Items),
        ("test20Items", test20Items),
        ("testZero", testZero)
    ]
    
    final class DummyModel: Entity, Preparation, Paginatable, Timestampable, JSONRepresentable {
        
        let storage = Storage()
        
        static let defaultPageSize = 10
        
        init() {}
        
        init(row: Row) throws {}
        
        func makeRow() throws -> Row {
            var row = Row()
            try row.set("name", "dummy")
            return row
        }

        static func prepare(_ database: Database) throws {
            try database.create(self) { builder in
                builder.id()
                builder.string("name")
            }
        }
        
        static func revert(_ database: Database) throws {}
        
        func makeJSON() throws -> JSON {
            return JSON()
        }
    }
    
    func testOnePage() throws {
        
        let memory = try SQLiteDriver(path: ":memory:")
        let database = Database(memory)
        
        try DummyModel.prepare(database)
        DummyModel.database = database
        
        try (0...5).forEach { _ in
            try DummyModel().save()
        }
        
        let first = try DummyModel.makeQuery().paginate(page: 1).makeJSON()
        
        XCTAssertEqual(first["page.position.max"]?.int, 1)
        XCTAssertEqual(first["page.position.next"]?.int, nil)
        XCTAssertEqual(first["page.position.previous"]?.int, nil)
    }
    
    func testTwoPages() throws {
        
        let memory = try SQLiteDriver(path: ":memory:")
        let database = Database(memory)
        
        try DummyModel.prepare(database)
        DummyModel.database = database
        
        try (0...15).forEach { _ in
            try DummyModel().save()
        }
        
        let first = try DummyModel.makeQuery().paginate(page: 1).makeJSON()
        
        XCTAssertEqual(first["page.position.max"]?.int, 2)
        XCTAssertEqual(first["page.position.next"]?.int, 2)
        XCTAssertEqual(first["page.position.previous"]?.int, nil)
        
        let second = try DummyModel.makeQuery().paginate(page: 2).makeJSON()
        
        XCTAssertEqual(second["page.position.max"]?.int, 2)
        XCTAssertEqual(second["page.position.next"]?.int, nil)
        XCTAssertEqual(second["page.position.previous"]?.int, 1)
    }
    
    func test10Items() throws {
        
        let memory = try SQLiteDriver(path: ":memory:")
        let database = Database(memory)
        
        try DummyModel.prepare(database)
        DummyModel.database = database
        
        try (0..<10).forEach { _ in
            try DummyModel().save()
        }
        
        let first = try DummyModel.makeQuery().paginate(page: 1).makeJSON()
        
        XCTAssertEqual(first["page.position.max"]?.int, 1)
        XCTAssertEqual(first["page.position.next"]?.int, nil)
        XCTAssertEqual(first["page.position.previous"]?.int, nil)
    }
    
    func test20Items() throws {
        
        let memory = try SQLiteDriver(path: ":memory:")
        let database = Database(memory)
        
        try DummyModel.prepare(database)
        DummyModel.database = database
        
        try (0..<20).forEach { _ in
            try DummyModel().save()
        }
        
        let first = try DummyModel.makeQuery().paginate(page: 1).makeJSON()
        
        XCTAssertEqual(first["page.position.max"]?.int, 2)
        XCTAssertEqual(first["page.position.next"]?.int, 2)
        XCTAssertEqual(first["page.position.previous"]?.int, nil)
        
        let second = try DummyModel.makeQuery().paginate(page: 2).makeJSON()
        
        XCTAssertEqual(second["page.position.max"]?.int, 2)
        XCTAssertEqual(second["page.position.next"]?.int, nil)
        XCTAssertEqual(second["page.position.previous"]?.int, 1)
    }
    
    func testZero() throws {
        
        let memory = try SQLiteDriver(path: ":memory:")
        let database = Database(memory)
        
        try DummyModel.prepare(database)
        DummyModel.database = database
        
        let first = try DummyModel.makeQuery().paginate(page: 1).makeJSON()
        
        XCTAssertEqual(first["page.position.max"]?.int, 0)
        XCTAssertEqual(first["page.position.next"]?.int, nil)
        XCTAssertEqual(first["page.position.previous"]?.int, nil)
    }
}
