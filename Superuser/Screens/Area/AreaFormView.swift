//
//  AreaFormView.swift
//  Superuser
//
//  Created by Phi on 2021-01-16.
//

import SwiftUI

struct EditAreaFormView: View {
    @ObservedObject var area: Area
    
    @State var title = ""
    @State var emoji = ""
    @State var health: Int16 = 5
    @State var priority: Int16 = 5
    @State var type = "Personal"
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    private func addArea() {
        withAnimation {
            area.emoji = emoji
            area.title = title
            area.priority = priority
            area.health = health
            area.isProfessional = type == "Professional"
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    var body: some View {
        AreaFormView(title: $title, emoji: $emoji, health: $health, priority: $priority, type: $type, isEdit: true, handleSubmit: {
            presentationMode.wrappedValue.dismiss()
            withAnimation {
                area.lastModified = Date()
                area.emoji = emoji
                area.title = title
                area.priority = priority
                area.health = health
                area.isProfessional = type == "Professional"
                try? viewContext.save()
            }
        })
        .onAppear {
            title = area.title!
            emoji = area.emoji!
            health = area.health
            priority = area.priority
            type = area.isProfessional ? "Professional" : "Personal"
        }
    }
}

struct NewAreaFormView: View {
    @State var title = ""
    @State var emoji = ""
    @State var health: Int16 = 5
    @State var priority: Int16 = 5
    @State var type = "Personal"
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        AreaFormView(title: $title, emoji: $emoji, health: $health, priority: $priority, type: $type, isEdit: false, handleSubmit: {
            presentationMode.wrappedValue.dismiss()
            withAnimation {
                viewContext.perform {
                    let newArea = Area(context: viewContext)
                    newArea.id = UUID()
                    newArea.createdAt = Date()
                    newArea.lastModified = Date()
                    newArea.emoji = emoji
                    newArea.title = title
                    newArea.priority = priority
                    newArea.health = health
                    newArea.isProfessional = type == "Professional"
                    try? viewContext.save()
                }
            }
        })
    }
}

struct AreaFormView: View {
    @Binding var title: String
    @Binding var emoji: String
    @Binding var health: Int16
    @Binding var priority: Int16
    @Binding var type: String
    var isEdit: Bool
    var handleSubmit: () -> Void
    
    var body: some View {
        Text(isEdit ? "Edit Area" : "Add New Area")
            .fontWeight(.bold)
            .font(.title)
            .padding(.top, 24)
        Form {
            Section {
                TextField("Title", text: $title)
                TextField("Emoji", text: $emoji)
            }
            
            Section {
                TitleSegmentedNumberPicker(end: 10, title: HealthData.label, color: HealthData.color, selection: $health)
                TitleSegmentedNumberPicker(end: 10, title: PriorityData.label, color: PriorityData.color, selection: $priority)
            }
            
            Section {
                PersonalProfessionalPicker(type: $type)
            }
            
            Section {
                Button {
                    handleSubmit()
                } label: {
                    Text(isEdit ? "Save" : "Add Area")
                }
            }
        }
    }
}

struct PersonalProfessionalPicker: View {
    @Binding var type: String
    var withAll = false
    var types = ["Personal", "Professional"]
    
    var body: some View {
        Picker("Type", selection: $type) {
            ForEach((withAll ? ["All"] : []) + types, id: \.self) { type in
                Text(type).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct AreaFormView_Previews: PreviewProvider {
    static var previews: some View {
//        AreaFormView()
        EmptyView()
    }
}

