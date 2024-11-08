import SwiftUI
import CoreLocation
import AVFoundation
import Combine

class WorkoutViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    // Published properties for SwiftUI to observe
    @Published var currentSpeed: Double = 0.0
    @Published var feedbackMessage: String = ""
    @Published var heartRate: Int = 0
    @Published var workoutTime: TimeInterval = 0
    
    // Define target pace range
    let targetPaceMin: Double = 2.0
    let targetPaceMax: Double = 3.0
    
    private var workoutTimer: AnyCancellable?
    private var feedbackTimer: AnyCancellable?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        
        // Start workout timer
        workoutTime = 0
        workoutTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.workoutTime += 1
                self.updateHeartRate()
            }
        
        // Start feedback timer to check pace every 5 seconds
        feedbackTimer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.checkPaceAndGiveFeedback()
            }
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        workoutTimer?.cancel()
        feedbackTimer?.cancel()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        currentSpeed = max(0, latestLocation.speed)
    }
    
    private func checkPaceAndGiveFeedback() {
        if currentSpeed < targetPaceMin {
            giveFeedback("Speed up!")
        } else if currentSpeed > targetPaceMax {
            giveFeedback("Slow down!")
        } else {
            feedbackMessage = "Good pace!"
        }
    }
    
    private func giveFeedback(_ message: String) {
        feedbackMessage = message
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        // Stop any ongoing speech before starting a new one to ensure it speaks
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        speechSynthesizer.speak(utterance)
    }

    private func updateHeartRate() {
        heartRate = Int.random(in: 60...180)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

