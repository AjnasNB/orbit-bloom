import XCTest
@testable import OrbitBloom

@MainActor final class WorldEventClockTests: XCTestCase {
    private let serverSeconds = 2_100_000_000.25
    private func payload(schema: Int = 1, schedule: Int = 1, serverNow: Double? = nil) -> Data {
        Data("{\"schema\":\(schema),\"schedule\":\(schedule),\"serverNow\":\(serverNow ?? serverSeconds)}".utf8)
    }
    private func response(url: URL? = nil, code: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(url: url ?? WorldEventClock.endpoint, statusCode: code, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])!
    }
    private func assertOffline(_ clock: WorldEventClock, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNil(clock.now, file: file, line: line)
        XCTAssertTrue(clock.status.hasPrefix("Offline"), file: file, line: line)
    }

    func testServerUTCAnchorAdvancesOnlyWithMonotonicUptimeAndRequestContainsNoPlayerData() async throws {
        var uptime: TimeInterval = 1_000
        var captured: URLRequest?
        let data = payload(), http = response()
        let clock = WorldEventClock(transport: { request in captured = request; return (data, http) }, uptime: { uptime })
        XCTAssertNil(clock.now)
        await clock.refresh()
        let request = try XCTUnwrap(captured)
        XCTAssertEqual(request.url, WorldEventClock.endpoint); XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.cachePolicy, .reloadIgnoringLocalCacheData); XCTAssertEqual(request.timeoutInterval, 12)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization")); XCTAssertNil(request.httpBody)
        XCTAssertEqual(try XCTUnwrap(clock.anchor).timeIntervalSince1970, serverSeconds, accuracy: 0.000_001)
        XCTAssertTrue(clock.status.hasPrefix("Worldwide"))
        // The arbitrary server date is used directly; no device-wall-clock comparison contributes to it.
        uptime += 75.5
        XCTAssertEqual(try XCTUnwrap(clock.now).timeIntervalSince1970, serverSeconds + 75.5, accuracy: 0.000_001)
        uptime += 23.25
        XCTAssertEqual(try XCTUnwrap(clock.now).timeIntervalSince1970, serverSeconds + 98.75, accuracy: 0.000_001)
    }

    func testAnchorExpiresAtExactlyFifteenMinutesAndRejectsUptimeRollbackOrNonfiniteReadings() async throws {
        var uptime: TimeInterval = 1_000
        let data = payload(), http = response()
        let clock = WorldEventClock(transport: { _ in (data, http) }, uptime: { uptime })
        await clock.refresh()
        uptime = 1_899.999
        XCTAssertEqual(try XCTUnwrap(clock.now).timeIntervalSince1970, serverSeconds + 899.999, accuracy: 0.000_001)
        uptime = 1_900; XCTAssertNil(clock.now)
        uptime = 1_901; XCTAssertNil(clock.now)
        for invalid in [999.0, .nan, .infinity, -.infinity] { uptime = invalid; XCTAssertNil(clock.now) }
    }

    func testUnsupportedSchemaScheduleAndMalformedPayloadCannotCreateTrustedTime() async {
        let invalid: [Data] = [
            payload(schema: 0), payload(schema: 2), payload(schedule: 0), payload(schedule: 2),
            Data("{\"schema\":\"1\",\"schedule\":1,\"serverNow\":2100000000}".utf8),
            Data("{\"schema\":1,\"schedule\":1}".utf8),
            Data("not JSON".utf8), Data()
        ]
        let http = response()
        for data in invalid {
            let clock = WorldEventClock(transport: { _ in (data, http) }, uptime: { 1_000 })
            await clock.refresh(); assertOffline(clock); XCTAssertNil(clock.anchor)
        }
    }

    func testOversizedAndNonfiniteOrOutOfRangeServerTimeAreRejected() async {
        let base = payload()
        let oversized = base + Data(repeating: 32, count: 4096 - base.count)
        XCTAssertEqual(oversized.count, 4096)
        let invalid = [oversized, oversized + Data([32]), payload(serverNow: 1_699_999_999),
                       payload(serverNow: 4_102_444_801),
                       Data("{\"schema\":1,\"schedule\":1,\"serverNow\":1e999}".utf8),
                       Data("{\"schema\":1,\"schedule\":1,\"serverNow\":\"NaN\"}".utf8),
                       Data("{\"schema\":1,\"schedule\":1,\"serverNow\":\"Infinity\"}".utf8)]
        let http = response()
        for data in invalid {
            let clock = WorldEventClock(transport: { _ in (data, http) }, uptime: { 1_000 })
            await clock.refresh(); assertOffline(clock); XCTAssertNil(clock.anchor)
        }
    }

    func testRedirectsAlternatePathsAndNon200ResponsesCannotSupplyClockAnchors() async {
        let data = payload()
        let replies: [URLResponse] = [
            response(url: URL(string: "https://attacker.example/api/events")!),
            response(url: URL(string: "https://orbit-bloom-game-site.ajnasnb.workers.dev.attacker.example/api/events")!),
            response(url: URL(string: "http://orbit-bloom-game-site.ajnasnb.workers.dev/api/events")!),
            response(url: URL(string: "https://orbit-bloom-game-site.ajnasnb.workers.dev:444/api/events")!),
            response(url: URL(string: "https://orbit-bloom-game-site.ajnasnb.workers.dev/other")!),
            response(code: 201), response(code: 204), response(code: 301), response(code: 404), response(code: 500),
            URLResponse(url: WorldEventClock.endpoint, mimeType: "application/json", expectedContentLength: data.count, textEncodingName: "utf-8")
        ]
        for reply in replies {
            let clock = WorldEventClock(transport: { _ in (data, reply) }, uptime: { 1_000 })
            await clock.refresh(); assertOffline(clock); XCTAssertNil(clock.anchor)
        }
    }

    func testFirstOfflineRefreshLeavesAllEventsUntrustedAndExplainsOfflinePlay() async {
        let clock = WorldEventClock(transport: { _ in throw URLError(.notConnectedToInternet) }, uptime: { 1_000 })
        await clock.refresh()
        assertOffline(clock); XCTAssertNil(clock.anchor); XCTAssertTrue(clock.status.contains("rooms stay open"))
    }

    func testFailedRefreshKeepsOnlyTheOriginalAnchorUntilItsOriginalExpiry() async throws {
        var uptime: TimeInterval = 1_000
        var calls = 0
        let data = payload(), http = response()
        let clock = WorldEventClock(transport: { _ in
            calls += 1
            if calls > 1 { throw URLError(.notConnectedToInternet) }
            return (data, http)
        }, uptime: { uptime })
        await clock.refresh()
        uptime = 1_100; await clock.refresh()
        XCTAssertEqual(try XCTUnwrap(clock.now).timeIntervalSince1970, serverSeconds + 100, accuracy: 0.000_001)
        XCTAssertTrue(clock.status.contains("checked recently"))
        uptime = 1_899.999; await clock.refresh(); XCTAssertNotNil(clock.now)
        uptime = 1_900; await clock.refresh(); assertOffline(clock)
        XCTAssertEqual(try XCTUnwrap(clock.anchor).timeIntervalSince1970, serverSeconds, accuracy: 0.000_001)
        uptime = 2_000; await clock.refresh(); assertOffline(clock)
    }

    func testInvalidRefreshCannotReplaceAValidAnchorOrExtendItsLifetime() async throws {
        var uptime: TimeInterval = 1_000
        var data = payload()
        let http = response()
        let clock = WorldEventClock(transport: { _ in (data, http) }, uptime: { uptime })
        await clock.refresh()
        data = payload(schema: 2, serverNow: serverSeconds + 900)
        uptime = 1_800; await clock.refresh()
        XCTAssertEqual(try XCTUnwrap(clock.now).timeIntervalSince1970, serverSeconds + 800, accuracy: 0.000_001)
        uptime = 1_900; XCTAssertNil(clock.now)
    }

    func testOverlappingRefreshesIssueOneRequestAndLaterRefreshCanRenewTheAnchor() async throws {
        var calls = 0
        var reply: CheckedContinuation<(Data, URLResponse), Error>?
        var uptime: TimeInterval = 1_000
        let data = payload(), http = response()
        let clock = WorldEventClock(transport: { _ in
            calls += 1
            if calls == 1 { return try await withCheckedThrowingContinuation { reply = $0 } }
            return (data, http)
        }, uptime: { uptime })
        let first = Task { await clock.refresh() }
        for _ in 0..<100 where reply == nil { await Task.yield() }
        let pending = try XCTUnwrap(reply)
        await clock.refresh(); await clock.refresh()
        XCTAssertEqual(calls, 1); XCTAssertNil(clock.anchor)
        pending.resume(returning: (data, http)); await first.value
        XCTAssertNotNil(clock.now)
        uptime = 1_900; XCTAssertNil(clock.now)
        await clock.refresh()
        XCTAssertEqual(calls, 2); XCTAssertNotNil(clock.now)
        uptime = 2_799.999; XCTAssertNotNil(clock.now)
        uptime = 2_800; XCTAssertNil(clock.now)
    }

    func testAnInvalidMonotonicAnchorIsNeverAccepted() async {
        let data = payload(), http = response()
        for uptime in [-1.0, .nan, .infinity, -.infinity] {
            let clock = WorldEventClock(transport: { _ in (data, http) }, uptime: { uptime })
            await clock.refresh(); assertOffline(clock); XCTAssertNil(clock.anchor)
        }
    }
}
