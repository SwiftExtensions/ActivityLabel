//
//  ViewController.swift
//  ActivityLabelDemo
//
//  Created by Александр Алгашев on 18.11.2026.
//

import UIKit
import ActivityLabel

/**
 Экран демо-приложения для тестирования и отладки `LabelView`.

 Отображает `LabelView` по центру экрана и панель кнопок
 для проверки основных сценариев:

 - отображение и скрытие метки с анимацией и без;
 - запуск и остановка индикатора загрузки;
 - смена содержимого (изображение и текст).
 */
final class ViewController: UIViewController {
    /**
     Тестируемый компонент `LabelView`.
     */
    private let labelView = LabelView(
        imageSystemName: "play.circle.fill",
        title: "Воспроизведение"
    )
    /**
     Переключатель анимации переходов.
     */
    private let animatedSwitch = UISwitch()
    /**
     Индекс текущего варианта содержимого.
     */
    private var contentIndex = 0
    /**
     Варианты содержимого для смены изображения и текста.
     */
    private let contents: [(imageSystemName: String?, title: String?)] = [
        ("play.circle.fill", "Воспроизведение"),
        ("pause.circle.fill", "Пауза"),
        ("heart.fill", "В избранное"),
        ("star.fill", nil),
        (nil, "Без изображения")
    ]

    /**
     Настраивает экран после загрузки view.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground

        self.setupLabelView()
        self.setupControls()
    }

    /**
     Настраивает внешний вид `LabelView` и размещает его по центру экрана.
     */
    private func setupLabelView() {
        let labelView = self.labelView
        labelView.textColor = .label
        labelView.font = .systemFont(ofSize: 14, weight: .medium)
        labelView.imageContentMode = .scaleAspectFit
        labelView.spacing = 8
        labelView.directionalContentInsets = NSDirectionalEdgeInsets(
            top:      16.0,
            leading:  16.0,
            bottom:   16.0,
            trailing: 16.0
        )
        labelView.layer.cornerCurve = .continuous
        labelView.layer.cornerRadius = 12.0
        labelView.layer.borderColor = UIColor.systemGray3.cgColor
        labelView.layer.borderWidth = 1.0

        labelView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(labelView)
        NSLayoutConstraint.activate([
            labelView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            labelView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            labelView.imageView.widthAnchor.constraint(equalToConstant: 48),
            labelView.imageView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    /**
     Настраивает панель кнопок и размещает её в нижней части экрана.
     */
    private func setupControls() {
        let animatedRow = self.makeAnimatedRow()
        let showHideRow = self.makeRow(
            self.makeButton(title: "Показать", action: #selector(self.showLabel)),
            self.makeButton(title: "Скрыть", action: #selector(self.hideLabel))
        )
        let activityRow = self.makeRow(
            self.makeButton(title: "Старт индикатор", action: #selector(self.startActivity)),
            self.makeButton(title: "Стоп индикатор", action: #selector(self.stopActivity))
        )
        let contentButton = self.makeButton(
            title: "Сменить содержимое",
            action: #selector(self.changeContent)
        )

        let stackView = UIStackView(arrangedSubviews: [
            animatedRow,
            showHideRow,
            activityRow,
            contentButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually

        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            stackView.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            stackView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            )
        ])
    }
    /**
     Создает строку с переключателем анимации.
     - Returns: Строка с подписью и `UISwitch`.
     */
    private func makeAnimatedRow() -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = "Анимация"
        titleLabel.font = .systemFont(ofSize: 16)

        let row = UIStackView(arrangedSubviews: [titleLabel, self.animatedSwitch])
        row.spacing = 8
        row.alignment = .center
        self.animatedSwitch.isOn = true
        self.animatedSwitch.setContentHuggingPriority(.required, for: .horizontal)
        return row
    }
    /**
     Создает горизонтальную строку из кнопок одинаковой ширины.
     - Parameter buttons: Кнопки для размещения в строке.
     - Returns: Горизонтальный стек с кнопками.
     */
    private func makeRow(_ buttons: UIButton...) -> UIStackView {
        let row = UIStackView(arrangedSubviews: buttons)
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually
        return row
    }
    /**
     Создает кнопку с указанным заголовком и обработчиком.
     - Parameter title: Заголовок кнопки.
     - Parameter action: Обработчик нажатия.
     - Returns: Настроенная кнопка.
     */
    private func makeButton(title: String, action: Selector) -> UIButton {
        var configuration: UIButton.Configuration
        if #available(iOS 26.0, *) {
            configuration = .prominentGlass()
        } else {
            configuration = .borderedProminent()
        }
        configuration.buttonSize = .large
        configuration.cornerStyle = .medium
        configuration.title = title
        configuration.titleTextAttributesTransformer =
        UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16.0, weight: .medium)
            
            return outgoing
        }
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }

    /**
     Отображает метку с текущим содержимым.
     */
    @objc private func showLabel() {
        let content = self.contents[self.contentIndex]
        self.labelView.show(
            imageSystemName: content.imageSystemName,
            title: content.title,
            animated: self.animatedSwitch.isOn
        )
    }
    /**
     Скрывает метку.
     */
    @objc private func hideLabel() {
        self.labelView.hide(animated: self.animatedSwitch.isOn)
    }
    /**
     Запускает анимацию индикатора загрузки.
     */
    @objc private func startActivity() {
        self.labelView.startActivityAnimating()
    }
    /**
     Останавливает анимацию индикатора загрузки.
     */
    @objc private func stopActivity() {
        self.labelView.stopActivityAnimating()
    }
    /**
     Переключает содержимое метки на следующий вариант.
     */
    @objc private func changeContent() {
        self.contentIndex = (self.contentIndex + 1) % self.contents.count
        self.showLabel()
    }


}
