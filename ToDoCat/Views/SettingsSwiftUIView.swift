//
//  SettingsSwiftUIView.swift
//  ToDoCat
//
//  Created by 서준일 on 5/21/25.
//

import SwiftUI

struct SettingsSwiftUIView: View {
    @ObservedObject var viewModel: SettingsViewModelAdapter
    @State private var showingResetAlert = false
    @State private var showingToast = false
    
    var body: some View {
        List {
            // 첫 번째 섹션 - 서비스
            Section(header: Text("서비스")) {
                Button("데이터 초기화") {
                    showingResetAlert = true
                }
                .foregroundColor(Color("TextColor"))
                
                Button("리뷰 남기기") {
                    viewModel.reviewButtonTapped()
                }
                .foregroundColor(Color("TextColor"))
                
                Button("문의하기") {
                    viewModel.mailButtonTapped()
                }
                .foregroundColor(Color("TextColor"))
            }
            
            // 두 번째 섹션 - 정보
            Section(header: Text("정보")) {
                Button("오픈소스 라이브러리") {
                    viewModel.openLicensesButtonTapped()
                }
                .foregroundColor(Color("TextColor"))
                
                HStack {
                    Text("버전")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundColor(Color("TextColor"))
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("설정")
        .alert("데이터 초기화", isPresented: $showingResetAlert) {
            Button("취소", role: .cancel) { }
            Button("확인", role: .destructive) {
                viewModel.resetConfirmed()
            }
        } message: {
            Text("데이터 초기화 시 기존 데이터는 전부 사라집니다. 데이터 초기화를 진행할까요?")
        }
        .alert(viewModel.toastMessage, isPresented: $showingToast) {
            Button("확인", role: .cancel) { }
        }
        .onReceive(viewModel.$showingToast) { showToast in
            if showToast {
                showingToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.showingToast = false
                }
            }
        }
    }
}

#Preview {
    //SettingsSwiftUIView()
}
