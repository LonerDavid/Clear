//
//  StressLineChartView.swift
//  Clear
//
//  Created by Haruaki on 2025/6/12.
//


import SwiftUI
import Charts

struct StressLineChartView: View {
    @State private var chronicStressData: [StressDataPoint] = []
    @State private var acuteStressData: [StressDataPoint] = []
    @State private var isLoading = true
    @EnvironmentObject var healthManager: HealthManager
    let color: Color
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if isLoading {
                ProgressView("Loading stress data...")
                    .frame(height: 40)
            } else if chronicStressData.isEmpty && acuteStressData.isEmpty {
                Text("No stress data available.")
                    .foregroundColor(.secondary)
                    .frame(height: 40)
            } else {
                if type == "chronic" {
                    VStack(alignment: .leading) {
//                        Text("Chronic Stress")
//                            .font(.headline)
                        Chart {
                            ForEach(chronicStressData) { point in
                                LineMark(
                                    x: .value("Time", point.timeLabel),
                                    y: .value("Stress Level", point.value)
                                )
                                .foregroundStyle(color)
                                .symbol(.circle)
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(height: 40)
                    }
                } else if type == "acute" {
                    VStack(alignment: .leading) {
//                        Text("Acute Stress")
//                            .font(.headline)
                        Chart {
                            ForEach(acuteStressData) { point in
                                LineMark(
                                    x: .value("Time", point.timeLabel),
                                    y: .value("Stress Level", point.value)
                                )
                                .foregroundStyle(color)
                                .symbol(.circle)
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: loadStressData)
    }

    private func loadStressData() {
        isLoading = true
        let group = DispatchGroup()
        
        if type == "chronic" {
            group.enter()
            healthManager.getChronicStressTrend { data in
                chronicStressData = data
                group.leave()
            }
        } else if type == "acute" {
            group.enter()
            healthManager.getAcuteStressTrend { data in
                acuteStressData = data
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
}

