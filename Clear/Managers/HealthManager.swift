// MARK: - HealthManager.swift

import SwiftUI
import Photos
import HealthKit
import UserNotifications

class HealthManager: ObservableObject {
    @Published var isAuthorized = false
    @Published var currentHRV: Double = 45.2
    @Published var currentHeartRate: Double = 72.0
    @Published var currentRespiratoryRate: Double = 16.0
    @Published var sleepREMMinutes: Double = 0.0
    @Published var stepCount: Int = 0
    @Published var activeEnergy: Double = 0.0
    @Published var stressAnalysis = StressAnalysis()
    @Published var isLoadingHealth = false
    @Published var healthError: String?

    private let healthStore = HKHealthStore()

    init() {
        setupMockData()
        checkHealthKitAvailability()
    }

    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            healthError = "此設備不支援 HealthKit"
            return
        }
    }

    func requestHealthKitPermission() {
        guard HKHealthStore.isHealthDataAvailable() else {
            healthError = "此設備不支援 HealthKit"
            return
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.healthError = "HealthKit 授權失敗：\(error.localizedDescription)"
                    print("HealthKit 授權錯誤：\(error)")
                } else if success {
                    self?.isAuthorized = true
                    self?.healthError = nil
                    self?.loadBasicHealthData()
                    print("HealthKit 授權成功")
                } else {
                    self?.healthError = "無法獲得健康數據權限"
                    print("HealthKit 授權被拒絕")
                }
            }
        }
    }

    private func setupMockData() {
        stressAnalysis.acuteStressLevel = Double.random(in: 20...60)
        stressAnalysis.chronicStressLevel = Double.random(in: 30...70)
        currentHRV = Double.random(in: 30...60)
        currentHeartRate = Double.random(in: 65...85)
        currentRespiratoryRate = Double.random(in: 14...18)
        sleepREMMinutes = Double.random(in: 60...90)
        stepCount = Int.random(in: 2000...8000)
        activeEnergy = Double.random(in: 200...600)
    }

    private func loadBasicHealthData() {
        isLoadingHealth = true

        if isAuthorized {
            loadRealHealthData()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.setupMockData()
                self?.isLoadingHealth = false
            }
        }
    }

    private func loadRealHealthData() {
        loadHeartRateData()
        loadHRVData()
        loadRespiratoryRateData()
        loadSleepData()
        loadStepCount()
        loadActiveEnergy()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.estimateChronicStress()
            self?.isLoadingHealth = false
        }
    }

    private func loadHeartRateData() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-3600), end: Date(), options: [])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: nil) { _, samples, _ in
            if let sample = samples?.first as? HKQuantitySample {
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                DispatchQueue.main.async { self.currentHeartRate = bpm }
            }
        }
        healthStore.execute(query)
    }

    private func loadHRVData() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-604800), end: Date(), options: [])
        let statsQuery = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage, anchorDate: Date(), intervalComponents: DateComponents(day: 1))
        statsQuery.initialResultsHandler = { _, results, _ in
            var sum: Double = 0
            var count = 0
            results?.enumerateStatistics(from: Date().addingTimeInterval(-604800), to: Date()) { stats, _ in
                if let avg = stats.averageQuantity()?.doubleValue(for: .secondUnit(with: .milli)) {
                    sum += avg
                    count += 1
                }
            }
            DispatchQueue.main.async {
                let averageHRV = count > 0 ? sum / Double(count) : 0
                self.currentHRV = averageHRV
                self.updateStressAnalysisFromHRV(averageHRV)
            }
        }
        healthStore.execute(statsQuery)
    }

    private func loadRespiratoryRateData() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-3600), end: Date(), options: [])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: nil) { _, samples, _ in
            if let sample = samples?.first as? HKQuantitySample {
                let breaths = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                DispatchQueue.main.async { self.currentRespiratoryRate = breaths }
            }
        }
        healthStore.execute(query)
    }

    private func loadSleepData() {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-604800), end: Date(), options: [])
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let sleepSamples = samples as? [HKCategorySample] else { return }

            let remSamples = sleepSamples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue }
            let totalREMMinutes = remSamples.reduce(0.0) { partialResult, sample in
                partialResult + sample.endDate.timeIntervalSince(sample.startDate) / 60.0
            }

            DispatchQueue.main.async {
                self.sleepREMMinutes = totalREMMinutes
            }
        }

        healthStore.execute(query)
    }

    private func loadStepCount() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-86400), end: Date(), options: [])
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
            if let sum = stats?.sumQuantity() {
                let steps = Int(sum.doubleValue(for: .count()))
                DispatchQueue.main.async { self.stepCount = steps }
            }
        }
        healthStore.execute(query)
    }

    private func loadActiveEnergy() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-86400), end: Date(), options: [])
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
            if let sum = stats?.sumQuantity() {
                let kcal = sum.doubleValue(for: .kilocalorie())
                DispatchQueue.main.async { self.activeEnergy = kcal }
            }
        }
        healthStore.execute(query)
    }

    private func updateStressAnalysisFromHRV(_ hrv: Double) {
        let stressFromHRV = max(0, min(100, (60 - hrv) * 2))
        stressAnalysis.acuteStressLevel = stressFromHRV
    }

    private func estimateChronicStress() {
        let sleepFactor = sleepREMMinutes < 60 ? 0.7 : 0.3
        let stepFactor = stepCount < 3000 ? 0.6 : 0.3
        let breathFactor = currentRespiratoryRate > 18 ? 0.8 : 0.3
        let energyFactor = activeEnergy < 250 ? 0.6 : 0.3

        let weighted = (sleepFactor + stepFactor + breathFactor + energyFactor) / 4.0
        stressAnalysis.chronicStressLevel = min(100, weighted * 100)
    }

    func refreshHealthData() {
        if isAuthorized {
            loadBasicHealthData()
        } else {
            requestHealthKitPermission()
        }
    }

    func getStressRecommendations() -> [String] {
        var recommendations: [String] = []

        if stressAnalysis.acuteStressLevel > 50 {
            recommendations.append("🫁 進行深呼吸練習，幫助立即放鬆")
            recommendations.append("🧘‍♀️ 嘗試5分鐘的正念冥想")
        }

        if stressAnalysis.chronicStressLevel > 50 || sleepREMMinutes < 60 {
            recommendations.append("😴 建議每晚睡眠7-9小時，提升 REM 深度")
            recommendations.append("🏃‍♂️ 保持規律的適度運動")
        }

        if currentHeartRate > 80 || currentRespiratoryRate > 18 {
            recommendations.append("💆‍♀️ 嘗試放鬆技巧降低心率與呼吸")
        }

        if stepCount < 3000 || activeEnergy < 200 {
            recommendations.append("🚶‍♂️ 增加日常活動，避免壓力累積")
        }

        if recommendations.isEmpty {
            recommendations.append("✨ 您的壓力水平很健康，繼續保持！")
        }

        return recommendations
    }
    
    private func formatTimeLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 壓力模型
