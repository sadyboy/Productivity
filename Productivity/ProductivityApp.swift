import SwiftUI
import Combine
import EventKit
import CoreLocation
internal import UniformTypeIdentifiers

@main
struct ProductivityApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var weatherManager = WeatherManager()
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some Scene {
        WindowGroup {
            if store.showSplash {
                SplashView()
                    .environmentObject(store)
            } else {
                MainView()
                    .environmentObject(store)
                    .environmentObject(weatherManager)
                    .environmentObject(calendarManager)
                    .preferredColorScheme(.dark)
                    .onAppear {
                        calendarManager.requestAccess()
                        weatherManager.requestLocationPermission()
                    }
            }
        }
    }
}

struct SplashView: View {
    @EnvironmentObject var store: AppStore
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
            
            VStack(spacing: 20) {
                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .cyan, .blue], startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .shadow(color: .cyan.opacity(0.5), radius: 20)
                
                Text("PCrazy Cutch Water")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .cyan], startPoint: .leading, endPoint: .trailing)
                    )
                    .opacity(opacity)
                    .shadow(color: .blue.opacity(0.5), radius: 10)
                
                Text("Enterprise Productivity Suite")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
            }
        }
        .onAppear {
            createParticles()
            
            withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                scale = 1.2
                opacity = 1
            }
            withAnimation(.linear(duration: 2)) {
                rotation = 360
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    store.showSplash = false
                }
            }
        }
    }
    
    func createParticles() {
        for _ in 0..<20 {
            let particle = Particle(
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -400...400),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.2...0.6)
            )
            particles.append(particle)
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

struct MainView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            AnimatedBackground(index: selectedTab)
            
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                        case 0: TasksView()
                        case 1: EisenhowerMatrixView()
                        case 2: TeamView()
                        case 3: TimerView()
                        case 4: AdvancedAnalyticsView()
                        case 5: AchievementsView()
                        default: TasksView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct AnimatedBackground: View {
    let index: Int
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: animate ? CGFloat.random(in: -100...100) : 0,
                            y: animate ? CGFloat.random(in: -200...200) : 0)
                    .blur(radius: 60)
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...5))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.3),
                        value: animate
                    )
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .onAppear { animate = true }
        .onChange(of: index) { _ in
            animate.toggle()
        }
    }
    
    var gradientColors: [Color] {
        switch index {
            case 0: return [.purple.opacity(0.3), .blue.opacity(0.3), .cyan.opacity(0.3)]
            case 1: return [.pink.opacity(0.3), .orange.opacity(0.3), .yellow.opacity(0.3)]
            case 2: return [.green.opacity(0.3), .mint.opacity(0.3), .teal.opacity(0.3)]
            case 3: return [.indigo.opacity(0.3), .purple.opacity(0.3), .pink.opacity(0.3)]
            case 4: return [.cyan.opacity(0.3), .blue.opacity(0.3), .purple.opacity(0.3)]
            case 5: return [.yellow.opacity(0.3), .orange.opacity(0.3), .red.opacity(0.3)]
            default: return [.blue.opacity(0.3)]
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs = [
        ("list.bullet", "Tasks"),
        ("square.grid.2x2", "Matrix"),
        ("person.3.fill", "Team"),
        ("timer", "Focus"),
        ("chart.xyaxis.line", "Analytics"),
        ("trophy.fill", "Rewards")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    TabButton(
                        icon: tabs[index].0,
                        title: tabs[index].1,
                        isSelected: selectedTab == index
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .blur(radius: 20)
        )
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    @State private var scale: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(
                    isSelected ?
                    LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
                )
                .scaleEffect(isSelected ? 1.2 : 1)
                .scaleEffect(scale)
            
            Text(title)
                .font(.system(size: 9, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .cyan : .gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            isSelected ?
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cyan.opacity(0.2)) :
                RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
        )
        .onChange(of: isSelected) { newValue in
            if newValue {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.15
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
                    scale = 1
                }
            }
        }
    }
}

