//
//  TimerService.swift
//  GoTime
//
//  Created by John Keith on 1/27/17.
//  Copyright © 2017 John Keith. All rights reserved.
//

import UIKit
import AVFoundation

enum LapQualities {
    case good
    case bad
    case ugly
}

protocol StopWatchServiceDelegate: class {
    func stopWatchIntervalElapsed(totalTimeElapsed: TimeInterval)
    
    func stopWatchStopped()
    
    func stopWatchPaused()
    
    func stopWatchRestarted()
    
    func stopWatchLapStored(lapTime: Double, lapNumber: Int, totalTime: Double)
    
    func stopWatchStarted()
    
    func stopWatchLapRemoved()
}

class StopWatchService: NSObject {
    private typealias klass = StopWatchService
    weak var delegate: StopWatchServiceDelegate?
    
    var coreData: CoreDataService
    
    var timer: Timer!
    var pingTimer: Timer!
    var timerRunning: Bool = false
    var startTime: TimeInterval!
    var elapsedTimeBeforePause: TimeInterval = 0.0

    lazy var lapTimes: Array = [Double]()
    
    init(coreDataService: CoreDataService = CoreDataService.shared) {
        coreData = coreDataService
    }
    
    func start(initialTime: TimeInterval = NSDate.timeIntervalSinceReferenceDate, restart: Bool = false) {
        startTime = initialTime
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(timeIntervalElapsed),
            userInfo: nil,
            repeats: true
        )

        timerRunning = true
    
        if(!restart) {
            lapTimes.append(0.0)
            delegate?.stopWatchStarted()
        }
        
        startPingInterval()
    }
    
    func startPingInterval() {
        if pingTimer == nil {
            let shouldStartInterval = Constants.storedSettings.bool(forKey: SettingsService.intervalKey)
            
            if shouldStartInterval {
                let intervalLength = Constants.storedSettings.integer(forKey: SettingsService.intervalAmountKey)
                
                pingTimer = Timer.scheduledTimer(
                    timeInterval: TimeInterval(intervalLength),
                    target: self,
                    selector: #selector(pingIntervalElapsed),
                    userInfo: nil,
                    repeats: true
                )
            }
        }
    }
    
    @objc func timeIntervalElapsed() {
        lapTimes[lapTimes.endIndex - 1] = calculateTimeBetweenPointAndNow(initialTime: startTime)
        let totalTimeElapsed = klass.calculateTotalLapsTime(laps: lapTimes)

        delegate?.stopWatchIntervalElapsed(totalTimeElapsed: totalTimeElapsed)
    }
    
    @objc func pingIntervalElapsed() {
        DispatchQueue.main.async {
            let systemSoundID: SystemSoundID = 1106

            AudioServicesPlaySystemSound(systemSoundID)
        }
    }
    
    func completedLapTimes() -> [Double] {
        if self.lapTimes.count > 0 {
            return Array(self.lapTimes[0..<self.lapTimes.count - 1])
        } else {
            return []
        }
    }
    
    func calculateTotalLapsTime() -> Double {
        return klass.calculateTotalLapsTime(laps: lapTimes)
    }
    
    func wasMileCompleted() -> Bool {
        let lapsPerMile = Constants.storedSettings.integer(forKey: SettingsService.milePaceAmountKey)
        
        return (completedLapTimes().count % lapsPerMile) == 0
    }
    
    func calculateMilePace() -> Double {
        let lapsPerMile = Constants.storedSettings.integer(forKey: SettingsService.milePaceAmountKey)
        let lapTimes = completedLapTimes().reversed()[0..<lapsPerMile]
        
        return klass.calculateTotalLapsTime(laps: Array(lapTimes))
    }
    
    func completedMiles() -> Int {
        let lapsPerMile = Constants.storedSettings.integer(forKey: SettingsService.milePaceAmountKey)
        
        return completedLapTimes().count / lapsPerMile
    }
    
    func calculateLapDeviationPercentage(lapTime: Double) -> Double {
        let currentStandardDeviation = klass.calculateStandardDeviation(laps: self.lapTimes)
        let currentAverageLapTime = klass.calculateAverageLapTime(laps: self.lapTimes)
        
        let startOfDeviationRange = currentAverageLapTime - currentStandardDeviation
        let endOfDeviationRange = currentAverageLapTime + currentStandardDeviation

        // starts at 0 being good, 1 being no good
        if (lapTime <= startOfDeviationRange) {
            return 0.0
        } else if ((startOfDeviationRange...endOfDeviationRange).contains(lapTime)) {
            return (lapTime - startOfDeviationRange) / (endOfDeviationRange - startOfDeviationRange)
        } else { // lapTime >= endOfDeviationRange
            return 1.0
        }
    }
    
    func colorOfLapTime(lapTime: Double) -> UIColor {
        let percent = CGFloat(calculateLapDeviationPercentage(lapTime: lapTime))
        let baseGreen = CIColor(color: Constants.colorGreen)
        let baseRed = CIColor(color: Constants.colorRed)
        
        if (percent == 0.0) {
            return Constants.colorGreen;
        } else if (percent == 1.0) {
            return Constants.colorRed
        }
        
        let resultRed = baseGreen.red + percent * (baseRed.red - baseGreen.red);
        let resultGreen = baseGreen.green + percent * (baseRed.green - baseGreen.green);
        let resultBlue = baseGreen.blue + percent * (baseRed.blue - baseGreen.blue);
        
        return UIColor(red: resultRed, green: resultGreen, blue: resultBlue, alpha: 1.0)
    }
    
    func calculateTimeBetweenPointAndNow(initialTime: TimeInterval) -> TimeInterval {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        return currentTime - initialTime
    }
    
    func stop() {
        if(timer != nil) {
            timer.invalidate()
        }
        
        if(pingTimer != nil) {
            pingTimer.invalidate()
        }

        RunPersistanceService(_lapTimes: self.lapTimes).save()

        resetInitialState()
        
        delegate?.stopWatchStopped()
    }
    
    func resetInitialState() {
        timer = nil
        pingTimer = nil
        timerRunning = false
        startTime = nil
        elapsedTimeBeforePause = 0.0
        lapTimes.removeAll()
    }
    
    func pause() {
        elapsedTimeBeforePause = calculateTimeBetweenPointAndNow(initialTime: startTime)
        
        timerRunning = false
        
        timer.invalidate()
        
        if pingTimer != nil {
            pingTimer.invalidate()
            pingTimer = nil
        }
        
        delegate?.stopWatchPaused()
    }
    
    func restart() {
        let newStartTime = NSDate.timeIntervalSinceReferenceDate - elapsedTimeBeforePause
        
        elapsedTimeBeforePause = 0.0
        
        start(initialTime: newStartTime, restart: true)
        
        delegate?.stopWatchRestarted()
    }
    
    func lap() {
        timer.invalidate()

        start()
    
        let currentTotalTime = klass.calculateTotalLapsTime(laps: lapTimes)
        let lapNumber = lapTimes.count - 1
        let lapTime = lapTimes[lapTimes.count - 2]
                
        delegate?.stopWatchLapStored(lapTime: lapTime, lapNumber: lapNumber, totalTime: currentTotalTime)
    }
    
    func deleteLap(at: Int) {
        lapTimes.remove(at: at)
        
        if lapTimes.count == 0 {
            lapTimes.append(0.0)
        }
        
        elapsedTimeBeforePause = lapTimes.last!
        
        delegate?.stopWatchLapRemoved()
    }
    
    func isPaused() -> Bool {
        return elapsedTimeBeforePause != 0.0 && !timerRunning
    }
}

