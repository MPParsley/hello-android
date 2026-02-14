import SwiftUI
import Shared

struct ContentView: View {
    let greeting = Greeting().greet()

    var body: some View {
        VStack {
            Spacer()
            Text(greeting)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
