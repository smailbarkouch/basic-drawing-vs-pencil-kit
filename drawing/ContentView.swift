//
//  ContentView.swift
//  drawing
//
//  Created by Smail Barkouch on 9/4/24.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()

    var body: some View {
        TabView {
            SimpleDrawingWithVel()
                .tabItem {
                    Label("Simple Drawing", systemImage: "pencil.line")
                }
            
            PencilKitWrapper(canvasView: $canvasView)
                .tabItem {
                    Label("Pencil Kit", systemImage: "pencil.line")
                }
        }
    }
}

#Preview {
    ContentView()
}

struct SimpleDrawingWithVel: View {
    @State var vel: Double = 0.0
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("\(vel)")
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            .padding()
            
            SimpleDrawingWrapper(updateVel: {
                vel = $0
            })
        }
    }
}

struct SimpleDrawingWrapper: UIViewRepresentable {
    let updateVel: (Double) -> Void
    
    init(updateVel: @escaping (Double) -> Void) {
        self.updateVel = updateVel
    }
    func makeUIView(context: Context) -> some UIView {
        SimpleDrawingView(frame: .infinite, updateVel: updateVel)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct PencilKitWrapper: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) { }
}

class SimpleDrawingView: UIView {
    private let circleLayer = CAShapeLayer()
    private var lastPoint: CGPoint = .zero
    private var lastMoment = 0.0
    var updateVel: (Double) -> Void = {_ in }
    
    init(frame: CGRect, updateVel: @escaping (Double) -> Void) {
        super.init(frame: frame)
        self.updateVel = updateVel
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        circleLayer.strokeColor = UIColor.green.cgColor
        circleLayer.fillColor = UIColor.green.withAlphaComponent(0.5).cgColor
        circleLayer.lineWidth = 0.5
        layer.addSublayer(circleLayer)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        lastPoint = point
        lastMoment = Date().timeIntervalSince1970
        
        updateCircle(at: point)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let currentTime = Date().timeIntervalSince1970
        updateVel(sqrt(pow(point.x - lastPoint.x, 2) + pow(point.y - lastPoint.y, 2)) / (currentTime - lastMoment))
        lastMoment = currentTime
        lastPoint = point
        

        updateCircle(at: point)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        let currentTime = Date().timeIntervalSince1970
        updateVel(sqrt(pow(point.x - lastPoint.x, 2) + pow(point.y - lastPoint.y, 2)) / (currentTime - lastMoment))
        lastMoment = currentTime
        lastPoint = point
    }

    private func updateCircle(at point: CGPoint) {
        let radius: CGFloat = 5.0
        let circlePath = UIBezierPath(arcCenter: point, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        circleLayer.path = circlePath.cgPath
    }
}

