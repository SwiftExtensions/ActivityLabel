//
//  AppDelegate.swift
//  ActivityLabelDemo
//
//  Created by Александр Алгашев on 18.11.2026.
//

import UIKit

/**
 Делегат приложения демо-проекта.

 Создает главное окно и отображает экран
 с примерами использования `LabelView`.
 */
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    /**
     Главное окно приложения.
     */
    var window: UIWindow?

    /**
     Настраивает главное окно и корневой контроллер.

     - Parameter application: Экземпляр приложения.
     - Parameter launchOptions: Параметры запуска.

     - Returns: `true`, если запуск прошёл успешно.
     */
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }


}