struct StressAnalysis {
    var acuteStressLevel: Double = 25
    var chronicStressLevel: Double = 35

    var stressCategory: StressCategory {
        let avgStress = (acuteStressLevel + chronicStressLevel) / 2
        switch avgStress {
        case 0..<25: return .low
        case 25..<50: return .moderate
        case 50..<75: return .high
        default: return .severe
        }
    }
}

enum StressCategory: String, CaseIterable {
    case low = "低壓力"
    case moderate = "中等壓力"
    case high = "高壓力"
    case severe = "嚴重壓力"

    var color: Color {
        switch self {
        case .low: return .yellow
        case .moderate: return .green
        case .high: return .orange
        case .severe: return .red
        }
    }

    var emoji: String {
        switch self {
        case .low: return "😌"
        case .moderate: return "😐"
        case .high: return "😰"
        case .severe: return "😵‍💫"
        }
    }
}

struct StressDataPoint: Identifiable {
    let id = UUID()
    let timeLabel: String // e.g., "Mon", "14:00"
    let value: Double
    let type: StressType
}

enum StressType: String, CaseIterable {
    case acute = "Acute"
    case chronic = "Chronic"
}


extension PHAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "未確定"
        case .restricted: return "受限制"
        case .denied: return "被拒絕"
        case .authorized: return "已授權"
        case .limited: return "有限授權"
        @unknown default: return "未知(\(rawValue))"
        }
    }
}

extension HealthManager {
    // Chronic stress: past 7 days
    func getChronicStressTrend(completion: @escaping ([StressDataPoint]) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -6, to: now)!)
        let endDate = now
        let interval = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])

        let statsQuery = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage, anchorDate: startDate, intervalComponents: interval)
        statsQuery.initialResultsHandler = { _, results, _ in
            var dataPoints: [StressDataPoint] = []
            results?.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
                if let avgHRV = stats.averageQuantity()?.doubleValue(for: .secondUnit(with: .milli)) {
                    let stress = max(0, min(100, (60 - avgHRV) * 2))
                    let dayLabel = DateFormatter.localizedString(from: stats.startDate, dateStyle: .short, timeStyle: .none)
                    dataPoints.append(StressDataPoint(timeLabel: dayLabel, value: stress, type: .chronic))
                }
            }
            DispatchQueue.main.async {
                completion(dataPoints)
            }
        }
        healthStore.execute(statsQuery)
    }

    // Acute stress: past 7 hours
    func getAcuteStressTrend(completion: @escaping ([StressDataPoint]) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion([])
            return
        }
        
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-7 * 3600) // 7 hours ago
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            let dataPoints = samples.map { sample -> StressDataPoint in
                let hrv = sample.quantity.doubleValue(for: .secondUnit(with: .milli))
                let stressLevel = max(0, min(100, (60 - hrv) * 2))
                let timeLabel = self.formatTimeLabel(sample.startDate)
                return StressDataPoint(timeLabel: timeLabel, value: stressLevel, type: .acute)
            }
            
            DispatchQueue.main.async {
                completion(dataPoints)
            }
        }
        
        healthStore.execute(query)
    }
}

