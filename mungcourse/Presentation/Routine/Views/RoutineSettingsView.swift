import SwiftUI

struct RoutineSettingsView: View {
    var tabBarHeight: CGFloat
    @StateObject private var viewModel = RoutineViewModel()
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    @State private var showEditRoutine = false
    
    var body: some View {
        GeometryReader { fullProxy in
            let allRoutines: [Routine] = viewModel.routines
            let routines: [Routine] = allRoutines.filter { (routine: Routine) -> Bool in
                routine.days.contains(viewModel.selectedDay)
            }

            ZStack {
                Color("pointwhite").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 공통 헤더 (요일 선택 포함)
                    ZStack {
                        CommonHeaderView(leftIcon: nil, title: "루틴 설정") {
                            //Image("icon_calendar")
                            //    .onTapGesture {
                            //        showDatePicker = true
                            //    }
                        }
                    }
                    .padding(.top, 16)
                    .background(Color("pointwhite")) // 명시적으로 흰색 배경 지정
                    .shadow(color: Color("pointblack").opacity(0.1), radius: 5, x: 0, y: 2) // 그림자 적용
                    
                    RoutineDaySelector(selectedDay: $viewModel.selectedDay)
                    
                    // 루틴 리스트
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            if routines.isEmpty {
                                EmptyRoutineView()
                            } else {
                                ForEach(Array(routines.indices), id: \Int.self) { index in
                                    let routine = routines[index]
                                    RoutineListItem(
                                        routine: routine,
                                        onToggle: { viewModel.toggleRoutineCompletion(routine: routine) },
                                        onEdit: {
                                            viewModel.editingRoutine = routine
                                        },
                                        onDelete: {
                                            viewModel.deleteRoutine(routine)
                                        }
                                    )
                                    if index < viewModel.routines.count - 1 {
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, tabBarHeight)
                    .onAppear {
                        print("[RoutineSettingsView] fullProxy.safeAreaInsets.bottom: \(fullProxy.safeAreaInsets.bottom)")
                        print("[RoutineSettingsView] tabBarHeight: \(tabBarHeight)")
                    }
                    
                    Spacer()
                }
                
                // 루틴 추가 버튼 (플로팅 버튼)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RoutineAddButton(action: {
                            viewModel.showAddRoutine = true
                        })
                        Spacer()
                    }
                    .padding(.bottom, 90)
                }
            }
            .onAppear {
                print("[RoutineSettingsView] ZStack appeared with fullProxy.safeAreaInsets.bottom: \(fullProxy.safeAreaInsets.bottom), tabBarHeight: \(tabBarHeight)")
            }
        }
        .sheet(isPresented: $viewModel.showAddRoutine) {
            AddRoutineView(onAdd: {
                viewModel.showAddRoutine = false
                viewModel.fetchRoutines(for: viewModel.selectedDay)
            })
            .presentationDetents([.height(435)])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.editingRoutine) { routine in
            EditRoutineView(routine: routine) {
                viewModel.fetchRoutines(for: viewModel.selectedDay)
            }
        }
        .sheet(isPresented: $showDatePicker) {
            CommonDatePickerSheet(selection: $selectedDate) {
                showDatePicker = false
            } onDismiss: {
                showDatePicker = false
            }
        }
    }
}

#Preview {
    RoutineSettingsView(tabBarHeight: 0)
}
