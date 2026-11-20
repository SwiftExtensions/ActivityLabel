//
//  LabelView.State.swift
//  ActivityLabel
//
//  Created by Александр Алгашев on 20.11.2026.
//

import UIKit

extension LabelView {
    /**
     Состояние отображения метки.

     Аккумулирует намерения видимости метки, индикатора
     и содержимого, а также счётчик последовательностей
     анимаций содержимого. Намерения изменяются только
     командами состояния: завершение анимации применяет
     состояние, только если намерения за время анимации
     не изменились.
     */
    struct State {
        /**
         Намерение отображения метки.
         */
        enum VisibilityIntent {
            /**
             Метка должна отображаться.
             */
            case show
            /**
             Метка должна быть скрыта.
             */
            case hide


        }
        /**
         Намерение состояния `activityView`.
         */
        enum ActivityIntent {
            /**
             Индикатор должен анимироваться.
             */
            case animating
            /**
             Индикатор должен быть остановлен.
             */
            case stopped


        }
        /**
         Намерение отображения содержимого метки.
         */
        enum ContentIntent {
            /**
             Содержимое должно отображаться.
             */
            case content
            /**
             Содержимое должно отсутствовать.
             */
            case empty


        }

        /**
         Текущее намерение отображения метки.
         */
        private(set) var visibilityIntent: VisibilityIntent = .show
        /**
         Текущее намерение состояния `activityView`.
         */
        private(set) var activityIntent: ActivityIntent = .stopped
        /**
         Текущее намерение отображения содержимого метки.
         */
        private(set) var contentIntent: ContentIntent = .empty
        /**
         Идентификатор текущей последовательности анимаций содержимого.

         Увеличивается при каждой новой команде отображения,
         чтобы обработчики завершения прерванных цепочек
         не вмешивались в текущее состояние метки.
         */
        private(set) var contentAnimationSequence = 0

        /**
         Отмечает намерение отобразить метку с содержимым.
         - Parameter image: Изображение. Может быть `nil`.
         - Parameter title: Текст. Может быть `nil`.
         - Returns: Идентификатор начатой последовательности анимаций.
         */
        mutating func show(image: UIImage?, title: String?) -> Int {
            self.contentAnimationSequence += 1
            self.visibilityIntent = .show
            self.contentIntent = image == nil && title.isEmpty ? .empty : .content

            return self.contentAnimationSequence
        }
        /**
         Отмечает намерение скрыть метку и очистить содержимое.
         - Returns: Идентификатор начатой последовательности анимаций.
         */
        mutating func hide() -> Int {
            self.contentAnimationSequence += 1
            self.visibilityIntent = .hide
            self.contentIntent = .empty

            return self.contentAnimationSequence
        }
        /**
         Отмечает намерение скрыть содержимое метки.

         Метка и индикатор продолжают отображаться.

         - Returns: Идентификатор начатой последовательности анимаций.
         */
        mutating func hideContent() -> Int {
            self.contentAnimationSequence += 1
            self.contentIntent = .empty

            return self.contentAnimationSequence
        }
        /**
         Отмечает намерение запустить индикатор.

         Метка намерена отображаться.
         */
        mutating func startActivityAnimating() {
            self.visibilityIntent = .show
            self.activityIntent = .animating
        }
        /**
         Отмечает намерение остановить индикатор.

         При отсутствии содержимого метка намерена скрыться.
         */
        mutating func stopActivityAnimating() {
            self.activityIntent = .stopped
            if self.contentIntent == .empty {
                self.visibilityIntent = .hide
            }
        }
        /**
         Обновляет намерение содержимого по факту его наличия.
         - Parameter isHidden: Признак отсутствия содержимого.
         */
        mutating func updateContent(isHidden: Bool) {
            self.contentIntent = isHidden ? .empty : .content
        }


    }


}
