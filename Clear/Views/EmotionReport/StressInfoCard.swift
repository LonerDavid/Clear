import SwiftUI
import Photos
import PhotosUI

// MARK: - StressInfoCard.swift
struct StressInfoCard: View {
    let title: String
    let percentage: Int
    let date: String
    let color: Color
    let type: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title3)
                    .foregroundStyle(.primary)
                Spacer()
                HStack {
                    Text(date)
                        .font(.title3)
                        .foregroundStyle(.primary)
                    Image(systemName: "chevron.right")
                }
            }
            HStack {
                Text("\(percentage)%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
//                StressTrendChart(color: color, percentage: percentage)
                StressLineChartView(color: color, type: type)
            }
        }
        #if !os(visionOS)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        #endif
    }
}
