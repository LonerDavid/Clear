import SwiftUI
import Photos
import PhotosUI

// MARK: - StressTrendChart.swift
// MARK: Deprecated in future
//
//struct StressTrendChart: View {
//    let color: Color
//    let percentage: Int
//    @State private var animateChart = false
//    
//    var body: some View {
//        HStack(spacing: 2) {
//            ForEach(0..<7, id: \.self) { index in
//                let height = CGFloat.random(in: 8...25)
//                Rectangle()
//                    .fill(color)
//                    .frame(width: 3, height: animateChart ? height : 5)
//                    .animation(.spring(response: 0.6).delay(Double(index) * 0.1), value: animateChart)
//            }
//        }
//        .onAppear {
//            animateChart = true
//        }
//    }
//}
