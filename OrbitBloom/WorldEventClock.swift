import Foundation
import Combine

/// HTTPS supplies the UTC anchor; uptime avoids device-clock edits during a session.
@MainActor final class WorldEventClock: ObservableObject {
    typealias Transport = (URLRequest) async throws -> (Data, URLResponse)
    @Published private(set) var status = "Connecting to the world event clock…"
    @Published private(set) var anchor: Date?
    private var anchoredUptime: TimeInterval = 0
    private var working = false
    private let transport: Transport
    private let readUptime: () -> TimeInterval
    static let endpoint = URL(string: "https://orbit-bloom-game-site.ajnasnb.workers.dev/api/events")!

    init(transport: Transport? = nil,
         uptime: @escaping () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }) {
        readUptime = uptime
        self.transport = transport ?? { request in
            let session = URLSession(configuration: .ephemeral)
            defer { session.invalidateAndCancel() }
            return try await session.data(for: request)
        }
    }

    var now: Date? {
        let elapsed = readUptime() - anchoredUptime
        guard let anchor, elapsed.isFinite, (0..<900).contains(elapsed) else { return nil }
        return anchor.addingTimeInterval(elapsed)
    }

    func refresh() async {
        // Overlapping callers use the published result of the first request, without issuing another.
        guard !working else { return }
        working = true; defer { working = false }
        do {
            var request = URLRequest(url: Self.endpoint, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 12)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await transport(request)
            struct Payload: Decodable { let schema: Int; let schedule: Int; let serverNow: Double }
            let checkedUptime = readUptime()
            guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                  http.url == Self.endpoint,
                  data.count < 4096, let payload = try? JSONDecoder().decode(Payload.self, from: data),
                  payload.schema == 1, payload.schedule == 1, payload.serverNow.isFinite,
                  (1_700_000_000...4_102_444_800).contains(payload.serverNow),
                  checkedUptime.isFinite, checkedUptime >= 0 else { throw URLError(.badServerResponse) }
            anchor = Date(timeIntervalSince1970: payload.serverNow)
            anchoredUptime = checkedUptime
            status = "Worldwide · same UTC schedule for everyone"
        } catch {
            status = now == nil ? "Offline · rooms stay open. Connect to join world events." : "World clock checked recently · retrying soon"
        }
    }
}
