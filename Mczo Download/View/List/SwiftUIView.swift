import SwiftUI

struct TestView: View {

    @State var isEditing = false
    @State var selection = Set<String>()

    var names = ["Karl", "Hans", "Faustao"]

    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selection) {
                    ForEach(names, id: \.self) {
                        name in
                        Text(name)
                    }
                }
                .navigationBarTitle("Names")
                .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring())
                Button(action: {
                    self.isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .frame(width: 80, height: 40)
                }
                .background(Color.yellow)
            }
            .padding(.bottom)
        }
    }
}

#if DEBUG
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
