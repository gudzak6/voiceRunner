import SwiftUI

struct WorkoutView: View {
    // Initialize the view model
    @StateObject private var viewModel = WorkoutViewModel()
    
    // Format workout time as minutes and seconds
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Live Workout Tracker")
                .font(.largeTitle)
                .padding()
            
            // Display current speed
            Text("Current Speed: \(viewModel.currentSpeed, specifier: "%.2f") m/s")
                .font(.title2)
            
            // Display feedback message
            Text(viewModel.feedbackMessage)
                .font(.headline)
                .foregroundColor(viewModel.feedbackMessage == "Good pace!" ? .green : .red)
            
            // Display heart rate
            Text("Heart Rate: \(viewModel.heartRate) bpm")
                .font(.title2)
                .foregroundColor(.pink)
            
            // Display workout time
            Text("Workout Time: \(formatTime(viewModel.workoutTime))")
                .font(.title2)
                .foregroundColor(.blue)
            
            // Start/Stop buttons for tracking
            HStack {
                Button("Start Workout") {
                    viewModel.startTracking()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Stop Workout") {
                    viewModel.stopTracking()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}
