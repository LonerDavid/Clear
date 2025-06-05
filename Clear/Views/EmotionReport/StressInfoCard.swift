import SwiftUI
import Photos
import PhotosUI

// MARK: - StressInfoCard.swift
struct StressInfoCard: View {
    let title: String
    let percentage: Int
    let date: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("\(percentage)%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text(date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // 趨勢圖
                    StressTrendChart(color: color, percentage: percentage)
                }
            }
            
            // 進度條
            ProgressView(value: Double(percentage), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