struct EisenhowerMatrixView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var draggedTask: Task?
    @State private var showAddTask = false
    @State private var selectedQuadrant: EisenhowerQuadrant = .urgentImportant
    
    var quadrants: [EisenhowerQuadrant: [Task]] {
        Dictionary(grouping: store.tasks.filter { !$0.isCompleted && !$0.isArchived }) { task in
            task.eisenhowerQuadrant
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Eisenhower Matrix")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, .orange], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    Text("Prioritize with Strategy")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button {
                    showAddTask = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            ScrollView {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        QuadrantBox(
                            quadrant: .urgentImportant,
                            tasks: quadrants[.urgentImportant] ?? [],
                            draggedTask: $draggedTask
                        )
                        
                        QuadrantBox(
                            quadrant: .notUrgentImportant,
                            tasks: quadrants[.notUrgentImportant] ?? [],
                            draggedTask: $draggedTask
                        )
                    }
                    
                    HStack(spacing: 12) {
                        QuadrantBox(
                            quadrant: .urgentNotImportant,
                            tasks: quadrants[.urgentNotImportant] ?? [],
                            draggedTask: $draggedTask
                        )
                        
                        QuadrantBox(
                            quadrant: .notUrgentNotImportant,
                            tasks: quadrants[.notUrgentNotImportant] ?? [],
                            draggedTask: $draggedTask
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskMatrixView(selectedQuadrant: $selectedQuadrant)
                .environmentObject(store)
                .environmentObject(calendarManager)
        }
    }
}

struct QuadrantBox: View {
    @EnvironmentObject var store: AppStore
    let quadrant: EisenhowerQuadrant
    let tasks: [Task]
    @Binding var draggedTask: Task?
    @State private var isTargeted = false
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(quadrant.icon)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(quadrant.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(quadrant.subtitle)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(tasks.count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(quadrant.color)
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(tasks) { task in
                            MatrixTaskCard(task: task)
                                .onDrag {
                                    draggedTask = task
                                    return NSItemProvider(object: task.id.uuidString as NSString)
                                }
                        }
                        
                        if tasks.isEmpty {
                            Text("Drop tasks here")
                                .font(.system(size: 12))
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [quadrant.color.opacity(0.2), quadrant.color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isTargeted ? quadrant.color : Color.clear, lineWidth: 2)
            )
            .onDrop(of: [.ahap], isTargeted: $isTargeted) { providers in
                guard let draggedTask = draggedTask else { return false }
                store.updateTaskQuadrant(id: draggedTask.id, quadrant: quadrant)
                self.draggedTask = nil
                return true
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct MatrixTaskCard: View {
    @EnvironmentObject var store: AppStore
    let task: Task
    
    var body: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation {
                    store.toggleTask(id: task.id)
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text(task.priority.icon)
                        .font(.system(size: 8))
                    
                    if task.isOverdue {
                        Text("Overdue")
                            .font(.system(size: 9))
                            .foregroundColor(.red)
                    } else {
                        Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct AddTaskMatrixView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss
    @Binding var selectedQuadrant: EisenhowerQuadrant
    @State private var title = ""
    @State private var category = "Work"
    @State private var dueDate = Date()
    @State private var addToCalendar = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .purple.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Text("New Task")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        TextField("Task title", text: $title)
                            .textFieldStyle(.plain)
                            .padding(16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Quadrant")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            ForEach(EisenhowerQuadrant.allCases, id: \.self) { quadrant in
                                QuadrantSelector(
                                    quadrant: quadrant,
                                    isSelected: selectedQuadrant == quadrant,
                                    action: { selectedQuadrant = quadrant }
                                )
                            }
                        }
                        
                        Menu {
                            ForEach(["Work", "Personal", "Study", "Health", "Shopping"], id: \.self) { cat in
                                Button(cat) { category = cat }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                Text(category)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .padding(16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        
                        Toggle(isOn: $addToCalendar) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Add to Calendar")
                            }
                            .foregroundColor(.white)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        Button {
                            let priority = selectedQuadrant.defaultPriority
                            store.addTask(
                                title: title,
                                priority: priority,
                                category: category,
                                dueDate: dueDate,
                                quadrant: selectedQuadrant
                            )
                            
                            if addToCalendar {
                                calendarManager.addEvent(title: title, date: dueDate)
                            }
                            
                            dismiss()
                        } label: {
                            Text("Create Task")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                        }
                        .disabled(title.isEmpty)
                        .opacity(title.isEmpty ? 0.5 : 1)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct QuadrantSelector: View {
    let quadrant: EisenhowerQuadrant
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? quadrant.color : .gray)
                
                Text(quadrant.icon)
                    .font(.system(size: 20))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(quadrant.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text(quadrant.subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? quadrant.color.opacity(0.2) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? quadrant.color : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct TeamView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddMember = false
    @State private var showShareTask = false
    @State private var selectedTask: Task?
    @State private var selectedLesson: Lesson?
    @State private var showTest: Bool = false
    @State private var selectedTest: CourseTest?
    
    var sharedTasks: [Task] {
        store.tasks.filter { !$0.sharedWith.isEmpty }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Team & Learning")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, .green], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    Text("\(store.teamMembers.count) members • \(store.completedLessons.count)/\(store.lessons.count) lessons")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button {
                    showAddMember = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team Members")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(store.teamMembers) { member in
                                    TeamMemberCard(member: member)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Learning Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(
                                    LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
                                )
                            
                            Text("Learning Center")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        // Progress Overview
                        VStack(spacing: 12) {
                            HStack {
                                Text("Course Progress")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(Int(store.courseProgress * 100))%")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.purple)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [.purple, .pink],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * store.courseProgress, height: 12)
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.purple.opacity(0.15))
                        )
                        
                        // Lessons
                        ForEach(store.lessons) { lesson in
                            LessonCard(
                                lesson: lesson,
                                isCompleted: store.completedLessons.contains(lesson.id.uuidString),
                                isLocked: !store.isLessonUnlocked(lesson)
                            )
                            .onTapGesture {
                                if store.isLessonUnlocked(lesson) {
                                    selectedLesson = lesson
                                }
                            }
                        }
                        
                        // Tests Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                                
                                Text("Knowledge Tests")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            ForEach(store.tests) { test in
                                TestCard(
                                    test: test,
                                    isPassed: store.passedTests.contains(test.id.uuidString),
                                    bestScore: store.testScores[test.id.uuidString] ?? 0,
                                    isLocked: !store.isTestUnlocked(test)
                                )
                                .onTapGesture {
                                    if store.isTestUnlocked(test) {
                                        selectedTest = test
                                        showTest = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Shared Tasks")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                showShareTask = true
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(.cyan)
                            }
                        }
                        
                        if sharedTasks.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "person.2.slash")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No shared tasks yet")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                
                                Text("Share tasks with your team to collaborate")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(sharedTasks) { task in
                                SharedTaskCard(task: task)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showAddMember) {
            AddTeamMemberView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showShareTask) {
            ShareTaskView()
                .environmentObject(store)
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailView(lesson: lesson)
                .environmentObject(store)
        }
        .sheet(item: $selectedTest) { item in
                TestView(test: item)
                    .environmentObject(store)
        }
    }
}

struct TeamMemberCard: View {
    let member: TeamMember
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.red, .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(member.initials)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                if member.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .offset(x: 22, y: 22)
                }
            }
            
            Text(member.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text(member.role)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct SharedTaskCard: View {
    @EnvironmentObject var store: AppStore
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(task.priority.icon)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                Text(task.dueDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
            }
            .foregroundColor(.gray)
            
            HStack(spacing: -8) {
                ForEach(task.sharedWith.prefix(3), id: \.self) { memberId in
                    if let member = store.teamMembers.first(where: { $0.id.uuidString == memberId }) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.green, .red.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(member.initials)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                }
                
                if task.sharedWith.count > 3 {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("+\(task.sharedWith.count - 3)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.green.opacity(0.2), .mint.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct AddTeamMemberView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var role = "Team Member"
    
    let roles = ["Admin", "Team Lead", "Team Member", "Guest"]
    let colors: [Color] = [.purple, .blue, .green, .orange, .pink, .cyan, .indigo, .mint]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .green.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Text("Add Team Member")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    TextField("Name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    
                    Menu {
                        ForEach(roles, id: \.self) { r in
                            Button(r) { role = r }
                        }
                    } label: {
                        HStack {
                            Text("Role: \(role)")
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Button {
                        let member = TeamMember(
                            name: name,
                            email: email,
                            role: role,
                            color: colors.randomElement() ?? .blue
                        )
                        store.addTeamMember(member)
                        dismiss()
                    } label: {
                        Text("Add Member")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                    .opacity(name.isEmpty || email.isEmpty ? 0.5 : 1)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

struct ShareTaskView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedTask: Task?
    @State private var selectedMembers: Set<String> = []
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .cyan.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Text("Share Task")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Task")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            ForEach(store.tasks.filter { !$0.isCompleted }) { task in
                                Button {
                                    selectedTask = task
                                } label: {
                                    HStack {
                                        Image(systemName: selectedTask?.id == task.id ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedTask?.id == task.id ? .cyan : .gray)
                                        
                                        Text(task.title)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedTask?.id == task.id ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
                                    )
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Share With")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            ForEach(store.teamMembers) { member in
                                Button {
                                    if selectedMembers.contains(member.id.uuidString) {
                                        selectedMembers.remove(member.id.uuidString)
                                    } else {
                                        selectedMembers.insert(member.id.uuidString)
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: selectedMembers.contains(member.id.uuidString) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedMembers.contains(member.id.uuidString) ? .green : .gray)
                                        
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.green, .blue.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Text(member.initials)
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(member.name)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            Text(member.role)
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedMembers.contains(member.id.uuidString) ? Color.green.opacity(0.2) : Color.white.opacity(0.05))
                                    )
                                }
                            }
                        }
                        
                        Button {
                            if let task = selectedTask {
                                store.shareTask(id: task.id, with: Array(selectedMembers))
                            }
                            dismiss()
                        } label: {
                            Text("Share Task")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                        }
                        .disabled(selectedTask == nil || selectedMembers.isEmpty)
                        .opacity(selectedTask == nil || selectedMembers.isEmpty ? 0.5 : 1)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct AdvancedAnalyticsView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var weatherManager: WeatherManager
    @State private var animateCharts = false
    @State private var selectedPeriod: AnalyticsPeriod = .week
    
    var productivityHeatmap: [HeatmapDay] {
        let calendar = Calendar.current
        let today = Date()
        var days: [HeatmapDay] = []
        
        for i in 0..<28 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let tasksCount = store.tasks.filter {
                calendar.isDate($0.date, inSameDayAs: date) && $0.isCompleted
            }.count
            
            days.append(HeatmapDay(date: date, intensity: min(Double(tasksCount) / 5.0, 1.0)))
        }
        
        return days.reversed()
    }
    
    var weeklyComparison: [Double] {
        let thisWeek = store.tasks.filter {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) && $0.isCompleted
        }.count
        
        let lastWeek = store.tasks.filter {
            let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
            return Calendar.current.isDate($0.date, equalTo: lastWeek, toGranularity: .weekOfYear) && $0.isCompleted
        }.count
        
        return [Double(lastWeek), Double(thisWeek)]
    }
    
    var productivityScore: Int {
        let completionRate = store.tasks.isEmpty ? 0 : Double(store.tasks.filter { $0.isCompleted }.count) / Double(store.tasks.count)
        let pomodoroScore = min(Double(store.completedPomodoros) / 20.0, 1.0)
        let streakScore = min(Double(store.focusStreak) / 7.0, 1.0)
        
        return Int((completionRate + pomodoroScore + streakScore) / 3.0 * 100)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Analytics")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, .cyan], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Text("Deep Insights")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                HStack(spacing: 12) {
                    ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                        Button {
                            withAnimation {
                                selectedPeriod = period
                            }
                        } label: {
                            Text(period.rawValue)
                                .font(.system(size: 14, weight: selectedPeriod == period ? .semibold : .regular))
                                .foregroundColor(selectedPeriod == period ? .white : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedPeriod == period ?
                                    LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(colors: [Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                ProductivityScoreCard(score: productivityScore, animate: animateCharts)
                    .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Productivity Heatmap")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Last 4 weeks")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    HeatmapView(days: productivityHeatmap, animate: animateCharts)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.2), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Week Over Week")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        WeekComparisonBar(
                            title: "Last Week",
                            value: Int(weeklyComparison[0]),
                            maxValue: max(weeklyComparison[0], weeklyComparison[1]),
                            color: .orange,
                            animate: animateCharts
                        )
                        
                        WeekComparisonBar(
                            title: "This Week",
                            value: Int(weeklyComparison[1]),
                            maxValue: max(weeklyComparison[0], weeklyComparison[1]),
                            color: .cyan,
                            animate: animateCharts
                        )
                    }
                    
                    if weeklyComparison[1] > weeklyComparison[0] {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.right")
                            Text("You're \(Int(((weeklyComparison[1] - weeklyComparison[0]) / max(weeklyComparison[0], 1)) * 100))% more productive this week!")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.2), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .padding(.horizontal, 20)
                
                if let weather = weatherManager.currentWeather {
                    WeatherInsightCard(weather: weather)
                        .padding(.horizontal, 20)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Task Completion Trend")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    LineChartView(data: generateTrendData(), animate: animateCharts)
                        .frame(height: 200)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.pink.opacity(0.2), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI Predictions")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    PredictionCard(
                        icon: "brain.head.profile",
                        title: "Optimal Work Time",
                        prediction: "You're most productive between 9-11 AM",
                        confidence: 87
                    )
                    
                    PredictionCard(
                        icon: "calendar.badge.clock",
                        title: "Completion Forecast",
                        prediction: "You'll likely complete 8 tasks this week",
                        confidence: 76
                    )
                    
                    PredictionCard(
                        icon: "figure.walk",
                        title: "Break Recommendation",
                        prediction: "Take a break every 52 minutes for best results",
                        confidence: 92
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.indigo.opacity(0.2), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            withAnimation {
                animateCharts = true
            }
        }
    }
    
    func generateTrendData() -> [Double] {
        let calendar = Calendar.current
        var data: [Double] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -6 + i, to: Date())!
            let count = store.tasks.filter {
                calendar.isDate($0.date, inSameDayAs: date) && $0.isCompleted
            }.count
            data.append(Double(count))
        }
        
        return data
    }
}

struct ProductivityScoreCard: View {
    let score: Int
    let animate: Bool
    @EnvironmentObject var store: AppStore // or whatever your store type is
    var scoreColor: Color {
        switch score {
            case 0..<30: return .red
            case 30..<60: return .orange
            case 60..<80: return .yellow
            default: return .green
        }
    }
    
    var scoreText: String {
        switch score {
            case 0..<30: return "Needs Focus"
            case 30..<60: return "Good Progress"
            case 60..<80: return "Great Work"
            default: return "Outstanding!"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Productivity Score")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: animate ? Double(score) / 100.0 : 0)
                    .stroke(
                        LinearGradient(
                            colors: [scoreColor, scoreColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 2, dampingFraction: 0.6), value: animate)
                
                VStack(spacing: 8) {
                    Text("\(animate ? score : 0)")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .animation(.spring(response: 1.5, dampingFraction: 0.7), value: animate)
                    
                    Text(scoreText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(scoreColor)
                }
            }
            
            HStack(spacing: 24) {
                ScoreMetric(icon: "checkmark.circle.fill", value: "\(store.tasks.filter { $0.isCompleted }.count)", label: "Completed", color: .green)
        
                ScoreMetric(icon: "flame.fill", value: "\(store.focusStreak)", label: "Streak", color: .orange)
                ScoreMetric(icon: "clock.fill", value: "\(store.totalFocusMinutes)", label: "Minutes", color: .cyan)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [scoreColor.opacity(0.2), scoreColor.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct ScoreMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
    }
}

struct HeatmapView: View {
    let days: [HeatmapDay]
    let animate: Bool
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                Rectangle()
                    .fill(
                        day.intensity == 0 ?
                            AnyShapeStyle(Color.gray.opacity(0.2)) :
                            AnyShapeStyle(LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ).opacity(day.intensity))
                    )
                    .frame(height: 40)
                    .cornerRadius(8)
                    .scaleEffect(animate ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.02), value: animate)
            }
        }
    }
}

struct WeekComparisonBar: View {
    let title: String
    let value: Int
    let maxValue: Double
    let color: Color
    let animate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: animate ? 150 * (Double(value) / max(maxValue, 1)) : 0)
                    .animation(.spring(response: 1.5, dampingFraction: 0.7), value: animate)
            }
            
            Text("\(value) tasks")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WeatherInsightCard: View {
    let weather: WeatherData
    
    var productivityTip: String {
        switch weather.condition {
            case "Clear", "Sunny":
                return "Perfect weather! Consider working near a window for natural light boost."
            case "Rain", "Rainy":
                return "Rainy day ahead. Great time for deep focus work indoors."
            case "Cloudy":
                return "Overcast conditions. Keep workspace well-lit for better focus."
            default:
                return "Check weather conditions for optimal work environment."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: weather.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weather Insights")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(Int(weather.temperature))°C • \(weather.condition)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Text(productivityTip)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.cyan.opacity(0.2), .blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct LineChartView: View {
    let data: [Double]
    let animate: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let stepX = geometry.size.width / CGFloat(data.count - 1)
            let stepY = geometry.size.height / CGFloat(maxValue)
            
            ZStack {
                Path { path in
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - (CGFloat(value) * stepY)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(
                    LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                .animation(.easeInOut(duration: 1.5), value: animate)
                
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 8, height: 8)
                        .position(
                            x: CGFloat(index) * stepX,
                            y: geometry.size.height - (CGFloat(value) * stepY)
                        )
                        .scaleEffect(animate ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.1), value: animate)
                }
            }
        }
    }
}

struct PredictionCard: View {
    let icon: String
    let title: String
    let prediction: String
    let confidence: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(prediction)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 10))
                    Text("\(confidence)% confidence")
                        .font(.system(size: 11))
                }
                .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct TasksView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var weatherManager: WeatherManager
    @State private var showAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskPriority: Priority = .medium
    @State private var newTaskCategory = "Work"
    @State private var newTaskDueDate = Date()
    @State private var animateList = false
    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var showFilters = false
    @State private var selectedTask: Task?
    @State private var addToCalendar = false
    
    var filteredTasks: [Task] {
        var tasks = store.tasks.filter { !$0.isArchived }
        
        if !searchText.isEmpty {
            tasks = tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch selectedFilter {
            case .all:
                break
            case .active:
                tasks = tasks.filter { !$0.isCompleted }
            case .completed:
                tasks = tasks.filter { $0.isCompleted }
            case .highPriority:
                tasks = tasks.filter { $0.priority == .high && !$0.isCompleted }
            case .today:
                tasks = tasks.filter { Calendar.current.isDateInToday($0.dueDate) }
        }
        
        return tasks
    }
    
    var weatherReminder: String? {
        guard let weather = weatherManager.currentWeather else { return nil }
        
        if weather.condition.contains("Rain") {
            return "☔️ Rainy day - perfect for indoor focused work"
        } else if weather.temperature > 25 {
            return "☀️ Hot day - stay hydrated and take breaks"
        } else if weather.temperature < 10 {
            return "🧊 Cold day - warm environment helps productivity"
        }
        return nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tasks")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, .cyan], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Text("\(store.tasks.filter { !$0.isCompleted && !$0.isArchived }.count) active")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring()) {
                            showFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(
                                LinearGradient(colors: showFilters ? [.cyan, .blue] : [.gray, .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                            )
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            showAddTask.toggle()
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(
                                LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
                            )
                            .rotationEffect(.degrees(showAddTask ? 45 : 0))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                if let reminder = weatherReminder {
                    HStack(spacing: 8) {
                        Text(reminder)
                            .font(.system(size: 13))
                            .foregroundColor(.cyan)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cyan.opacity(4.15))
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search tasks...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.5))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                
                if showFilters {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(TaskFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.title,
                                    isSelected: selectedFilter == filter,
                                    action: {
                                        withAnimation {
                                            selectedFilter = filter
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if showAddTask {
                    VStack(spacing: 12) {
                        TextField("Task title", text: $newTaskTitle)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(
                                LinearGradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                        
                        HStack(spacing: 12) {
                            Menu {
                                ForEach(Priority.allCases, id: \.self) { priority in
                                    Button {
                                        newTaskPriority = priority
                                    } label: {
                                        HStack {
                                            Text(priority.icon)
                                            Text(priority.rawValue)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(newTaskPriority.icon)
                                    Text(newTaskPriority.rawValue)
                                        .font(.system(size: 14))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            Menu {
                                ForEach(["Work", "Personal", "Study", "Health", "Shopping"], id: \.self) { category in
                                    Button(category) {
                                        newTaskCategory = category
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "folder.fill")
                                    Text(newTaskCategory)
                                        .font(.system(size: 14))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        
                        DatePicker("Due Date", selection: $newTaskDueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        
                        Toggle(isOn: $addToCalendar) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Add to Calendar")
                            }
                            .foregroundColor(.white)
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        
                        Button {
                            store.addTask(
                                title: newTaskTitle,
                                priority: newTaskPriority,
                                category: newTaskCategory,
                                dueDate: newTaskDueDate
                            )
                            
                            if addToCalendar {
                                calendarManager.addEvent(title: newTaskTitle, date: newTaskDueDate)
                            }
                            
                            newTaskTitle = ""
                            newTaskPriority = .medium
                            newTaskCategory = "Work"
                            newTaskDueDate = Date()
                            addToCalendar = false
                            withAnimation {
                                showAddTask = false
                            }
                        } label: {
                            Text("Add Task")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(12)
                        }
                        .disabled(newTaskTitle.isEmpty)
                        .opacity(newTaskTitle.isEmpty ? 0.5 : 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(filteredTasks.enumerated()), id: \.element.id) { index, task in
                            TaskRow(task: task)
                                .offset(x: animateList ? 0 : -300)
                                .opacity(animateList ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: animateList)
                                .onTapGesture {
                                    selectedTask = task
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            animateList = true
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
                .environmentObject(store)
        }
    }
}

struct TaskRow: View {
    @EnvironmentObject var store: AppStore
    let task: Task
    @State private var isPressed = false
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring()) {
                        store.deleteTask(id: task.id)
                    }
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                }
                
                Button {
                    store.archiveTask(id: task.id)
                } label: {
                    Image(systemName: "archivebox.fill")
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
            .padding(.trailing, 20)
            
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        store.toggleTask(id: task.id)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: task.isCompleted ? [.green, .mint] : [.purple.opacity(0.3), .blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 28, height: 28)
                        
                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(task.priority.icon)
                            .font(.system(size: 12))
                        
                        Text(task.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(task.isCompleted ? .gray : .white)
                            .strikethrough(task.isCompleted)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 10))
                            Text(task.category)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.cyan)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(task.dueDate.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 12))
                        }
                        .foregroundColor(task.isOverdue && !task.isCompleted ? .red : .gray)
                        
                        if !task.sharedWith.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 10))
                                Text("\(task.sharedWith.count)")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [task.priority.color.opacity(1.0), .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            offset = gesture.translation.width
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring()) {
                            if gesture.translation.width < -100 {
                                offset = -120
                                isSwiped = true
                            } else {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1)
    }
}

struct TaskDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let task: Task
    @State private var editedTitle: String
    @State private var editedPriority: Priority
    @State private var editedCategory: String
    @State private var editedDueDate: Date
    @State private var isEditing = false
    
    init(task: Task) {
        self.task = task
        _editedTitle = State(initialValue: task.title)
        _editedPriority = State(initialValue: task.priority)
        _editedCategory = State(initialValue: task.category)
        _editedDueDate = State(initialValue: task.dueDate)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, task.priority.color.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button {
                        isEditing.toggle()
                        if !isEditing {
                            store.updateTask(
                                id: task.id,
                                title: editedTitle,
                                priority: editedPriority,
                                category: editedCategory,
                                dueDate: editedDueDate
                            )
                        }
                    } label: {
                        Text(isEditing ? "Save" : "Edit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.cyan)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Text(task.priority.icon)
                                .font(.system(size: 40))
                            
                            if isEditing {
                                TextField("Task title", text: $editedTitle)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text(task.title)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        VStack(spacing: 16) {
                            DetailRow(icon: "flag.fill", title: "Priority", value: task.priority.rawValue, color: task.priority.color)
                            DetailRow(icon: "folder.fill", title: "Category", value: task.category, color: .cyan)
                            DetailRow(icon: "calendar", title: "Due Date", value: task.dueDate.formatted(date: .long, time: .shortened), color: task.isOverdue ? .red : .blue)
                            DetailRow(icon: "clock.fill", title: "Created", value: task.date.formatted(date: .long, time: .shortened), color: .purple)
                            
                            if task.isCompleted {
                                DetailRow(icon: "checkmark.circle.fill", title: "Status", value: "Completed", color: .green)
                            } else if task.isOverdue {
                                DetailRow(icon: "exclamationmark.triangle.fill", title: "Status", value: "Overdue", color: .red)
                            } else {
                                DetailRow(icon: "hourglass", title: "Status", value: "In Progress", color: .orange)
                            }
                            
                            if !task.sharedWith.isEmpty {
                                DetailRow(icon: "person.2.fill", title: "Shared With", value: "\(task.sharedWith.count) members", color: .green)
                            }
                        }
                        
                        Button {
                            withAnimation {
                                store.toggleTask(id: task.id)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: task.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                                Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: task.isCompleted ? [.orange, .red] : [.green, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        
                        Button {
                            store.deleteTask(id: task.id)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Delete Task")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.red.opacity(0.8), .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(
                    LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(20)
        }
    }
}

struct TimerView: View {
    @EnvironmentObject var store: AppStore
    @State private var timeRemaining = 1500
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1
    @State private var selectedDuration = 1500
    @State private var showDurationPicker = false
    
    let durations = [
        ("Pomodoro", 1500),
        ("Short Break", 300),
        ("Long Break", 900),
        ("Deep Work", 3600)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Focus Timer")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .green], startPoint: .leading, endPoint: .trailing)
                    )
                    .padding(.top, 16)
                
                Menu {
                    ForEach(durations, id: \.0) { duration in
                        Button {
                            selectedDuration = duration.1
                            timeRemaining = duration.1
                            resetTimer()
                        } label: {
                            HStack {
                                Text(duration.0)
                                Text("(\(duration.1 / 60) min)")
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(durations.first(where: { $0.1 == selectedDuration })?.0 ?? "Pomodoro")
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                }
                
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(colors: [.green.opacity(0.2), .mint.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 20
                        )
                        .frame(width: 260, height: 260)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(1 - Double(timeRemaining) / Double(selectedDuration)))
                        .stroke(
                            LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timeRemaining)
                    
                    VStack(spacing: 8) {
                        Text(timeString)
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, .mint], startPoint: .top, endPoint: .bottom)
                            )
                        
                        Text(isRunning ? "Stay Focused 🎯" : "Ready to Start")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .scaleEffect(pulseScale)
                }
                
                HStack(spacing: 16) {
                    Button {
                        toggleTimer()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 20))
                            Text(isRunning ? "Pause" : "Start")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 150, height: 56)
                        .background(
                            LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(28)
                        .shadow(color: .green.opacity(0.4), radius: 10)
                    }
                    
                    Button {
                        resetTimer()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20))
                            Text("Reset")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 150, height: 56)
                        .background(
                            LinearGradient(colors: [.purple.opacity(0.6), .blue.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(28)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Focus Sessions")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        StatBox(
                            icon: "checkmark.circle.fill",
                            value: "\(store.completedPomodoros)",
                            label: "Completed",
                            color: .green
                        )
                        
                        StatBox(
                            icon: "flame.fill",
                            value: "\(store.focusStreak)",
                            label: "Streak",
                            color: .orange
                        )
                        
                        StatBox(
                            icon: "clock.fill",
                            value: "\(store.totalFocusMinutes)",
                            label: "Minutes",
                            color: .cyan
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func toggleTimer() {
        isRunning.toggle()
        if isRunning {
            startTimer()
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        } else {
            timer?.invalidate()
            withAnimation {
                pulseScale = 1
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                isRunning = false
                store.completedPomodoros += 1
                store.focusStreak += 1
                store.totalFocusMinutes += selectedDuration / 60
                withAnimation {
                    pulseScale = 1
                }
            }
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        isRunning = false
        timeRemaining = selectedDuration
        rotationAngle = 0
        withAnimation {
            pulseScale = 1
        }
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                )
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.15))
        )
    }
}

struct AchievementsView: View {
    @EnvironmentObject var store: AppStore
    @State private var animateAchievements = false
    
    var achievements: [Achievement] {
        [
            Achievement(
                id: "first_task",
                title: "First Step",
                description: "Complete your first task",
                icon: "star.fill",
                color: .yellow,
                isUnlocked: store.tasks.filter { $0.isCompleted }.count >= 1,
                progress: min(Double(store.tasks.filter { $0.isCompleted }.count), 1.0)
            ),
            Achievement(
                id: "task_master",
                title: "Task Master",
                description: "Complete 10 tasks",
                icon: "crown.fill",
                color: .orange,
                isUnlocked: store.tasks.filter { $0.isCompleted }.count >= 10,
                progress: min(Double(store.tasks.filter { $0.isCompleted }.count) / 10.0, 1.0)
            ),
            Achievement(
                id: "team_player",
                title: "Team Player",
                description: "Share 5 tasks with team",
                icon: "person.3.fill",
                color: .green,
                isUnlocked: store.tasks.filter { !$0.sharedWith.isEmpty }.count >= 5,
                progress: min(Double(store.tasks.filter { !$0.sharedWith.isEmpty }.count) / 5.0, 1.0)
            ),
            Achievement(
                id: "focus_ninja",
                title: "Focus Ninja",
                description: "Complete 10 focus sessions",
                icon: "bolt.fill",
                color: .cyan,
                isUnlocked: store.completedPomodoros >= 10,
                progress: min(Double(store.completedPomodoros) / 10.0, 1.0)
            ),
            Achievement(
                id: "week_warrior",
                title: "Week Warrior",
                description: "Maintain 7-day streak",
                icon: "flame.fill",
                color: .red,
                isUnlocked: store.focusStreak >= 7,
                progress: min(Double(store.focusStreak) / 7.0, 1.0)
            ),
            Achievement(
                id: "productivity_pro",
                title: "Productivity Pro",
                description: "Accumulate 500 focus minutes",
                icon: "timer",
                color: .purple,
                isUnlocked: store.totalFocusMinutes >= 500,
                progress: min(Double(store.totalFocusMinutes) / 500.0, 1.0)
            ),
            Achievement(
                id: "matrix_master",
                title: "Matrix Master",
                description: "Use Eisenhower Matrix 20 times",
                icon: "square.grid.2x2.fill",
                color: .pink,
                isUnlocked: store.tasks.count >= 20,
                progress: min(Double(store.tasks.count) / 20.0, 1.0)
            ),
            Achievement(
                id: "organizer",
                title: "Super Organizer",
                description: "Use all 5 categories",
                icon: "folder.fill",
                color: .indigo,
                isUnlocked: store.usedCategories.count >= 5,
                progress: min(Double(store.usedCategories.count) / 5.0, 1.0)
            )
        ]
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Achievements")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, .yellow], startPoint: .leading, endPoint: .trailing)
                        )
                    
                    Text("\(unlockedCount) of \(achievements.count) unlocked")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Progress")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                            .frame(width: 140, height: 140)
                        
                        Circle()
                            .trim(from: 0, to: animateAchievements ? Double(unlockedCount) / Double(achievements.count) : 0)
                            .stroke(
                                LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round)
                            )
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 1.5, dampingFraction: 0.7), value: animateAchievements)
                        
                        VStack(spacing: 4) {
                            Text("\(Int((Double(unlockedCount) / Double(achievements.count)) * 100))%")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("Complete")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.yellow.opacity(0.15), .orange.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .padding(.horizontal, 20)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(Array(achievements.enumerated()), id: \.element.id) { index, achievement in
                        AchievementCard(achievement: achievement)
                            .scaleEffect(animateAchievements ? 1 : 0.5)
                            .opacity(animateAchievements ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1), value: animateAchievements)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            withAnimation {
                animateAchievements = true
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @State private var showDetail = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: achievement.isUnlocked ?
                            [achievement.color, achievement.color.opacity(0.6)] :
                                [.gray.opacity(0.3), .gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: achievement.isUnlocked ? achievement.color.opacity(0.5) : .clear, radius: 10)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .opacity(achievement.isUnlocked ? 1 : 0.3)
                
                if !achievement.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .offset(x: 20, y: 20)
                }
            }
            
            Text(achievement.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            if !achievement.isUnlocked {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(achievement.color)
                            .frame(width: geometry.size.width * achievement.progress, height: 4)
                    }
                }
                .frame(height: 4)
                
                Text("\(Int(achievement.progress * 100))%")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            } else {
                Text("Unlocked! 🎉")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(achievement.color)
            }
        }
        .padding(16)
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [achievement.color.opacity(0.15), achievement.color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(achievement.isUnlocked ? achievement.color.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            showDetail.toggle()
        }
        .alert(achievement.title, isPresented: $showDetail) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(achievement.description)
        }
    }
}

// MARK: - Learning Components

struct LessonCard: View {
    let lesson: Lesson
    let isCompleted: Bool
    let isLocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        isLocked ? AnyShapeStyle(Color.gray.opacity(0.3)) :
                            AnyShapeStyle(LinearGradient(
                                colors: [lesson.color.color, lesson.color.color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    )
                    .frame(width: 60, height: 60)
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                } else if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    Image(systemName: lesson.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(lesson.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isLocked ? .gray : .white)
                
                Text(lesson.description)
                    .font(.system(size: 13))
                    .foregroundColor(isLocked ? .gray.opacity(0.6) : .gray)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                    Text("\(lesson.duration) min")
                        .font(.system(size: 12))
                    
                    if lesson.difficulty != .beginner {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text(lesson.difficulty.rawValue)
                            .font(.system(size: 12))
                    }
                }
                .foregroundColor(isLocked ? .gray.opacity(0.6) : .orange)
            }
            
            Spacer()
            
            if !isLocked {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isLocked ? AnyShapeStyle(Color.gray.opacity(0.1)) :
                        AnyShapeStyle(LinearGradient(
                            colors: [lesson.color.color.opacity(0.2), lesson.color.color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? Color.green : Color.clear, lineWidth: 2)
        )
        .opacity(isLocked ? 0.6 : 1)
    }
}

struct LessonDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let lesson: Lesson
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, lesson.color.color],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("Lesson \(lesson.order)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                TabView(selection: $currentPage) {
                    ForEach(Array(lesson.content.enumerated()), id: \.offset) { index, content in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                Image(systemName: lesson.icon)
                                    .font(.system(size: 60))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [lesson.color.color, lesson.color.color],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom, 16)
                                
                                Text(lesson.title)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(content)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(8)
                                
                                if index == lesson.content.count - 1 {
                                    Button {
                                        store.completeLesson(lesson.id.uuidString)
                                        dismiss()
                                    } label: {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text("Complete Lesson")
                                        }
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                colors: [.green, .mint],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                    }
                                    .padding(.top, 16)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
        }
    }
}

struct TestCard: View {
    let test: CourseTest
    let isPassed: Bool
    let bestScore: Int
    let isLocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isLocked ? AnyShapeStyle(Color.gray.opacity(0.3)) :
                            AnyShapeStyle(LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    )
                    .frame(width: 60, height: 60)
                
                if isPassed {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                } else if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(test.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isLocked ? .gray : .white)
                
                Text("\(test.questions.count) questions")
                    .font(.system(size: 13))
                    .foregroundColor(isLocked ? .gray.opacity(0.6) : .gray)
                
                if isPassed {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("Best: \(bestScore)%")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.green)
                } else if !isLocked {
                    Text("Passing score: \(test.passingScore)%")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            if !isLocked {
                Image(systemName: isPassed ? "arrow.clockwise" : "chevron.right")
                    .foregroundColor(isPassed ? .green : .gray)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isLocked ? Color.gray.opacity(0.1) :
                    Color.orange.opacity(0.15)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPassed ? Color.green : Color.clear, lineWidth: 2)
        )
        .opacity(isLocked ? 0.6 : 1)
    }
}

struct TestView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let test: CourseTest
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int: Int] = [:]
    @State private var showResults = false
    @State private var score = 0
    
    var currentQuestion: TestQuestion {
        test.questions[currentQuestionIndex]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .orange.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(currentQuestionIndex + 1) / \(test.questions.count)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                if !showResults {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * CGFloat(currentQuestionIndex + 1) / CGFloat(test.questions.count),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text(currentQuestion.question)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                                    Button {
                                        selectedAnswers[currentQuestionIndex] = index
                                    } label: {
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedAnswers[currentQuestionIndex] == index ? Color.orange : Color.gray.opacity(0.3))
                                                    .frame(width: 32, height: 32)
                                                
                                                if selectedAnswers[currentQuestionIndex] == index {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            
                                            Text(option)
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                        }
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    selectedAnswers[currentQuestionIndex] == index ?
                                                    Color.orange.opacity(0.2) :
                                                    Color.white.opacity(0.05)
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    selectedAnswers[currentQuestionIndex] == index ?
                                                    Color.orange : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    
                    VStack(spacing: 12) {
                        if currentQuestionIndex < test.questions.count - 1 {
                            Button {
                                withAnimation {
                                    currentQuestionIndex += 1
                                }
                            } label: {
                                HStack {
                                    Text("Next Question")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            }
                            .disabled(selectedAnswers[currentQuestionIndex] == nil)
                            .opacity(selectedAnswers[currentQuestionIndex] == nil ? 0.5 : 1)
                        } else {
                            Button {
                                calculateScore()
                                showResults = true
                            } label: {
                                HStack {
                                    Text("Finish Test")
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            }
                            .disabled(selectedAnswers[currentQuestionIndex] == nil)
                            .opacity(selectedAnswers[currentQuestionIndex] == nil ? 0.5 : 1)
                        }
                        
                        if currentQuestionIndex > 0 {
                            Button {
                                withAnimation {
                                    currentQuestionIndex -= 1
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.left")
                                    Text("Previous")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(
                            colors: [.black.opacity(0.9), .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                } else {
                    // Results View
                    ScrollView {
                        VStack(spacing: 32) {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                        .frame(width: 200, height: 200)
                                    
                                    Circle()
                                        .trim(from: 0, to: CGFloat(score) / 100.0)
                                        .stroke(
                                            LinearGradient(
                                                colors: score >= test.passingScore ? [.green, .mint] : [.orange, .red],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                        )
                                        .frame(width: 200, height: 200)
                                        .rotationEffect(.degrees(-90))
                                    
                                    VStack(spacing: 8) {
                                        Text("\(score)%")
                                            .font(.system(size: 54, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text(score >= test.passingScore ? "Passed!" : "Not Passed")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(score >= test.passingScore ? .green : .red)
                                    }
                                }
                                
                                if score >= test.passingScore {
                                    HStack(spacing: 8) {
                                        Image(systemName: "party.popper.fill")
                                        Text("Congratulations!")
                                        Image(systemName: "party.popper.fill")
                                    }
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                } else {
                                    Text("Keep learning and try again!")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            VStack(spacing: 16) {
                                ResultRow(
                                    icon: "checkmark.circle.fill",
                                    title: "Correct Answers",
                                    value: "\(correctAnswersCount) / \(test.questions.count)",
                                    color: .green
                                )
                                
                                ResultRow(
                                    icon: "xmark.circle.fill",
                                    title: "Wrong Answers",
                                    value: "\(test.questions.count - correctAnswersCount)",
                                    color: .red
                                )
                                
                                ResultRow(
                                    icon: "target",
                                    title: "Passing Score",
                                    value: "\(test.passingScore)%",
                                    color: .orange
                                )
                            }
                            
                            VStack(spacing: 12) {
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Done")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                colors: [.cyan, .blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                }
                                
                                if score < test.passingScore {
                                    Button {
                                        currentQuestionIndex = 0
                                        selectedAnswers = [:]
                                        showResults = false
                                        score = 0
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Try Again")
                                        }
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 32)
                    }
                }
            }
        }
    }
    
    var correctAnswersCount: Int {
        var count = 0
        for (index, question) in test.questions.enumerated() {
            if selectedAnswers[index] == question.correctAnswer {
                count += 1
            }
        }
        return count
    }
    
    func calculateScore() {
        let correct = correctAnswersCount
        score = Int((Double(correct) / Double(test.questions.count)) * 100)
        
        if score >= test.passingScore {
            store.passTest(test.id.uuidString, score: score)
        }
    }
}

struct ResultRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Models

struct Lesson: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let color: CodableColor
    let duration: Int
    let difficulty: LessonDifficulty
    let order: Int
    let content: [String]
    let requiredLessonId: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        icon: String,
        color: Color,
        duration: Int,
        difficulty: LessonDifficulty = .beginner,
        order: Int,
        content: [String],
        requiredLessonId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.color = CodableColor(color: color)
        self.duration = duration
        self.difficulty = difficulty
        self.order = order
        self.content = content
        self.requiredLessonId = requiredLessonId
    }
}

enum LessonDifficulty: String, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct CourseTest: Identifiable, Codable {
    let id: UUID
    let title: String
    let questions: [TestQuestion]
    let passingScore: Int
    let requiredLessonId: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        questions: [TestQuestion],
        passingScore: Int = 70,
        requiredLessonId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.questions = questions
        self.passingScore = passingScore
        self.requiredLessonId = requiredLessonId
    }
}

struct TestQuestion: Identifiable, Codable {
    let id: UUID
    let question: String
    let options: [String]
    let correctAnswer: Int
    
    init(
        id: UUID = UUID(),
        question: String,
        options: [String],
        correctAnswer: Int
    ) {
        self.id = id
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
    }
}

class AppStore: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var notes: [Note] = []
    @Published var completedPomodoros: Int = 0
    @Published var focusStreak: Int = 0
    @Published var totalFocusMinutes: Int = 0
    @Published var showSplash = true
    @Published var teamMembers: [TeamMember] = []
    @Published var lessons: [Lesson] = []
    @Published var completedLessons: [String] = []
    @Published var tests: [CourseTest] = []
    @Published var passedTests: [String] = []
    @Published var testScores: [String: Int] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    var hasEarlyMorningTask: Bool {
        tasks.filter { task in
            task.isCompleted &&
            Calendar.current.component(.hour, from: task.date) < 9
        }.count > 0
    }
    
    var usedCategories: Set<String> {
        Set(tasks.map { $0.category })
    }
    
    var courseProgress: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessons.count) / Double(lessons.count)
    }
    
    func isLessonUnlocked(_ lesson: Lesson) -> Bool {
        guard let requiredId = lesson.requiredLessonId else { return true }
        return completedLessons.contains(requiredId)
    }
    
    func isTestUnlocked(_ test: CourseTest) -> Bool {
        guard let requiredId = test.requiredLessonId else { return true }
        return completedLessons.contains(requiredId)
    }
    
    func completeLesson(_ lessonId: String) {
        if !completedLessons.contains(lessonId) {
            completedLessons.append(lessonId)
        }
    }
    
    func passTest(_ testId: String, score: Int) {
        if !passedTests.contains(testId) {
            passedTests.append(testId)
        }
        
        if let currentScore = testScores[testId] {
            if score > currentScore {
                testScores[testId] = score
            }
        } else {
            testScores[testId] = score
        }
    }
    
    init() {
        loadData()
        setupSubscriptions()
        loadTempData()
    }
    
    func setupSubscriptions() {
        $tasks
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] tasks in
                self?.saveTasks(tasks)
            }
            .store(in: &cancellables)
        
        $notes
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] notes in
                self?.saveNotes(notes)
            }
            .store(in: &cancellables)
        
        $completedPomodoros
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] count in
                UserDefaults.standard.set(count, forKey: "completedPomodoros")
            }
            .store(in: &cancellables)
        
        $focusStreak
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] count in
                UserDefaults.standard.set(count, forKey: "focusStreak")
            }
            .store(in: &cancellables)
        
        $totalFocusMinutes
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] count in
                UserDefaults.standard.set(count, forKey: "totalFocusMinutes")
            }
            .store(in: &cancellables)
        
        $teamMembers
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] members in
                self?.saveTeamMembers(members)
            }
            .store(in: &cancellables)
        
        $completedLessons
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] lessons in
                UserDefaults.standard.set(lessons, forKey: "completedLessons")
            }
            .store(in: &cancellables)
        
        $passedTests
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] tests in
                UserDefaults.standard.set(tests, forKey: "passedTests")
            }
            .store(in: &cancellables)
        
        $testScores
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] scores in
                if let encoded = try? JSONEncoder().encode(scores) {
                    UserDefaults.standard.set(encoded, forKey: "testScores")
                }
            }
            .store(in: &cancellables)
    }
    
    func loadData() {
        if let tasksData = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            tasks = decodedTasks
        }
        
        if let notesData = UserDefaults.standard.data(forKey: "notes"),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: notesData) {
            notes = decodedNotes
        }
        
        if let membersData = UserDefaults.standard.data(forKey: "teamMembers"),
           let decodedMembers = try? JSONDecoder().decode([TeamMember].self, from: membersData) {
            teamMembers = decodedMembers
        }
        
        completedPomodoros = UserDefaults.standard.integer(forKey: "completedPomodoros")
        focusStreak = UserDefaults.standard.integer(forKey: "focusStreak")
        totalFocusMinutes = UserDefaults.standard.integer(forKey: "totalFocusMinutes")
        
        completedLessons = UserDefaults.standard.stringArray(forKey: "completedLessons") ?? []
        passedTests = UserDefaults.standard.stringArray(forKey: "passedTests") ?? []
        
        if let scoresData = UserDefaults.standard.data(forKey: "testScores"),
           let decodedScores = try? JSONDecoder().decode([String: Int].self, from: scoresData) {
            testScores = decodedScores
        }
    }
    
    func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    func saveNotes(_ notes: [Note]) {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "notes")
        }
    }
    
    func saveTeamMembers(_ members: [TeamMember]) {
        if let encoded = try? JSONEncoder().encode(members) {
            UserDefaults.standard.set(encoded, forKey: "teamMembers")
        }
    }
    
    func addTask(title: String, priority: Priority = .medium, category: String = "Work", dueDate: Date = Date(), quadrant: EisenhowerQuadrant = .urgentImportant) {
        let task = Task(title: title, priority: priority, category: category, dueDate: dueDate, quadrant: quadrant)
        tasks.insert(task, at: 0)
    }
    
    func toggleTask(id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
    }
    
    func archiveTask(id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isArchived = true
        }
    }
    
    func updateTask(id: UUID, title: String, priority: Priority, category: String, dueDate: Date) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].title = title
            tasks[index].priority = priority
            tasks[index].category = category
            tasks[index].dueDate = dueDate
        }
    }
    
    func updateTaskQuadrant(id: UUID, quadrant: EisenhowerQuadrant) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].quadrant = quadrant
            tasks[index].priority = quadrant.defaultPriority
        }
    }
    
    func shareTask(id: UUID, with members: [String]) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].sharedWith = members
        }
    }
    
    func addNote(title: String, content: String, category: String = "Work") {
        let note = Note(title: title, content: content, category: category)
        notes.insert(note, at: 0)
    }
    
    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
    }
    
    func updateNote(id: UUID, title: String, content: String, category: String) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].title = title
            notes[index].content = content
            notes[index].category = category
        }
    }
    
    func addTeamMember(_ member: TeamMember) {
        teamMembers.append(member)
    }
    
    func clearAllTasks() {
        tasks.removeAll()
    }
    
    func clearAllNotes() {
        notes.removeAll()
    }
    
    func resetStatistics() {
        completedPomodoros = 0
        focusStreak = 0
        totalFocusMinutes = 0
    }
    
    func resetAchievements() {
        resetStatistics()
    }
    
    func loadTempData() {
        if tasks.isEmpty {
            tasks = [
                Task(title: "Review quarterly reports", priority: .high, category: "Work", isCompleted: true, quadrant: .urgentImportant),
                Task(title: "Prepare presentation slides", priority: .high, category: "Work", isCompleted: false, dueDate: Date().addingTimeInterval(3600), quadrant: .urgentImportant),
                Task(title: "Team meeting at 2 PM", priority: .medium, category: "Work", isCompleted: false, dueDate: Date().addingTimeInterval(7200), quadrant: .urgentNotImportant),
                Task(title: "Strategic planning", priority: .high, category: "Work", isCompleted: false, dueDate: Date().addingTimeInterval(86400), quadrant: .notUrgentImportant),
                Task(title: "Email responses", priority: .low, category: "Work", isCompleted: false, quadrant: .urgentNotImportant),
                Task(title: "Learn new skills", priority: .medium, category: "Study", isCompleted: false, quadrant: .notUrgentImportant),
                Task(title: "Social media check", priority: .low, category: "Personal", isCompleted: false, quadrant: .notUrgentNotImportant),
                Task(title: "Workout session", priority: .high, category: "Health", isCompleted: true, quadrant: .notUrgentImportant)
            ]
        }
        
        if notes.isEmpty {
            notes = [
                Note(title: "Meeting Notes - Q1 Planning", content: "Discussed Q1 objectives and team allocation. Key points:\n- Increase productivity by 20%\n- New project timeline\n- Budget allocation", category: "Meeting"),
                Note(title: "Project Ideas", content: "Brainstorming session outcomes:\n\n1. Automated reporting system\n2. Team collaboration tools\n3. Client portal improvements", category: "Ideas"),
                Note(title: "Learning Resources", content: "Topics to study:\n- SwiftUI advanced patterns\n- Combine framework\n- iOS performance optimization", category: "Study")
            ]
        }
        
        if teamMembers.isEmpty {
            teamMembers = [
                TeamMember(name: "Sarah Johnson", email: "sarah@company.com", role: "Team Lead", color: .purple, isOnline: true),
                TeamMember(name: "Mike Chen", email: "mike@company.com", role: "Developer", color: .blue, isOnline: true),
                TeamMember(name: "Emma Davis", email: "emma@company.com", role: "Designer", color: .pink, isOnline: false),
                TeamMember(name: "Alex Smith", email: "alex@company.com", role: "Manager", color: .green, isOnline: true)
            ]
        }
        
        if completedPomodoros == 0 {
            completedPomodoros = 12
            focusStreak = 5
            totalFocusMinutes = 300
        }
        
        if lessons.isEmpty {
            let lesson1 = Lesson(
                title: "Introduction to Productivity",
                description: "Learn the fundamentals of productivity and time management",
                icon: "book.fill",
                color: .blue,
                duration: 10,
                difficulty: .beginner,
                order: 1,
                content: [
                    "Welcome to the Productivity Master Course! In this lesson, you'll learn the core principles of effective productivity.",
                    "Productivity isn't about doing more things—it's about doing the right things effectively. The key is prioritization and focus.",
                    "Throughout this course, you'll learn proven techniques used by successful professionals worldwide.",
                    "Remember: Small, consistent actions lead to remarkable results over time. Let's get started!"
                ]
            )
            
            let lesson2 = Lesson(
                title: "The Eisenhower Matrix",
                description: "Master the art of prioritization using the Eisenhower Matrix",
                icon: "square.grid.2x2.fill",
                color: .purple,
                duration: 15,
                difficulty: .beginner,
                order: 2,
                content: [
                    "The Eisenhower Matrix is a powerful tool for prioritizing tasks based on urgency and importance.",
                    "Urgent & Important: Do these tasks immediately. They're critical and time-sensitive.",
                    "Not Urgent & Important: Schedule these tasks. They're crucial for long-term success.",
                    "Urgent & Not Important: Delegate these if possible. They're interruptions that don't contribute to your goals.",
                    "Not Urgent & Not Important: Eliminate these time-wasters. They provide little to no value."
                ],
                requiredLessonId: lesson1.id.uuidString
            )
            
            let lesson3 = Lesson(
                title: "Pomodoro Technique",
                description: "Use focused time blocks to maximize your concentration",
                icon: "timer",
                color: .orange,
                duration: 12,
                difficulty: .intermediate,
                order: 3,
                content: [
                    "The Pomodoro Technique is a time management method that uses focused 25-minute work sessions.",
                    "How it works: Work for 25 minutes with complete focus, then take a 5-minute break.",
                    "After 4 pomodoros, take a longer break of 15-30 minutes to recharge.",
                    "This technique leverages your brain's natural attention span and prevents burnout.",
                    "The key is avoiding all distractions during your focused work periods."
                ],
                requiredLessonId: lesson2.id.uuidString
            )
            
            let lesson4 = Lesson(
                title: "Team Collaboration",
                description: "Learn effective strategies for working with teams",
                icon: "person.3.fill",
                color: .green,
                duration: 18,
                difficulty: .intermediate,
                order: 4,
                content: [
                    "Effective team collaboration multiplies individual productivity and creates synergy.",
                    "Clear Communication: Always communicate expectations, deadlines, and progress clearly.",
                    "Shared Goals: Ensure everyone understands and works toward common objectives.",
                    "Regular Check-ins: Schedule consistent meetings to stay aligned and address blockers.",
                    "Use collaboration tools effectively to streamline workflows and reduce miscommunication."
                ],
                requiredLessonId: lesson3.id.uuidString
            )
            
            let lesson5 = Lesson(
                title: "Advanced Analytics",
                description: "Track and optimize your performance using data",
                icon: "chart.bar.fill",
                color: .cyan,
                duration: 20,
                difficulty: .advanced,
                order: 5,
                content: [
                    "What gets measured gets improved. Analytics help you understand your productivity patterns.",
                    "Track key metrics: completion rate, focus time, task distribution, and productivity trends.",
                    "Identify your peak performance hours and schedule important work during those times.",
                    "Use data to spot bottlenecks and areas for improvement in your workflow.",
                    "Regular review of your analytics leads to continuous improvement and better outcomes."
                ],
                requiredLessonId: lesson4.id.uuidString
            )
            
            lessons = [lesson1, lesson2, lesson3, lesson4, lesson5]
        }
        
        if tests.isEmpty {
            let test1 = CourseTest(
                title: "Productivity Fundamentals",
                questions: [
                    TestQuestion(
                        question: "What is the primary goal of productivity?",
                        options: [
                            "Doing more tasks in less time",
                            "Doing the right things effectively",
                            "Working longer hours",
                            "Multitasking efficiently"
                        ],
                        correctAnswer: 1
                    ),
                    TestQuestion(
                        question: "Which quadrant of the Eisenhower Matrix should you focus on first?",
                        options: [
                            "Not Urgent & Not Important",
                            "Urgent & Not Important",
                            "Not Urgent & Important",
                            "Urgent & Important"
                        ],
                        correctAnswer: 3
                    ),
                    TestQuestion(
                        question: "What should you do with tasks that are Not Urgent & Not Important?",
                        options: [
                            "Do them immediately",
                            "Schedule them",
                            "Delegate them",
                            "Eliminate them"
                        ],
                        correctAnswer: 3
                    ),
                    TestQuestion(
                        question: "How does consistent small action lead to results?",
                        options: [
                            "It doesn't, only big actions matter",
                            "Through compound effect over time",
                            "By working faster",
                            "By multitasking"
                        ],
                        correctAnswer: 1
                    ),
                    TestQuestion(
                        question: "What is the best approach to task prioritization?",
                        options: [
                            "First come, first served",
                            "Based on urgency and importance",
                            "Random selection",
                            "Easiest tasks first"
                        ],
                        correctAnswer: 1
                    )
                ],
                passingScore: 80,
                requiredLessonId: lessons.first?.id.uuidString
            )
            
            let test2 = CourseTest(
                title: "Time Management Mastery",
                questions: [
                    TestQuestion(
                        question: "How long is a standard Pomodoro work session?",
                        options: [
                            "15 minutes",
                            "20 minutes",
                            "25 minutes",
                            "30 minutes"
                        ],
                        correctAnswer: 2
                    ),
                    TestQuestion(
                        question: "After how many Pomodoros should you take a long break?",
                        options: [
                            "2 Pomodoros",
                            "3 Pomodoros",
                            "4 Pomodoros",
                            "5 Pomodoros"
                        ],
                        correctAnswer: 2
                    ),
                    TestQuestion(
                        question: "What is the main benefit of the Pomodoro Technique?",
                        options: [
                            "Working longer hours",
                            "Doing more tasks",
                            "Maintaining focus and preventing burnout",
                            "Eliminating all breaks"
                        ],
                        correctAnswer: 2
                    ),
                    TestQuestion(
                        question: "How should you handle distractions during a Pomodoro?",
                        options: [
                            "Deal with them immediately",
                            "Avoid them completely",
                            "Multitask",
                            "Pause the timer"
                        ],
                        correctAnswer: 1
                    ),
                    TestQuestion(
                        question: "What is the ideal length for a short break between Pomodoros?",
                        options: [
                            "2 minutes",
                            "5 minutes",
                            "10 minutes",
                            "15 minutes"
                        ],
                        correctAnswer: 1
                    )
                ],
                passingScore: 70,
                requiredLessonId: lessons.count > 2 ? lessons[2].id.uuidString : nil
            )
            
            let test3 = CourseTest(
                title: "Advanced Productivity",
                questions: [
                    TestQuestion(
                        question: "What is the most important aspect of team collaboration?",
                        options: [
                            "Having many meetings",
                            "Clear communication",
                            "Working independently",
                            "Avoiding conflicts"
                        ],
                        correctAnswer: 1
                    ),
                    TestQuestion(
                        question: "Why is tracking productivity metrics important?",
                        options: [
                            "To punish poor performance",
                            "To compare with others",
                            "To identify patterns and improve",
                            "It's not important"
                        ],
                        correctAnswer: 2
                    ),
                    TestQuestion(
                        question: "When should you schedule your most important tasks?",
                        options: [
                            "At the end of the day",
                            "During your peak performance hours",
                            "During lunch break",
                            "Late at night"
                        ],
                        correctAnswer: 1
                    ),
                    TestQuestion(
                        question: "What leads to continuous improvement in productivity?",
                        options: [
                            "Working more hours",
                            "Regular review and adjustment",
                            "Following the same routine",
                            "Avoiding change"
                        ],
                        correctAnswer: 1
                    ),
                    TestQuestion(
                        question: "What is the purpose of shared goals in team work?",
                        options: [
                            "To create competition",
                            "To ensure alignment and common purpose",
                            "To assign blame",
                            "To reduce workload"
                        ],
                        correctAnswer: 1
                    )
                ],
                passingScore: 75,
                requiredLessonId: lessons.count > 4 ? lessons[4].id.uuidString : nil
            )
            
            tests = [test1, test2, test3]
        }
    }
}

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var date: Date
    var priority: Priority
    var category: String
    var dueDate: Date
    var isArchived: Bool
    var quadrant: EisenhowerQuadrant
    var sharedWith: [String]
    
    var isOverdue: Bool {
        dueDate < Date() && !isCompleted
    }
    
    var eisenhowerQuadrant: EisenhowerQuadrant {
        quadrant
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        priority: Priority = .medium,
        category: String = "Work",
        isCompleted: Bool = false,
        date: Date = Date(),
        dueDate: Date = Date().addingTimeInterval(86400),
        isArchived: Bool = false,
        quadrant: EisenhowerQuadrant = .urgentImportant,
        sharedWith: [String] = []
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.category = category
        self.isCompleted = isCompleted
        self.date = date
        self.dueDate = dueDate
        self.isArchived = isArchived
        self.quadrant = quadrant
        self.sharedWith = sharedWith
    }
}

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var category: String
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        category: String = "Work",
        date: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.date = date
    }
}