// MARK: CLASS FUNCTIONS
extension StopWatchService {
    class func findFastestLapIndex(_ laps: [Double]) -> Int? {
        let min = laps.min()
        
        if (min != nil) {
            return laps.index(of: min!)
        } else {
            return nil
        }
    }
    
    class func findSlowestLapIndex(_ laps: [Double]) -> Int? {
        let max = laps.max()
        
        if (max != nil) {
            return laps.index(of: max!)
        } else {
            return nil
        }
    }
    
    class func calculateTotalLapsTime(laps: [Double]) -> Double {
        return laps.map{$0}.reduce(0, +)
    }
    
    class func calculateAverageLapTime(laps: [Double]) -> Double {
        let totalLapTime = calculateTotalLapsTime(laps: laps)
        
        return totalLapTime / Double(laps.count)
    }
    
    class func calculateStandardDeviation(laps: [Double]) -> Double {
        let meanLapTime = calculateAverageLapTime(laps: laps)
        
        let sumOfLaps = laps.reduce(0.0, { acc, time in
            let s = (time - meanLapTime)
            return acc + s * s
        })
        
        let result = sumOfLaps / Double(laps.count)
        
        return result.squareRoot()
    }
    
    class func determineLapQuality(lap: Double, laps: [Double]) -> LapQualities {
        let currentStandardDeviation = calculateStandardDeviation(laps: laps)
        let currentAverageLapTime = calculateAverageLapTime(laps: laps)
        
        if (lap <= currentAverageLapTime) {
            return LapQualities.good
        } else if (lap <= currentStandardDeviation + currentAverageLapTime) {
            return LapQualities.bad
        } else {
            return LapQualities.ugly
        }
    }
}
