//   Copyright 2017 Enervolution GmbH
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
import XCTest
import Titan
import Foundation

let nullResponse = Response(-1, Data(), HTTPHeaders())

final class TitanAPITests: XCTestCase {

    static var allTests = [
        ("testFunctionalMutableParams", testFunctionalMutableParams),
        ("testTitanGet", testTitanGet),
        ("testTitanEcho", testTitanEcho),
        ("testMultipleRoutes", testMultipleRoutes),
        ("testTitanSugar", testTitanSugar),
        ("testFunctionFunction", testFunctionFunction),
        ("testDifferentMethods", testDifferentMethods),
        ("testErrorsAreCaught", testErrorsAreCaught),
        ("testSamePathDifferentiationByMethod", testSamePathDifferentiationByMethod),
        ("testCanAccessJSONBody", testCanAccessJSONBody),
        ("testCanAccessFormURLEncodedBody", testCanAccessFormURLEncodedBody),
        ("testCanAccessQueryString", testCanAccessQueryString),
        ("testTypesafePathParams", testTypesafePathParams),
        ("test404", test404),
        ("testPredicates", testPredicates),
        ("testAuthentication", testAuthentication)
    ]

    var titanInstance: Titan!
    override func setUp() {
        titanInstance = Titan()
    }

    func testFunctionalMutableParams() {
        let app = Titan()
        app.get("/init") { (req, res) -> (RequestType, ResponseType) in
            var newReq = req.copy()
            var newRes = res.copy()
            newRes.body = "Hello World".data(using: .utf8)!
            newReq.path = "/rewritten"
            newRes.code = 500
            return (newReq, newRes)
        }
        app.addFunction { (req, res) -> (RequestType, ResponseType) in
            XCTAssertEqual(req.path, "/rewritten")
            return (req, res)
        }
        let response = app.app(request: Request(.get, "/init"), response: nullResponse).1
        XCTAssertEqual(response.code, 500)
        XCTAssertEqual(response.body, "Hello World")
    }

