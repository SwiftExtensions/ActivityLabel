//
//  LabelView.swift
//  ActivityLabel
//
//  Created by Александр Алгашев on 28.11.2025.
//

import UIKit

/**
 Компонент для отображения изображения с текстовой меткой.

 `LabelView` — вертикальный стек, содержащий ``activityView``
 и отдельный стек содержимого ``LabelContentView`` из `UIImageView`
 и `UILabel`.

 Изображение и текст объединены в отдельный стек, поэтому
 анимируются как единое целое.

 ## Пример использования:

 ```swift
 // Создание с изображением и заголовком
 let labelView = LabelView(
     image: UIImage(systemName: "play.circle.fill"),
     title: "Воспроизведение"
 )

 // Настройка внешнего вида
 labelView.textColor = .white
 labelView.font = .systemFont(ofSize: 14, weight: .medium)
 labelView.imageContentMode = .scaleAspectFit
 labelView.spacing = 8

 // Добавление на экран
 view.addSubview(labelView)
 ```

 ## Основные свойства:
 - `image` - изображение для отображения
 - `title` - текст метки
 - `textColor` - цвет текста
 - `font` - шрифт текста
 - `imageContentMode` - режим отображения изображения
 - `directionalContentInsets` - внутренние отступы содержимого
 - `background` - конфигурация фона метки
 - `activityView` - индикатор загрузки
 */
open class LabelView: UIStackView {
    /**
     Класс слоя метки — `CALayer` вместо `CATransformLayer` `UIStackView`.

     Замена позволяет слою рисовать оформление ``background``:
     цвет фона, скругление углов, обводку и тень.
     */
    open override class var layerClass: AnyClass { CALayer.self }
    /**
     Индикатор загрузки `UIActivityIndicatorView`, встроенный в метку.

     Располагается первым элементом стека над остальным содержимым.
     Пока анимация не запущена, индикатор скрыт
     и не занимает места в стеке.
     */
    public private(set) var activityView: UIActivityIndicatorView!
    
    /**
     Компонент для отображения изображения.

     Доступен только для чтения. Используйте свойство `image` для установки изображения.
     */
    public var imageView: UIImageView! { self.contentView.imageView }
    /**
     Компонент для отображения текста.

     Доступен только для чтения. Используйте свойство `title` для установки текста.
     */
    public var label: UILabel! { self.contentView.label }

    /**
     Отступ между элементами стека.

     Применяется и между элементами внутри стека содержимого.
     */
    public override var spacing: CGFloat {
        get { super.spacing }
        set {
            super.spacing = newValue
            self.contentView?.spacing = newValue
        }
    }
    /**
     Изображение для отображения в `imageView`.
     */
    public var image: UIImage? {
        get { self.imageView.image }
        set {
            self.contentView.image = newValue
            self.contentView.isHidden = newValue == nil && self.title.isEmpty
        }
    }
    /**
     Режим отображения содержимого изображения.

     Определяет, как изображение масштабируется и позиционируется внутри `imageView`.
     */
    public var imageContentMode: UIView.ContentMode {
        get { self.imageView.contentMode }
        set { self.imageView.contentMode = newValue }
    }

    /**
     Текст метки для отображения в `label`.

     Размер и положение метки управляются autolayout,
     например ограничениями `UIStackView`.
     */
    public var title: String? {
        get { self.label.text }
        set {
            self.contentView.title = newValue
            self.contentView.isHidden = newValue.isEmpty && self.image == nil
        }
    }
    /**
     Цвет текста метки.
     */
    public var textColor: UIColor? {
        get { self.label.textColor }
        set { self.label.textColor = newValue }
    }
    /**
     Выравнивание текста в метке.
     */
    public var textAlignment: NSTextAlignment {
        get { self.label.textAlignment }
        set { self.label.textAlignment = newValue }
    }
    /**
     Шрифт текста метки.
     */
    public var font: UIFont? {
        get { self.label.font }
        set { self.label.font = newValue }
    }
    /**
     Максимальное количество строк для отображения текста.

     Значение `0` означает отсутствие ограничений по количеству строк.
     */
    public var numberOfLines: Int {
        get { self.label.numberOfLines }
        set { self.label.numberOfLines = newValue }
    }
    /**
     Внутренние отступы содержимого с поддержкой направления текста (RTL/LTR).

     Использует `directionalLayoutMargins` для корректного отображения
     в языках с направлением справа налево.

     ## Пример использования:

     ```swift
     labelView.directionalContentInsets = NSDirectionalEdgeInsets(
         top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0
     )
     ```

     - Note: При установке значения автоматически включается `isLayoutMarginsRelativeArrangement`.
     */
    public var directionalContentInsets: NSDirectionalEdgeInsets {
        get { self.directionalLayoutMargins }
        set {
            self.insetsLayoutMarginsFromSafeArea = false
            self.directionalLayoutMargins = newValue
            self.isLayoutMarginsRelativeArrangement = true
        }
    }
    /**
     Конфигурация фона метки.

     Настройки применяются напрямую к ``layer``: цвет фона,
     скругление углов, обводка и тень. Значение `nil`
     сбрасывает оформление фона. Изменения анимируются
     внутри `UIView.animate`.

     `backgroundInsets`, `visualEffect`, `image`
     и `customView` не поддерживаются.

     ## Пример использования:

     ```swift
     var background = UIBackgroundConfiguration.clear()
     background.backgroundColor = .secondarySystemFill
     background.cornerRadius = 12.0
     labelView.background = background
     ```
     */
    public var background: UIBackgroundConfiguration? {
        didSet { self.updateBackground() }
    }
    /**
     Признак запущенной анимации индикатора загрузки ``activityView``.
     */
    public var isActivityAnimating: Bool {
        self.activityView.isAnimating
    }
    
