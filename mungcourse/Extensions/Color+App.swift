//
//  Color+App.swift
//  mungcourse
//
//  프로젝트 전역에서 사용할 커스텀 컬러 시스템을 정의합니다.
//

import SwiftUI

extension Color {
    // MARK: - Gray Scale
    static let gray900 = Color(red: 61/255, green: 61/255, blue: 61/255)
    static let gray800 = Color(red: 68/255, green: 68/255, blue: 68/255)
    static let gray700 = Color(red: 128/255, green: 128/255, blue: 128/255)
    static let gray600 = Color(red: 158/255, green: 158/255, blue: 158/255)
    static let gray500 = Color(red: 180/255, green: 180/255, blue: 180/255)
    static let gray400 = Color(red: 217/255, green: 217/255, blue: 217/255)
    static let gray300 = Color(red: 240/255, green: 240/255, blue: 240/255)
    static let gray200 = Color(red: 242/255, green: 242/255, blue: 242/255)
    static let gray100 = Color(red: 250/255, green: 250/255, blue: 250/255)

    // MARK: - Static
    static let black = Color(red: 0/255, green: 0/255, blue: 0/255)
    static let white = Color(red: 255/255, green: 255/255, blue: 255/255)

    // MARK: - Main
    static let main = Color(red: 38/255, green: 192/255, blue: 0/255)

    // MARK: - Gradation
    static let main50 = main.opacity(0.5)
    static let main25 = main.opacity(0.25)
    static let black50 = Color.black.opacity(0.5)
    static let black20 = Color.black.opacity(0.2)
    static let black10 = Color.black.opacity(0.1)
    static let white50 = Color.white.opacity(0.5)
    static let white25 = Color.white.opacity(0.25)

    // MARK: - Point
    static let pointRed = Color(red: 238/255, green: 49/255, blue: 30/255)
    static let pointYellow = Color(red: 255/255, green: 232/255, blue: 9/255)
} 