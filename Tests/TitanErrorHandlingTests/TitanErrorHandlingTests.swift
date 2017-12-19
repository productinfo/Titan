import XCTest
import TitanErrorHandling
import TitanCore
let nullResponse = Response(code: -1, body: Data(), headers: HTTPHeaders())

class TitanErrorHandlingTests: XCTestCase {

    static var allTests = [
        ("testErrorsAreCaught", testErrorsAreCaught)
        ]

    func testErrorsAreCaught() {
        let t = Titan()
        let errorHandler: (Error) -> ResponseType = { (err: Error) in
            let desc = String(describing: err)
            let descData = desc.data(using: .utf8)!
            return Response(code: 500, body: descData, headers: HTTPHeaders())
        }
        t.addFunction(errorHandler: errorHandler) { (_, _) throws -> (RequestType, ResponseType) in
            throw "Oh no"
        }
        XCTAssertEqual(t.app(request: Request(method: "", path: "", body: Data(), headers: HTTPHeaders()), response: nullResponse).1.body, "Oh no")
    }
}

extension String: Error {

}