    /**
     Стек содержимого из изображения и текста.
     */
    private(set) var contentView: LabelContentView!
    /**
     Цвет обводки фона для обновления при смене цветовой схемы.
     */
    private var strokeColor: UIColor?
    /**
     Цвет тени фона для обновления при смене цветовой схемы.
     */
    private var shadowColor: UIColor?
    /**
     Трансформер масштаба.
     */
    private var scaleTransform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    /**
     Длительность анимаций метки.

     Применяется при отображении и скрытии, смене
     содержимого, а также при запуске и остановке
     ``activityView``. Значение по умолчанию — `0.3` секунды.
     */
    public var animationDuration: TimeInterval = 0.3
    /**
     Идентификатор текущей последовательности анимаций содержимого метки.

     Увеличивается при каждой новой команде отображения,
     чтобы обработчики завершения прерванных цепочек
     не вмешивались в текущее состояние метки.
     */
    private var contentAnimationSequence = 0
    /**
     Идентификатор текущей последовательности анимаций `activityView`.

     Отделён от `contentAnimationSequence`: запуск и остановка
     индикатора не должны прерывать цепочку анимаций
     содержимого метки и наоборот.
     */
    private var activityAnimationSequence = 0

    /**
     Создает экземпляр `LabelView` с изображением и заголовком.

     - Parameter image: Изображение для отображения. Может быть `nil`.
     - Parameter title: Текст метки. Может быть `nil`.

     Инициализатор автоматически настраивает вертикальную ориентацию,
     отступ 4.0 и центрирование элементов.
     */
    public convenience init(image: UIImage?, title: String?) {
        self.init(frame: .zero)

        self.image = image
        self.title = title
    }
    /**
     Создает экземпляр `LabelView` с изображением и заголовком.

     - Parameter imageSystemName: Имя системного изображение для отображения. Может быть `nil`.
     - Parameter title: Текст метки. Может быть `nil`.

     Инициализатор автоматически настраивает вертикальную ориентацию,
     отступ 4.0 и центрирование элементов.
     */
    public convenience init(imageSystemName name: String?, title: String?) {
        self.init(frame: .zero)

        let image = name.flatMap(UIImage.init(systemName:))
        self.init(image: image, title: title)
    }
    /**
     Создает экземпляр `LabelView` с указанным фреймом.

     - Parameter frame: Прямоугольник, определяющий размер и позицию view.
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    /**
     Создает экземпляр `LabelView` из Interface Builder.

     - Parameter coder: Объект для декодирования view.
     */
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        self.initialSetup()
    }
    /**
     Установить начальные настройки.
     */
    private func initialSetup() {
        self.axis = .vertical
        self.spacing = 4.0
        self.alignment = .center

        let activityView = UIActivityIndicatorView(style: .medium)
        self.activityView = activityView
        self.insertArrangedSubview(activityView, at: 0)

        let contentView = LabelContentView()
        // Содержимого пока нет: скрыто, пока не появятся
        // изображение или текст.
        contentView.isHidden = true
        self.contentView = contentView
        self.addArrangedSubview(contentView)
    }
    /**
     Применяет конфигурацию ``background`` к ``layer``.
     */
    private func updateBackground() {
        guard let configuration = self.background else {
            self.backgroundColor = nil
            self.layer.cornerRadius = 0.0
            self.layer.borderWidth = 0.0
            self.layer.shadowOpacity = 0.0
            self.strokeColor = nil
            self.shadowColor = nil
            self.updateStrokeColor()
            self.updateShadowColor()
            return
        }
        
        self.backgroundColor = configuration.resolvedBackgroundColor(for: self.tintColor)
        self.layer.cornerRadius = configuration.cornerRadius
        self.layer.borderWidth = configuration.strokeWidth
        self.strokeColor = configuration.strokeColor.map { _ in
            configuration.resolvedStrokeColor(for: self.tintColor)
        }
        if #available(iOS 18.0, *) {
            let shadow = configuration.shadowProperties
            self.shadowColor = shadow.color
            self.layer.shadowOpacity = Float(shadow.opacity)
            self.layer.shadowRadius = shadow.radius
            self.layer.shadowOffset = shadow.offset
            self.layer.shadowPath = shadow.path?.cgPath
        }
        self.updateStrokeColor()
        self.updateShadowColor()
    }
    /**
     Обновляет цвет обводки слоя с учётом текущей цветовой схемы.
     */
    private func updateStrokeColor() {
        self.layer.borderColor = self.strokeColor?
            .resolvedColor(with: self.traitCollection).cgColor
    }
    /**
     Обновляет цвет тени слоя с учётом текущей цветовой схемы.
     */
    private func updateShadowColor() {
        self.layer.shadowColor = self.shadowColor?
            .resolvedColor(with: self.traitCollection).cgColor
    }
    /**
     Обновляет цвета обводки и тени при смене цветовой схемы.

     - Parameter previousTraitCollection: Предыдущий набор признаков среды.
     */
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.updateStrokeColor()
            self.updateShadowColor()
        }
    }
    /**
     Начинает новую последовательность анимаций содержимого метки.

     Обработчики завершения предыдущей последовательности
     перестают учитываться: проверка идентификатора
     внутри `completion` не пройдёт.

     - Returns: Идентификатор начатой последовательности.
     */
    private func beginContentAnimationSequence() -> Int {
        self.contentAnimationSequence += 1
        return self.contentAnimationSequence
    }
    /**
     Начинает новую последовательность анимаций `activityView`.

     Обработчики завершения предыдущей последовательности
     перестают учитываться: проверка идентификатора
     внутри `completion` не пройдёт.

     - Returns: Идентификатор начатой последовательности.
     */
    private func beginActivityAnimationSequence() -> Int {
        self.activityAnimationSequence += 1
        return self.activityAnimationSequence
    }
    /**
     Запускает анимацию ``activityView`` и отображает метку.
     */
    public func startActivityAnimating() {
        guard !self.activityView.isAnimating || self.activityView.alpha != 1.0 else { return }
        let sequence = self.beginActivityAnimationSequence()

        self.isHidden = false
        if self.contentView.isHidden {
            self.alpha = 0.0
            self.transform = .identity
            self.activityView.alpha = 1.0
            self.activityView.startAnimating()
            UIView.animate(withDuration: self.animationDuration) {
                self.alpha = 1.0
            }
        } else {
            self.activityView.alpha = 0.0
            UIView.animate(withDuration: self.animationDuration) {
                self.activityView.startAnimating()
            } completion: { finished in
                guard finished, sequence == self.activityAnimationSequence else { return }
                UIView.animate(withDuration: self.animationDuration) {
                    self.activityView.alpha = 1.0
                }
            }
        }
    }
    /**
     Останавливает анимацию ``activityView``.

     Индикатор плавно затухает на месте, после чего
     освобождает занимаемое место.
     */
    public func stopActivityAnimating() {
        guard self.activityView.isAnimating else { return }
        let sequence = self.beginActivityAnimationSequence()

        if self.contentView.isHidden {
            UIView.animate(withDuration: self.animationDuration) {
                self.alpha = 0.0
            } completion: { finished in
                guard finished, sequence == self.activityAnimationSequence else { return }
                self.activityView.stopAnimating()
                self.isHidden = true
                self.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: self.animationDuration) {
                self.activityView.alpha = 0.0
            } completion: { finished in
                guard finished, sequence == self.activityAnimationSequence else { return }
                UIView.animate(withDuration: self.animationDuration) {
                    self.activityView.stopAnimating()
                } completion: { finished in
                    guard finished, sequence == self.activityAnimationSequence else { return }
                    self.activityView.alpha = 1.0
                }
            }
        }
    }
    /**
     Отображает содержимое метки.

     - Parameter image: Изображение.
     - Parameter title: Текст.
     - Parameter animated: Признак анимированного отображения.
       При `true` для скрытой метки содержимое проявляется
       через изменение прозрачности. Для видимой метки текущие
       изображение и текст растворяются, после чего новые
       проявляются. ``activityView`` при этом остаётся
       видимым. Значение по умолчанию — `false`.
     */
    public func show(
        image: UIImage?,
        title: String?,
        animated: Bool = false
    ) {
        let sequence = self.beginContentAnimationSequence()

        guard animated else {
            self.image = image
            self.title = title
            self.contentView.resetAppearance()
            self.alpha = 1.0
            self.transform = .identity
            self.isHidden = false
            return
        }

        if self.isHidden {
            self.alpha = 0.0
            self.transform = .identity
            self.isHidden = false
            self.image = image
            self.title = title
            self.contentView.resetAppearance()
            // Нет содержимого, метка остаётся скрытой
            if self.contentView.isHidden {
                self.alpha = 1.0
                return
            }

            UIView.animate(withDuration: self.animationDuration) {
                self.alpha = 1.0
            }
        } else {
            self.replaceContent(with: image, title: title, sequence: sequence)
        }
    }
    /**
     Отображает содержимое метки.

     - Parameter imageSystemName: Имя системного изображение для отображения.
     - Parameter title: Текст.
     - Parameter animated: Признак анимированного отображения.
       При `true` для скрытой метки содержимое проявляется
       через изменение прозрачности. Для видимой метки текущие
       изображение и текст растворяются, после чего новые
       проявляются. ``activityView`` при этом остаётся
       видимым. Значение по умолчанию — `false`.
     */
    public func show(
        imageSystemName name: String?,
        title: String?,
        animated: Bool = false
    ) {
        let image = name.flatMap(UIImage.init(systemName:))
        self.show(image: image, title: title, animated: animated)
    }
    /**
     Заменяет содержимое метки с анимацией.

     Текущие изображение и текст растворяются, затем
     устанавливаются новые и проявляются.

     - Parameter image: Новое изображение.
     - Parameter title: Новый текст.
     - Parameter sequence: Идентификатор последовательности анимаций,
       в рамках которой выполняется замена.
     */
    private func replaceContent(
        with image: UIImage?,
        title: String?,
        sequence: Int
    ) {
        if self.isActivityAnimating {
            UIView.animate(withDuration: self.animationDuration) {
                // Восстановление видимости метки, если её
                // прозрачность гасится незавершённым скрытием.
                self.alpha = 1.0
                self.transform = .identity
                self.contentView.alpha = 0.0
                self.contentView.transform = self.scaleTransform
            } completion: { finished in
                guard finished, sequence == self.contentAnimationSequence else { return }
                UIView.animate(withDuration: self.animationDuration) {
                    self.image = image
                    self.title = title
                    self.layoutIfNeeded()
                } completion: { finished in
                    guard finished, sequence == self.contentAnimationSequence else { return }
                    UIView.animate(withDuration: self.animationDuration) {
                        self.contentView.resetAppearance()
                    }
                }
            }
        } else {
            UIView.animate(withDuration: self.animationDuration) {
                self.alpha = 0.0
                self.transform = self.scaleTransform
            } completion: { finished in
                guard finished, sequence == self.contentAnimationSequence else { return }
                self.image = image
                self.title = title
                UIView.animate(withDuration: self.animationDuration) {
                    self.alpha = 1.0
                    self.transform = .identity
                }
            }
        }
    }
    /**
     Скрывает метку.

     ``activityView`` при скрытии останавливается.

     - Parameter animated: Признак анимированного скрытия.
       При `true` содержимое уменьшается и растворяется.
       Значение по умолчанию — `false`.
     */
    public func hide(animated: Bool = false) {
        let sequence = self.beginContentAnimationSequence()

        guard animated else {
            self.clear()
            self.contentView.resetAppearance()
            self.activityView.stopAnimating()
            self.alpha = 1.0
            self.transform = .identity
            self.isHidden = true
            return
        }

        if self.isHidden {
            self.activityView.stopAnimating()
            return
        }

        UIView.animate(withDuration: self.animationDuration) {
            self.alpha = 0.0
        } completion: { finished in
            guard finished, sequence == self.contentAnimationSequence else { return }
            self.isHidden = true
            self.alpha = 1.0
            self.transform = .identity
            self.clear()
            self.activityView.stopAnimating()
        }
    }
    /**
     Очищает содержимое метки.

     Сбрасывает изображение и текст.
     */
    public func clear() {
        self.title = nil
        self.image = nil
    }


}