struct TeamMember: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var role: String
    var color: CodableColor
    var isOnline: Bool
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
        return firstInitial + lastInitial
    }
    
    init(id: UUID = UUID(), name: String, email: String, role: String, color: Color, isOnline: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.color = CodableColor(color: color)
        self.isOnline = isOnline
    }
}

struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

enum Priority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var icon: String {
        switch self {
            case .low: return "🟢"
            case .medium: return "🟡"
            case .high: return "🔴"
        }
    }
    
    var color: Color {
        switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .red
        }
    }
}

enum TaskFilter: CaseIterable {
    case all
    case active
    case completed
    case highPriority
    case today
    
    var title: String {
        switch self {
            case .all: return "All"
            case .active: return "Active"
            case .completed: return "Completed"
            case .highPriority: return "High Priority"
            case .today: return "Today"
        }
    }
}

enum EisenhowerQuadrant: String, Codable, CaseIterable {
    case urgentImportant = "Urgent & Important"
    case notUrgentImportant = "Not Urgent & Important"
    case urgentNotImportant = "Urgent & Not Important"
    case notUrgentNotImportant = "Not Urgent & Not Important"
    
    var title: String {
        switch self {
            case .urgentImportant: return "Do First"
            case .notUrgentImportant: return "Schedule"
            case .urgentNotImportant: return "Delegate"
            case .notUrgentNotImportant: return "Eliminate"
        }
    }
    
