import AVFoundation

@MainActor final class AudioDirector {
    static let shared = AudioDirector()
    private var music: AVAudioPlayer?
    private var effects: [AVAudioPlayer] = []
    private var current = ""
    func theme(_ name: String, enabled: Bool) {
        guard enabled else { music?.stop(); current = ""; return }
        guard current != name else { if music?.isPlaying == false { music?.play() }; return }
        guard let url = Bundle.main.url(forResource:"music-" + name,withExtension:"m4a") else { return }
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        music = try? AVAudioPlayer(contentsOf:url); music?.volume = 0.23; music?.numberOfLoops = -1; music?.play(); current = name
    }
    func effect(_ name: String, enabled: Bool = true) {
        guard enabled, let url = Bundle.main.url(forResource:"sfx-" + name,withExtension:"m4a"), let player = try? AVAudioPlayer(contentsOf:url) else { return }
        effects.removeAll { !$0.isPlaying }; effects.append(player); player.volume = 0.6; player.play()
    }
    func suspend() { music?.pause() }
}
