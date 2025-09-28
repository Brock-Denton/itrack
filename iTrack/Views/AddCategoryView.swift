import SwiftUI

struct AddCategoryView: View {
    @EnvironmentObject var dataManager: AppDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var categoryName = ""
    @State private var selectedIcon = "folder"
    @State private var selectedColor = Color.blue
    
    private let availableIcons = [
        "folder", "briefcase", "person", "house", "book", "laptop", "phone", "car", "heart", "star",
        "sun.max", "moon", "cloud", "leaf", "flame", "drop", "snow", "bolt", "eye", "ear"
    ]
    
    private let availableColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .brown, .gray, .indigo
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Category Name")
                        .font(.headline)
                    
                    TextField("Enter category name", text: $categoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Icon")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? selectedColor : Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Color")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(availableColors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    dataManager.addCategory(
                        name: categoryName,
                        color: ColorData(swiftUI: selectedColor),
                        icon: selectedIcon
                    )
                    dismiss()
                }) {
                    Text("Add Category")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(categoryName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(categoryName.isEmpty)
            }
            .padding()
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    AddCategoryView()
        .environmentObject(AppDataManager())
}