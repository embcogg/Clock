import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var timer: Timer?
    var countdownTimer: Timer?
    var endTime: Date?
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLiveClock()
        setupDatePicker()
        setupAudioPlayer()
    }
    
    func startLiveClock() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateClock()
        }
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .countDownTimer
    }
    
    func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "London", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print("Audio player setup failed with error: \(error)")
        }
    }
    
    @objc func updateClock() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        let currentTime = Date()
        label1.text = dateFormatter.string(from: currentTime)
        
        updateBackgroundImage(for: currentTime)
    }
    
    func updateBackgroundImage(for currentTime: Date) {
        let hour = Calendar.current.component(.hour, from: currentTime)
        backgroundImageView.image = UIImage(named: hour < 12 ? "morning" : "night")
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        if actionButton.titleLabel?.text == "Start Timer" {
            startCountdown()
        } else if actionButton.titleLabel?.text == "Stop Music" {
            stopMusicAndReset()
        } else {
            cancelTimer()
        }
    }
    
    func startCountdown() {
        let duration = datePicker.countDownDuration
        endTime = Date().addingTimeInterval(duration)
        label2.text = durationString(from: duration)
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
        actionButton.setTitle("Cancel Timer", for: .normal)
    }
    
    @objc func updateCountdown() {
        guard let endTime = endTime else { return }
        let timeInterval = endTime.timeIntervalSinceNow
        
        if timeInterval <= 0 {
            finishCountdown()
            return
        }
        
        label2.text = durationString(from: timeInterval)
    }
    
    func durationString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func finishCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        playMusic()
        actionButton.setTitle("Stop Music", for: .normal)
    }
    
    func playMusic() {
        audioPlayer?.play()
    }
    //Track: London
    //Music by https://www.fiftysounds.com
    
    func stopMusicAndReset() {
        audioPlayer?.stop()
        resetTimerUI()
    }
    
    func cancelTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        resetTimerUI()
    }
    
    func resetTimerUI() {
        label2.text = "00:00:00"
        actionButton.setTitle("Start Timer", for: .normal)
        datePicker.isEnabled = true
    }
}
