import SwiftUI
import AudioToolbox

struct ContentView: View {
    @State private var xOffset: CGFloat = 0
    @State private var tempo: Double = 60.0
    @State private var isPlaying = false
    @State var oldTransaction: Transaction = Transaction()
    @State var id = 0
    let squares = (0..<30).map { _ in Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)) }
    @State var squareSize = 45.0
    @State var squareSpacing = 5.0
    @State var squareTotalSize = 50.0
    @State var timerHolder = TimerHolder()
    @State var currentIndex = 0
    
    var body: some View {
        VStack {
            Text("Tempo: \(tempo)")
            
            if isPlaying {
                ScrollView(.vertical) {
//                    ScrollViewReader { proxy in
                        HStack {
                            ForEach(squares.indices, id: \.self) { idx in
                                Rectangle()
                                    .fill(squares[idx])
                                    .frame(width: squareSize, height: squareSize)
                                    .overlay(Text("\(idx+1)"))
                            }
                        }
                        .offset(x: xOffset)
                        .id(id)
                    }
                    .frame(width: squareTotalSize * 6.0, height: squareTotalSize, alignment: .leading)
                    .border(.red)
//                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack {
                            ForEach(squares.indices, id: \.self) { idx in
                                Rectangle()
                                    .fill(squares[idx])
                                    .frame(width: squareSize, height: squareSize)
                                    .overlay(Text("\(idx+1)"))
                                    .id(idx)
                            }
                        }
                        .onAppear{
                            proxy.scrollTo(currentIndex, anchor: .leading)
                        }
                    }
                }
                .frame(maxWidth: 300.0)
                .border(.red)
            }
   
            Button(isPlaying ? "Pause" : "Play") {
                isPlaying.toggle()
                if isPlaying {
                    startTimerAndAnimation()
                } else {
                    timerHolder.stop()
                }
            }.keyboardShortcut(" ", modifiers: [])

            HStack {
                Button("Decrease Tempo") {
                    changeTempo(by: -10.0)
                }
                Button("Increase Tempo") {
                    changeTempo(by: 10.0)
                }
            }
            Button("Reset") {
                isPlaying = false
                tempo = 60
                currentIndex = 0
                timerHolder.stop()
            }
        }
    }
    
    func startTimerAndAnimation() {
        if currentIndex >= squares.count {
            currentIndex = 0
            xOffset = 0
        }
        timerHolder.start(withInterval: 60 / tempo, repeats: true, stopCondition: {
            return currentIndex >= self.squares.count
        }) { _ in
            currentIndex += 1
            NSSound.beep()
        }
        xOffset = -(Double(currentIndex) * squareTotalSize)
        let duration = (60.0 / tempo) * Double(squares.count)
        id += 1 // This resets the view
        withAnimation(.linear(duration: duration)) {
            xOffset -= CGFloat(squares.count * Int(squareTotalSize))
        }
    }

    func changeTempo(by amount: Double) {
        tempo = amount < 0 ? max(10, tempo + amount) : (tempo + amount)
        startTimerAndAnimation()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//#Preview {
//    ContentView()
//}

class TimerHolder {
    var timer: Timer?

    func start(withInterval interval: TimeInterval, repeats: Bool, stopCondition: @escaping () -> Bool, block: @escaping (Timer) -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { [weak self] timer in
            if stopCondition() {
                self?.stop()
            } else {
                block(timer)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
