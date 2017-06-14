import XCTest
@testable import FluentProviderTests

XCTMain([
     testCase(CacheTests.allTests),
     testCase(PagingTests.allTests)
])
