import SwiftUI

struct ContentView: View {
    @StateObject private var manager = CameraControlManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Valeur du bouton")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("\(manager.scrollValue)")
                .font(.system(size: 80, weight: .bold))
        }
        .onAppear {
            manager.setupControl()
        }
    }
}
