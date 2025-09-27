import SwiftUI

struct AddCategoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let parentCategory: Category?
    
    @State private var name = ""
    @State private var selectedColor = "#007AFF"
    @State private var selectedIcon = "circle.fill"
    @State private var showingColorPicker = false
    @State private var showingIconPicker = false
    
    private let colors = [
        "#007AFF", "#FF3B30", "#30D158", "#FF9500", "#AF52DE",
        "#FF2D92", "#5AC8FA", "#FF6B6B", "#64D2FF", "#FF9F0A"
    ]
    
    private let icons = [
        "circle.fill", "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "leaf.fill", "drop.fill", "sun.max.fill", "moon.fill", "cloud.fill",
        "briefcase.fill", "person.fill", "house.fill", "car.fill", "airplane",
        "book.fill", "pencil", "paintbrush.fill", "music.note", "camera.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? .gray)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(selectedIcon == icon ? Color(hex: selectedColor) : .gray)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(selectedIcon == icon ? Color(hex: selectedColor)?.opacity(0.1) : Color.clear)
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button("Create Category") {
                        createCategory()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle(parentCategory == nil ? "New Category" : "New Subcategory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createCategory() {
        Task {
            await dataManager.createCategory(
                name: name,
                color: selectedColor,
                icon: selectedIcon,
                parentId: parentCategory?.id
            )
            dismiss()
        }
    }
}

#Preview {
    AddCategoryView(parentCategory: nil)
        .environmentObject(DataManager())
}
