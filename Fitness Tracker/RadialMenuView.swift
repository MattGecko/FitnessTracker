import SwiftUI

struct RadialMenuView: View {
    @Binding var isExpanded: Bool
    private let radius: CGFloat = 150 // Increased spacing distance
    private let buttonSize: CGFloat = 50 // Increased button size

    var body: some View {
        ZStack {
            if isExpanded {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isExpanded = false
                        }
                    }
            }

            ZStack {
                // Adjusted angles: Workout (far left), Weight (center), Food (far right)
                if isExpanded {
                    let angles: [Double] = [120, 90, 60] // More spread
                    ForEach(0..<3, id: \.self) { index in
                        let angle = Angle(degrees: angles[index])
                        let xOffset = cos(angle.radians) * radius
                        let yOffset = -sin(angle.radians) * radius
                        
                        RadialButton(
                            icon: radialButtonData[index].icon,
                            color: radialButtonData[index].color,
                            size: buttonSize
                        ) {
                            print("\(radialButtonData[index].label) tapped") // Replace with navigation
                            isExpanded = false
                        }
                        .offset(x: xOffset, y: yOffset)
                        .transition(.scale)
                    }
                }
            }
        }
    }
}

// Radial button data structure
struct RadialButtonData {
    let icon: String
    let color: Color
    let label: String
}

// Button configurations (Weight is center)
let radialButtonData: [RadialButtonData] = [
    RadialButtonData(icon: "dumbbell", color: .blue, label: "Workout"),  // Far left
    RadialButtonData(icon: "scalemass", color: .green, label: "Weight"), // Center
    RadialButtonData(icon: "fork.knife.circle.fill", color: .orange, label: "Food") // Far right
]

// Radial Button Component
struct RadialButton: View {
    var icon: String
    var color: Color
    var size: CGFloat
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(Circle().fill(color))
                .shadow(radius: 5)
        }
    }
}
