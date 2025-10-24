//
//  BusAPIServiceTests.swift
//  BusdesNativeiOSTests
//
//  Created by Claude Code
//

import XCTest
@testable import BusdesNativeiOS

final class BusAPIServiceTests: XCTestCase {

    var sut: BusAPIService!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        sut = BusAPIService(session: mockSession)
    }

    override func tearDown() {
        sut = nil
        mockSession = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Given: BusAPIServiceを初期化

        // Then: 正しく初期化される
        XCTAssertNotNil(sut, "BusAPIService should be initialized")
    }

    func testInitialization_WithCustomDecoder() {
        // Given: カスタムデコーダー
        let customDecoder = JSONDecoder()
        customDecoder.keyDecodingStrategy = .useDefaultKeys

        // When: カスタムデコーダーでサービスを初期化
        let service = BusAPIService(session: URLSession.shared, decoder: customDecoder)

        // Then: 正しく初期化される
        XCTAssertNotNil(service, "Should initialize with custom decoder")
    }

    // MARK: - URL Validation Tests

    func testFetchNextBus_InvalidURL() async {
        // Given: 無効なバス停名（URLエンコードできない文字列）
        // Note: 実際には Constants.API.nextBusURL が nil を返すケース

        // When/Then: このケースは Constants のテストで検証すべき
        // ここでは正常系のテストのみ実施
    }

    // MARK: - Error Handling Tests

    func testFetchNextBus_NetworkError() async {
        // Given: ネットワークエラーを返すモックセッション
        mockSession.mockError = URLError(.notConnectedToInternet)

        // When: バス接近情報を取得しようとする
        do {
            _ = try await sut.fetchNextBus(from: "立命館大学", to: "南草津駅")
            XCTFail("Should throw network error")
        } catch let error as NetworkError {
            // Then: ネットワークエラーが投げられる
            if case .networkError(let urlError) = error {
                XCTAssertEqual((urlError as? URLError)?.code, .notConnectedToInternet)
            } else {
                XCTFail("Should be network error")
            }
        } catch {
            XCTFail("Should throw NetworkError, not \(error)")
        }
    }

    func testFetchNextBus_InvalidResponse() async {
        // Given: 無効なHTTPレスポンス（500エラー）
        mockSession.mockStatusCode = 500
        mockSession.mockData = Data()

        // When: バス接近情報を取得しようとする
        do {
            _ = try await sut.fetchNextBus(from: "立命館大学", to: "南草津駅")
            XCTFail("Should throw invalid response error")
        } catch let error as NetworkError {
            // Then: 無効なレスポンスエラーが投げられる
            if case .invalidResponse(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Should be invalid response error")
            }
        } catch {
            XCTFail("Should throw NetworkError")
        }
    }

    func testFetchNextBus_EmptyData() async {
        // Given: 空のデータ
        mockSession.mockStatusCode = 200
        mockSession.mockData = Data()

        // When: バス接近情報を取得しようとする
        do {
            _ = try await sut.fetchNextBus(from: "立命館大学", to: "南草津駅")
            XCTFail("Should throw no data error")
        } catch let error as NetworkError {
            // Then: データなしエラーが投げられる
            if case .noData = error {
                XCTAssertTrue(true, "Correctly threw no data error")
            } else {
                XCTFail("Should be no data error, got \(error)")
            }
        } catch {
            XCTFail("Should throw NetworkError")
        }
    }

    func testFetchNextBus_DecodingError() async {
        // Given: 無効なJSONデータ
        mockSession.mockStatusCode = 200
        mockSession.mockData = "Invalid JSON".data(using: .utf8)!

        // When: バス接近情報を取得しようとする
        do {
            _ = try await sut.fetchNextBus(from: "立命館大学", to: "南草津駅")
            XCTFail("Should throw decoding error")
        } catch let error as NetworkError {
            // Then: デコードエラーが投げられる
            if case .decodingError = error {
                XCTAssertTrue(true, "Correctly threw decoding error")
            } else {
                XCTFail("Should be decoding error, got \(error)")
            }
        } catch {
            XCTFail("Should throw NetworkError")
        }
    }

    // MARK: - Success Cases Tests

    func testFetchNextBus_Success() async {
        // Given: 有効なJSONレスポンス
        let validJSON = """
        {
            "bus_stop_name": "立命館大学",
            "approach_infos": [
                {
                    "bus_time": "10:00",
                    "real_arrival_time": "10:00",
                    "status": "接近"
                }
            ]
        }
        """.data(using: .utf8)!

        mockSession.mockStatusCode = 200
        mockSession.mockData = validJSON

        // When: バス接近情報を取得
        do {
            let result = try await sut.fetchNextBus(from: "立命館大学", to: "南草津駅")

            // Then: 正しくデータが取得される
            XCTAssertEqual(result.busStopName, "立命館大学")
            XCTAssertEqual(result.approachInfos.count, 1)
            XCTAssertEqual(result.approachInfos.first?.busTime, "10:00")
        } catch {
            XCTFail("Should not throw error on valid data: \(error)")
        }
    }

    func testFetchTimeTable_Success() async {
        // Given: 有効な時刻表JSONレスポンス
        let validJSON = """
        {
            "weekdays": {
                "five": [],
                "six": [],
                "seven": [],
                "eight": [],
                "nine": [],
                "ten": [],
                "eleven": [],
                "twelve": [],
                "thirteen": [],
                "fourteen": [],
                "fifteen": [],
                "sixteen": [],
                "seventeen": [],
                "eighteen": [],
                "nineteen": [],
                "twenty": [],
                "twenty_one": [],
                "twenty_two": [],
                "twenty_three": [],
                "twenty_four": []
            },
            "saturdays": {
                "five": [],
                "six": [],
                "seven": [],
                "eight": [],
                "nine": [],
                "ten": [],
                "eleven": [],
                "twelve": [],
                "thirteen": [],
                "fourteen": [],
                "fifteen": [],
                "sixteen": [],
                "seventeen": [],
                "eighteen": [],
                "nineteen": [],
                "twenty": [],
                "twenty_one": [],
                "twenty_two": [],
                "twenty_three": [],
                "twenty_four": []
            },
            "holidays": {
                "five": [],
                "six": [],
                "seven": [],
                "eight": [],
                "nine": [],
                "ten": [],
                "eleven": [],
                "twelve": [],
                "thirteen": [],
                "fourteen": [],
                "fifteen": [],
                "sixteen": [],
                "seventeen": [],
                "eighteen": [],
                "nineteen": [],
                "twenty": [],
                "twenty_one": [],
                "twenty_two": [],
                "twenty_three": [],
                "twenty_four": []
            }
        }
        """.data(using: .utf8)!

        mockSession.mockStatusCode = 200
        mockSession.mockData = validJSON

        // When: 時刻表を取得
        do {
            let result = try await sut.fetchTimeTable(from: "立命館大学", to: "南草津駅")

            // Then: 正しくデータが取得される
            XCTAssertNotNil(result.weekdays)
            XCTAssertNotNil(result.saturdays)
            XCTAssertNotNil(result.holidays)
        } catch {
            XCTFail("Should not throw error on valid data: \(error)")
        }
    }

    // MARK: - HTTP Status Code Tests

    func testFetchNextBus_VariousStatusCodes() async {
        let testCases: [(statusCode: Int, shouldSucceed: Bool)] = [
            (200, true),
            (201, true),
            (299, true),
            (300, false),
            (400, false),
            (404, false),
            (500, false),
            (503, false)
        ]

        for (statusCode, shouldSucceed) in testCases {
            // Given: 各ステータスコード
            mockSession.mockStatusCode = statusCode
            mockSession.mockData = shouldSucceed ? """
                {
                    "bus_stop_name": "Test",
                    "approach_infos": []
                }
                """.data(using: .utf8)! : Data()

            // When: APIを呼び出す
            do {
                _ = try await sut.fetchNextBus(from: "立命館大学", to: "南草津駅")

                // Then: 成功すべきケース
                XCTAssertTrue(shouldSucceed, "Status \(statusCode) should succeed")
            } catch {
                // Then: 失敗すべきケース
                XCTAssertFalse(shouldSucceed, "Status \(statusCode) should fail")
            }
        }
    }
}

// MARK: - Mock Objects

class MockURLSession: URLSession {
    var mockData: Data?
    var mockStatusCode = 200
    var mockError: Error?

    override func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        let response = HTTPURLResponse(
            url: url,
            statusCode: mockStatusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        return (mockData ?? Data(), response)
    }
}
