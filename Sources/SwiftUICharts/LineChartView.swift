//
//  LineChartView.swift
//  CardioBot
//
//  Created by Majid Jabrayilov on 6/27/20.
//  Copyright © 2020 Majid Jabrayilov. All rights reserved.
//
import SwiftUI

/// Type that defines a line chart style.
public struct LineChartStyle: ChartStyle {
    public let lineMinHeight: CGFloat
    public let showAxis: Bool
    public let axisLeadingPadding: CGFloat
    public let showLabels: Bool
    public let labelCount: Int?
    public let showLegends: Bool
    public let filled: Bool
    public let lineWidth: CGFloat
    public let animationDuration: Double
    
    /**
     Creates new line chart style with the following parameters.
     
     - Parameters:
     - lineMinHeight: The minimal height for the point that presents the biggest value. Default is 100.
     - showAxis: Bool value that controls whenever to show axis.
     - axisLeadingPadding: Leading padding for axis line. Default is 0.
     - showLabels: Bool value that controls whenever to show labels.
     - labelCount: The count of labels that should be shown below the the chart. Default is all.
     - showLegends: Bool value that controls whenever to show legends.
     - filled: Bool value that controls the filled aspect of the chart
     - lineWidth: the width of the line when drawing the line (filled = false)
     - animationDuration: animation duration, set to 0 for instant effect

     
     */
    
    public init(
        lineMinHeight: CGFloat = 100,
        showAxis: Bool = true,
        axisLeadingPadding: CGFloat = 0,
        showLabels: Bool = true,
        labelCount: Int? = nil,
        showLegends: Bool = true,
        filled: Bool = true,
        lineWidth: CGFloat = 5,
        animationDuration: Double = 0.0
    ) {
        self.lineMinHeight = lineMinHeight
        self.showAxis = showAxis
        self.axisLeadingPadding = axisLeadingPadding
        self.showLabels = showLabels
        self.labelCount = labelCount
        self.showLegends = showLegends
        self.filled = filled
        self.lineWidth = lineWidth
        self.animationDuration = animationDuration
    }
}

/// SwiftUI view that draws data points by drawing a line.
public struct LineChartView: View {
    @Environment(\.chartStyle) var chartStyle
    let dataPoints: [DataPoint]
    @State private var percentage: CGFloat = .zero
    
    /**
     Creates new line chart view with the following parameters.
     
     - Parameters:
     - dataPoints: The array of data points that will be used to draw the bar chart.
     */
    public init(dataPoints: [DataPoint]) {
        self.dataPoints = dataPoints
    }
    
    private var style: LineChartStyle {
        (chartStyle as? LineChartStyle) ?? .init()
    }
    
    private var gradient: LinearGradient {
        let colors = dataPoints.map(\.legend).map(\.color)
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var grid: some View {
        ChartGrid(dataPoints: dataPoints)
            .stroke(
                style.showAxis ? Color.secondary : .clear,
                style: StrokeStyle(
                    lineWidth: 1,
                    lineCap: .round,
                    lineJoin: .round,
                    miterLimit: 0,
                    dash: [1, 8],
                    dashPhase: 1
                )
            )
    }
    
    public var body: some View {
        VStack {
            HStack(spacing: 0) {
                
                if(style.filled) {
                    LineChartShape(dataPoints: dataPoints)
                        .trim(from: 0, to: percentage)
                        .fill(gradient)
                        .animation(.easeInOut(duration:style.animationDuration))
                        .frame(minHeight: style.lineMinHeight)
                        .background(grid)
                } else {
                    LineChartShape(dataPoints: dataPoints, closePath: false)
                        .trim(from: 0, to: percentage)
                        .stroke(gradient,
                                style: StrokeStyle(
                                    lineWidth:style.lineWidth,
                                    lineCap: .round,
                                    lineJoin: .round
                                    //TODO: add the dash and others
                                    
                                )
                            )
                        .animation(.easeOut(duration: style.animationDuration))
                        .frame(minHeight: style.lineMinHeight)
                        .background(grid)
                }
                
                if style.showAxis {
                    AxisView(dataPoints: dataPoints)
                        .accessibilityHidden(true)
                        .padding(.leading, style.axisLeadingPadding)
                }
            }.onAppear {
                self.percentage = 1.0 // << activates animation for 0 to the end
            }
            
            if style.showLabels {
                LabelsView(dataPoints: dataPoints, labelCount: style.labelCount ?? dataPoints.count)
                    .accessibilityHidden(true)
            }
            
            if style.showLegends {
                LegendView(dataPoints: dataPoints)
                    .padding()
                    .accessibilityHidden(true)
            }
        }
    }
}

#if DEBUG
struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LineChartView(dataPoints: DataPoint.mock)
                .chartStyle(LineChartStyle(showAxis: false, showLabels: false, animationDuration: 3.0))
            LineChartView(dataPoints: DataPoint.mock).chartStyle(LineChartStyle(filled:false,lineWidth: 3))
        }
    }
}
#endif
