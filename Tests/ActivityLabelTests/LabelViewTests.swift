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
    /**
     Проверяет, что стек содержимого скрыт у метки без содержимого.
     */
    func testContentViewHiddenForEmptyLabel() {
        let empty = LabelView()
        XCTAssertTrue(empty.contentView.isHidden)

        let filled = LabelView(image: nil, title: "Текст")
        XCTAssertFalse(filled.contentView.isHidden)
    }
    /**
     Проверяет появление метки при запуске индикатора.
     */
    func testStartActivityAnimatingShowsLabel() {
        let labelView = LabelView()
        labelView.isHidden = true

        labelView.startActivityAnimating()

        XCTAssertFalse(labelView.isHidden)
        XCTAssertTrue(labelView.activityView.isAnimating)
    }
    /**
     Проверяет скрытие пустой метки после остановки индикатора.
     */
    func testStopActivityAnimatingHidesEmptyLabel() {
        let labelView = self.makeLabelView()
        labelView.isHidden = true

        labelView.startActivityAnimating()
        labelView.stopActivityAnimating()

        self.waitForAnimations()

        XCTAssertTrue(labelView.isHidden)
        XCTAssertFalse(labelView.activityView.isAnimating)
    }
    /**
     Проверяет, что отображение содержимого во время остановки
     индикатора не приводит к скрытию метки.

     Воспроизводит гонку: остановка индикатора запускает
     затухание метки, а отображение приходит до завершения
     затухания.
     */
    func testShowDuringStopActivityKeepsLabelVisible() {
        let labelView = self.makeLabelView()
        labelView.isHidden = true

        labelView.startActivityAnimating()
        labelView.stopActivityAnimating()
        labelView.show(image: nil, title: "Ошибка", animated: true)

        self.waitForAnimations()

        XCTAssertFalse(labelView.isHidden)
        XCTAssertEqual(labelView.title, "Ошибка")
    }
    /**
     Проверяет, что отображение содержимого во время остановки
     индикатора пустой метки не мешает остановке индикатора.

     Воспроизводит гонку: остановка индикатора запускает
     затухание метки, а отображение содержимого прерывает
     это затухание до его завершения.
     */
    func testShowDuringStopActivityStopsIndicator() {
        let labelView = self.makeLabelView()
        labelView.isHidden = true

        labelView.startActivityAnimating()
        labelView.stopActivityAnimating()
        labelView.show(image: nil, title: "Новый текст", animated: true)

        self.waitForAnimations()

        XCTAssertFalse(labelView.isHidden)
        XCTAssertFalse(labelView.activityView.isAnimating)
        XCTAssertEqual(labelView.title, "Новый текст")
    }
    /**
     Проверяет, что запуск индикатора во время скрытия метки
     сохраняет запущенный индикатор и видимость метки.

     Воспроизводит гонку: скрытие запускает затухание метки,
     а запуск индикатора приходит до завершения затухания.
     */
    func testStartActivityDuringHideKeepsIndicatorAnimating() {
        let labelView = self.makeLabelView(title: "Текст")
        labelView.show(image: nil, title: "Текст")

        labelView.hide(animated: true)
        labelView.startActivityAnimating()

        self.waitForAnimations()

        XCTAssertFalse(labelView.isHidden)
        XCTAssertTrue(labelView.activityView.isAnimating)
        XCTAssertFalse(labelView.activityView.isHidden)
    }
    /**
     Проверяет, что скрытие содержимого не влияет
     на индикатор и саму метку.
     */
    func testHideContentKeepsIndicatorAnimating() {
        let labelView = self.makeLabelView(title: "Текст")
        labelView.startActivityAnimating()

        labelView.hideContent(animated: true)

        self.waitForAnimations()

        XCTAssertFalse(labelView.isHidden)
        XCTAssertTrue(labelView.activityView.isAnimating)
        XCTAssertTrue(labelView.contentView.isHidden)
        XCTAssertNil(labelView.title)
    }
    /**
     Проверяет, что отображение во время скрытия метки
     возвращает её видимость.
     */
    func testShowDuringHideKeepsLabelVisible() {
        let labelView = self.makeLabelView(title: "Текст")
        labelView.show(image: nil, title: "Текст")

        labelView.hide(animated: true)
        labelView.show(image: nil, title: "Ошибка", animated: true)

        self.waitForAnimations()

        XCTAssertFalse(labelView.isHidden)
        XCTAssertEqual(labelView.title, "Ошибка")
    }

    /**
     Создает метку в окне с ускоренными анимациями.

     Анимации `UIView` выполняются только для представлений,
     добавленных в окно. Длительность сокращена для тестов.

     - Parameter title: Текст метки. Может быть `nil`.
     - Returns: Метка, добавленная в тестовое окно.
     */
    private func makeLabelView(title: String? = nil) -> LabelView {
        let labelView = LabelView(image: nil, title: title)
        labelView.animationDuration = 0.01

        let window = UIWindow(frame: CGRect(
            x: 0.0, y: 0.0,
            width: 300.0, height: 300.0
        ))
        window.addSubview(labelView)
        window.isHidden = false

        return labelView
    }
    /**
     Ожидает завершения анимаций метки.

     - Parameter timeout: Время ожидания в секундах.
       Значение по умолчанию — `0.5`.
     */
    private func waitForAnimations(timeout: TimeInterval = 0.5) {
        let expectation = XCTestExpectation(description: "Окончание анимаций")
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: timeout + 1.0)
    }


}
