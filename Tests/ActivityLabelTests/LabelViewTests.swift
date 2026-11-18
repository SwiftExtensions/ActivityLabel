//
//  LabelViewTests.swift
//  ActivityLabel
//
//  Created by Александр Алгашев on 18.11.2026.
//

import XCTest
@testable import ActivityLabel

final class LabelViewTests: XCTestCase {
    /**
     Проверяет начальную структуру метки.
     */
    func testInitialSetup() {
        let labelView = LabelView(image: nil, title: "Тест")

        XCTAssertEqual(labelView.axis, .vertical)
        XCTAssertEqual(labelView.title, "Тест")
        XCTAssertNotNil(labelView.activityView)
        XCTAssertFalse(labelView.activityView.isAnimating)
    }
    /**
     Проверяет применение внутренних отступов.
     */
    func testDirectionalContentInsets() {
        let labelView = LabelView()
        let insets = NSDirectionalEdgeInsets(
            top: 8.0,
            leading: 12.0,
            bottom: 8.0,
            trailing: 12.0
        )
        labelView.directionalContentInsets = insets

        XCTAssertEqual(labelView.directionalContentInsets, insets)
        XCTAssertTrue(labelView.isLayoutMarginsRelativeArrangement)
    }
    /**
     Проверяет включение и отключение фона метки.
     */
    func testBackgroundEnablesAndDisables() {
        let labelView = LabelView()

        XCTAssertNil(labelView.background)

        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = .secondarySystemFill
        background.cornerRadius = 12.0
        labelView.background = background

        XCTAssertEqual(labelView.backgroundColor, .secondarySystemFill)
        XCTAssertEqual(labelView.layer.cornerRadius, 12.0)
        XCTAssertEqual(labelView.background, background)

        labelView.background = nil

        XCTAssertNil(labelView.background)
        XCTAssertNil(labelView.backgroundColor)
        XCTAssertEqual(labelView.layer.cornerRadius, 0.0)
    }


}