    func testTitanGet() {
        titanInstance.get("/username") { req, _ in
            do {
                return (req, try Response(200, "swizzlr", HTTPHeaders()))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }
        XCTAssertEqual(titanInstance.app(request: Request(.get, "/username"), response: nullResponse).1.body, "swizzlr")
    }

    func testTitanEcho() {
        titanInstance.get("/echoMyBody") { req, _ in
            return (req, Response(200, req.body, HTTPHeaders()))
        }
        XCTAssertEqual(titanInstance.app(request: Request(.get, "/echoMyBody", "hello, this is my body"), response: nullResponse).response.body,
                       "hello, this is my body")
    }

    func testMultipleRoutes() {
        titanInstance.get("/username") { req, _ in
            do {
                return (req, try Response(200, "swizzlr", HTTPHeaders()))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }

        titanInstance.get("/echoMyBody") { req, _ in
            return (req, Response(200, req.body))
        }
        XCTAssertEqual(titanInstance.app(request: Request(.get, "/echoMyBody", "hello, this is my body"), response: nullResponse).response.body,
                       "hello, this is my body")
        XCTAssertEqual(titanInstance.app(request: Request(.get, "/username"), response: nullResponse).1.body, "swizzlr")
    }

    func testTitanSugar() {
        let somePremadeFunction: TitanFunc = { req, res in
            return (req, res)
        }
        titanInstance.get(path: "/username", handler: somePremadeFunction)
        titanInstance.get("/username", somePremadeFunction)
    }

    func testFunctionFunction() {
        var start = Date()
        var end = start
        titanInstance.addFunction("*") { (req: RequestType, res: ResponseType) -> (RequestType, ResponseType) in
            start = Date()
            return (req, res)
        }
        titanInstance.get("/username") { req, _ in
            do {
                return (req, try Response(200, "swizzlr"))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }
        titanInstance.addFunction("*") { (req: RequestType, res: ResponseType) -> (RequestType, ResponseType) in
            end = Date()
            return (req, res)
        }
        _ = titanInstance.app(request: Request(.get, "/username"), response: nullResponse).response
        XCTAssertLessThan(start, end)
    }

    func testDifferentMethods() {
        titanInstance.get("/getSomething") { req, _ in
            do {
                return (req, try Response(200, "swizzlrGotSomething!"))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }

        titanInstance.post("/postSomething") { req, _ in
            do {
                return (req, try Response(200, "something posted"))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }

        titanInstance.put("/putSomething") { req, _ in
            do {
                return (req, try Response(200, "i can confirm that stupid stuff is now on the server"))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }

        titanInstance.patch("/patchSomething") { req, _ in
            do {
                return (req, try Response(200, "i guess we don't have a flat tire anymore?"))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }

        titanInstance.delete("/deleteSomething") { req, _ in
            do {
                return (req, try Response(200, "error: could not find the USA or its principles"))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }

        titanInstance.options("/optionSomething") { req, _ in
            do {
                return (req, try Response(200, "I sold movie rights!"))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }

        titanInstance.head("/headSomething") { req, _ in
            do {
                return (req, try Response(200, "OWN GOAL!!"))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }
    }

    func testErrorsAreCaught() {
        let t = Titan()
        let errorHandler: (Error) -> ResponseType = { (err: Error) in
            let desc = String(describing: err)
            do {
                return try Response(500, desc)
            } catch {
                return Response(code: 500, body: Data(), headers: HTTPHeaders())
            }
        }
        t.addFunction(errorHandler: errorHandler) { (_, _) throws -> (RequestType, ResponseType) in
            throw "Oh no"
        }
        XCTAssertEqual(t.app(request: Request(.custom(named: ""), ""), response: nullResponse).1.body, "Oh no")
    }

    func testSamePathDifferentiationByMethod() {
        var username = ""

        titanInstance.get("/username") { req, _ in
            do {
                return (req, try Response(200, username))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }

        titanInstance.post("/username") { (req: RequestType, _) in
            let s: String = req.body!
            username = s
            do {
                return (req, try Response(201, ""))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }

        let resp = titanInstance.app(request: Request(.post, "/username", "Lisa"), response: nullResponse).1
        XCTAssertEqual(resp.code, 201)
        XCTAssertEqual(titanInstance.app(request: Request(.get, "/username"), response: nullResponse).response.body, "Lisa")
    }

    func testCanAccessJSONBody() {
        let jsonBody = "{\"data\": [1, 2, 3]}"
        let req: RequestType = Request(.post, "/ingest", jsonBody)
        // Dictionary<String, [Int]>
        // [String, [Int]]
        guard let json = req.json as? Dictionary<String, Array<Int>> else {
            XCTFail("Received: \(String(describing: req.json))")
            return
        }
        XCTAssertEqual(json["data"]!, [1, 2, 3])
    }

    func testCanAccessFormURLEncodedBody() {
        let requestBody = "foo=bar&baz=&favorite+flavor=flies&resume=when+i+was+young%0D%0Ai+went+to+school&foo=bar2"
        let request = Request(.post, "/submit", requestBody)
        let parsed = request.formURLEncodedBody
        // Simple
        XCTAssertEqual(parsed[0].name, "foo")
        XCTAssertEqual(parsed[0].value, "bar")
        // Missing value
        XCTAssertEqual(parsed[1].name, "baz")
        XCTAssertEqual(parsed[1].value, "")
        // Spaces
        XCTAssertEqual(parsed[2].name, "favorite flavor")
        XCTAssertEqual(parsed[2].value, "flies")
        // Percent encoded new lines
        XCTAssertEqual(parsed[3].name, "resume")
        XCTAssertEqual(parsed[3].value, "when i was young\r\ni went to school")
        // Simple
        XCTAssertEqual(parsed[4].name, "foo")
        XCTAssertEqual(parsed[4].value, "bar2")

        let dict = request.postParams
        XCTAssertEqual(dict["resume"], "when i was young\r\ni went to school")
        XCTAssertEqual(dict["foo"], "bar2") // check repeats, last value wins
    }

    func testCanAccessQueryString() {
        let path = "/users?verified=true&q=thomas%20catterall"
        let request: RequestType = Request(.get, path)
        let parsedQuery = request.queryPairs
        guard parsedQuery.count == 2 else {
            XCTFail("query params expected 2")
            return
        }
        XCTAssertEqual(parsedQuery[0].key, "verified")
        XCTAssertEqual(parsedQuery[0].value, "true")

        XCTAssertEqual(parsedQuery[1].key, "q")
        XCTAssertEqual(parsedQuery[1].value, "thomas catterall")
    }

    func testTypesafePathParams() {
        titanInstance.get("/foo/{id}/baz") { req, _, params in
            let id = params["id"] ?? ""
            do {
                return (req, try Response(200, id))
            } catch {
                return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
            }
        }
        let resp = titanInstance.app(request: Request(.get, "/foo/567/baz"), response: nullResponse).1
        XCTAssertEqual(resp.body, "567")
    }

    func test404() {
        titanInstance.addFunction(defaultTo404)
    }

    func testPredicates() {
        titanInstance.addFunction(defaultTo404)
        titanInstance.predicate({ (req, _) -> Bool in
            return req.headers.contains(where: { (header) -> Bool in
                return header.name == "Authentication" && header.value == "password"
            })
        }, true: { authenticated in
            authenticated.get("/password") { req, _ in
                do {
                    return (req, try Response(200, "Super secret password!", HTTPHeaders()))
                } catch {
                    return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
                }
            }
        }, false: { unauthenticated in
            unauthenticated.addFunction { req, _ in
                do {
                    return (req, try Response(499, "WHAT WHAT", HTTPHeaders()))
                } catch {
                    return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
                }
            }
        })
        let unauthenticatedResponse = titanInstance.app(request: Request(.get, "/password", "", HTTPHeaders()), response: nullResponse).1
        XCTAssertEqual(unauthenticatedResponse.code, 499)
        XCTAssertEqual(unauthenticatedResponse.body, "WHAT WHAT")
        let authenticatedResponse = titanInstance.app(request: Request(.get, "/password", "",
                                                                       HTTPHeaders(dictionaryLiteral: ("Authentication", "password"))),
                                                      response: nullResponse).1

        XCTAssertEqual(authenticatedResponse.code, 200)
        XCTAssertEqual(authenticatedResponse.body, "Super secret password!")
        let authenticated404 = titanInstance.app(request: Request(.head, "/password", "",
                                                                  HTTPHeaders(dictionaryLiteral: ("Authentication", "password"))),
                                                 response: nullResponse).1

        XCTAssertEqual(authenticated404.code, 404)
    }

    func testAuthentication() {
        func myAuthorizationRoutine(_ request: RequestType) -> Bool {
            return request.headers.contains(where: { (header) -> Bool in
                return header.name == "Authentication" && header.value == "other password"
            })
        }
        titanInstance.authenticated(myAuthorizationRoutine) { (authenticated) in
            authenticated.get("/password") { req, _ in
                do {
                    return (req, try Response(200, "Super secret password!", HTTPHeaders()))
                } catch {
                    return (req, Response(code: 500, body: Data(), headers: HTTPHeaders()))
                }
            }
        }
        let unauthenticatedResponse = titanInstance.app(request: Request(.get, "/password", "", HTTPHeaders()), response: nullResponse).1
        XCTAssertEqual(unauthenticatedResponse.code, 401)

        let authenticatedResponse = titanInstance.app(request: Request(.get, "/password", "",
                                                                       HTTPHeaders(dictionaryLiteral: ("Authentication", "other password"))),
                                                      response: nullResponse).1
        XCTAssertEqual(authenticatedResponse.code, 200)
        XCTAssertEqual(authenticatedResponse.body, "Super secret password!")
    }
}

extension String: Error {}
