import Foundation
import SwiftUI

class TimerManager: ObservableObject {
    @Published var currentTimer: TimeEntry?
    @Published var isTimerRunning: Bool = false
    @Published var currentDuration: TimeInterval = 0
    
    private var timer: Timer?
    private var lastTick: Date?

    init() {
        loadTimerState()
        if isTimerRunning, let timer = currentTimer {
            if let startTime = timer.startTime, let lastActiveObject = UserDefaults.standard.object(forKey: "lastActiveDate"), let lastActive = lastActiveObject as? Date {
                let elapsedInBackground = Date().timeIntervalSince(lastActive)
                currentDuration = timer.totalDuration + elapsedInBackground
            }
            startTimer()
        }
    }

    func startTracking(for category: Category, userId: UUID) {
        if isTimerRunning {
            stopTracking()
        }
        currentTimer = TimeEntry(categoryId: category.id, userId: userId, startTime: Date(), endTime: nil, isActive: true, totalDuration: 0, createdAt: Date())
        isTimerRunning = true
        currentDuration = 0
        startTimer()
        saveTimerState()
    }

    func pauseTracking() {
        stopTimer()
        if var timer = currentTimer {
            timer.totalDuration = currentDuration
            timer.isActive = false
            currentTimer = timer
            isTimerRunning = false
            saveTimerState()
        }
    }

    func resumeTracking() {
        if var timer = currentTimer {
            timer.startTime = Date()
            timer.isActive = true
            currentTimer = timer
            isTimerRunning = true
            startTimer()
            saveTimerState()
        }
    }

    func stopTracking() {
        stopTimer()
        if var timer = currentTimer {
            timer.endTime = Date()
            timer.totalDuration = currentDuration
            timer.isActive = false
            currentTimer = timer
            isTimerRunning = false
            saveTimerState()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        lastTick = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isTimerRunning else { return }
            self.currentDuration += 1
            self.saveTimerState()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func saveTimerState() {
        if let encoded = try? JSONEncoder().encode(currentTimer) {
            UserDefaults.standard.set(encoded, forKey: "currentTimer")
        }
        UserDefaults.standard.set(isTimerRunning, forKey: "isTimerRunning")
        UserDefaults.standard.set(currentDuration, forKey: "currentDuration")
        UserDefaults.standard.set(Date(), forKey: "lastActiveDate")
    }

    private func loadTimerState() {
        if let data = UserDefaults.standard.data(forKey: "currentTimer"),
           let decodedTimer = try? JSONDecoder().decode(TimeEntry.self, from: data) {
            self.currentTimer = decodedTimer
        }
        self.isTimerRunning = UserDefaults.standard.bool(forKey: "isTimerRunning")
        self.currentDuration = UserDefaults.standard.double(forKey: "currentDuration")
    }
}
