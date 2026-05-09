import UIKit
import UnityFramework
import AVFoundation

class UnityBridge: NSObject {
    static let shared = UnityBridge()
    private var unityFramework: UnityFramework?
    private var pendingSceneIndex: Int? = nil
    private var unityReady = false
    private var unityStarted = false
    var onUnityMessage: ((String) -> Void)?

    func launch(sceneIndex: Int) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            startUnity(sceneIndex: sceneIndex)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { self.startUnity(sceneIndex: sceneIndex) }
                }
            }
        default:
            break
        }
    }

    private func startUnity(sceneIndex: Int) {
        if unityFramework == nil {
            pendingSceneIndex = sceneIndex
            initUnity()
        } else if unityReady {
            showUnityAndLoadScene(sceneIndex: sceneIndex)
        } else {
            pendingSceneIndex = sceneIndex
        }
    }

    func initUnity() {
        if unityStarted { return }
        unityStarted = true

        let bundlePath = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        let bundle = Bundle(path: bundlePath)
        if bundle?.isLoaded == false { bundle?.load() }

        guard let ufw = bundle?.principalClass?.getInstance() else {
            print("❌ UnityBridge: Failed to get UnityFramework instance")
            unityStarted = false
            return
        }

        unityFramework = ufw
        unityFramework?.setDataBundleId("com.unity3d.framework")
        unityFramework?.register(self)

        // ✅ Pass nil for appLaunchOpts — critical for embedded mode
        unityFramework?.runEmbedded(
            withArgc: CommandLine.argc,
            argv: CommandLine.unsafeArgv,
            appLaunchOpts: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUnityMessage(_:)),
            name: NSNotification.Name("OnUnityMessage"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUnityReady),
            name: NSNotification.Name("UnityReady"),
            object: nil
        )

        // Fallback after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            if !self.unityReady, let sceneIndex = self.pendingSceneIndex {
                print("⚠️ UnityBridge: Fallback launch triggered")
                self.unityReady = true
                self.showUnityAndLoadScene(sceneIndex: sceneIndex)
                self.pendingSceneIndex = nil
            }
        }
    }

    @objc private func onUnityReady() {
        print("✅ UnityBridge: Unity is ready!")
        unityReady = true
        if let sceneIndex = pendingSceneIndex {
            showUnityAndLoadScene(sceneIndex: sceneIndex)
            pendingSceneIndex = nil
        }
    }

    private func showUnityAndLoadScene(sceneIndex: Int) {
        let gameObjectName = sceneIndex == 1 ? "Game2Manager" : "Game1Manager"

        print("🎮 UnityBridge: Sending LoadScene(\(sceneIndex)) to \(gameObjectName)")

        unityFramework?.sendMessageToGO(
            withName: gameObjectName,
            functionName: "LoadScene",
            message: String(sceneIndex)
        )

        guard let unityVC = unityFramework?.appController()?.rootViewController else {
            print("❌ UnityBridge: Unity rootViewController is nil")
            return
        }

        // ✅ Find the topmost presented view controller
        var topVC = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController

        while let presented = topVC?.presentedViewController {
            topVC = presented
        }

        guard let topVC = topVC else {
            print("❌ UnityBridge: Could not find top view controller")
            return
        }

        print("🎮 UnityBridge: Presenting Unity from \(type(of: topVC))")

        topVC.present(unityVC, animated: true) {
            print("✅ UnityBridge: Unity presented successfully for scene \(sceneIndex)")
        }
    }

    @objc func handleUnityMessage(_ notification: Notification) {
        if let message = notification.userInfo?["message"] as? String {
            onUnityMessage?(message)
        }
    }
}

extension UnityBridge: UnityFrameworkListener {
    func unityDidUnload(_ notification: Notification!) {
        unityFramework?.unregisterFrameworkListener(self)
        unityFramework = nil
        unityReady = false
        unityStarted = false
    }
    func unityDidQuit(_ notification: Notification!) {}
}