    var subtitle: String {
        switch self {
            case .urgentImportant: return "Critical tasks"
            case .notUrgentImportant: return "Plan ahead"
            case .urgentNotImportant: return "Interruptions"
            case .notUrgentNotImportant: return "Time wasters"
        }
    }
    
    var icon: String {
        switch self {
            case .urgentImportant: return "🔥"
            case .notUrgentImportant: return "📅"
            case .urgentNotImportant: return "👥"
            case .notUrgentNotImportant: return "🗑️"
        }
    }
    
    var color: Color {
        switch self {
            case .urgentImportant: return .red
            case .notUrgentImportant: return .blue
            case .urgentNotImportant: return .orange
            case .notUrgentNotImportant: return .gray
        }
    }
    
    var defaultPriority: Priority {
        switch self {
            case .urgentImportant: return .high
            case .notUrgentImportant: return .medium
            case .urgentNotImportant: return .medium
            case .notUrgentNotImportant: return .low
        }
    }
}

enum AnalyticsPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    let progress: Double
}

struct HeatmapDay: Identifiable {
    let id = UUID()
    let date: Date
    let intensity: Double
}

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var hasAccess = false
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.hasAccess = granted
            }
        }
    }
    
    func addEvent(title: String, date: Date) {
        guard hasAccess else { return }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = date
        event.endDate = date.addingTimeInterval(3600)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            print("Error saving event: \(error.localizedDescription)")
        }
    }
    
    func getUpcomingEvents() -> [EKEvent] {
        guard hasAccess else { return [] }
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        return eventStore.events(matching: predicate)
    }
}

class WeatherManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentWeather: WeatherData?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
            default:
                loadMockWeather()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        fetchWeather(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        loadMockWeather()
    }
    
    private func fetchWeather(for location: CLLocation) {
        loadMockWeather()
    }
    
    private func loadMockWeather() {
        let conditions = ["Clear", "Sunny", "Cloudy", "Rain", "Rainy"]
        let icons = ["sun.max.fill", "sun.max.fill", "cloud.fill", "cloud.rain.fill", "cloud.rain.fill"]
        let randomIndex = Int.random(in: 0..<conditions.count)
        
        DispatchQueue.main.async {
            self.currentWeather = WeatherData(
                temperature: Double.random(in: 15...30),
                condition: conditions[randomIndex],
                icon: icons[randomIndex],
                humidity: Int.random(in: 40...80),
                windSpeed: Double.random(in: 5...25)
            )
        }
    }
}

struct WeatherData {
    let temperature: Double
    let condition: String
    let icon: String
    let humidity: Int
    let windSpeed: Double
}
