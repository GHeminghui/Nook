import XCTest

/// 仅用于生成 App Store 截图素材：
/// `TEST_RUNNER_CAPTURE_APPSTORE=1 xcodebuild test -only-testing:NookUITests/AppStoreScreenshots ...`
final class AppStoreScreenshots: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["CAPTURE_APPSTORE"] == "1",
            "素材生成专用，普通测试运行跳过"
        )
    }

    func testCaptureScreens() throws {
        XCUIDevice.shared.orientation = .landscapeLeft

        let app = XCUIApplication()
        app.launchArguments = baseArguments + ["-nook-demo-seed"]
        app.launch()
        XCTAssertTrue(app.staticTexts[homeLabel].waitForExistence(timeout: 60))
        sleep(2)
        snapshot("01-全部资料")

        relaunch(app, arguments: baseArguments + ["-nook-demo-folder", "函数"])
        XCTAssertTrue(app.navigationBars["函数"].waitForExistence(timeout: 20))
        sleep(2)
        snapshot("02-文件夹层级")

        relaunch(app, arguments: baseArguments + ["-nook-demo-tag", "课堂"])
        sleep(3)
        snapshot("03-标签筛选")

        relaunch(app, arguments: baseArguments)
        app.staticTexts["函数的单调性.pdf"].tap()
        sleep(6)
        snapshot("04-PDF 标注")

        relaunch(app, arguments: baseArguments)
        app.staticTexts["三角函数公式卡.html"].tap()
        sleep(4)
        snapshot("05-HTML 预览")
    }

    private var language: String {
        ProcessInfo.processInfo.environment["CAPTURE_LANG"] ?? "zh-Hans"
    }

    private var baseArguments: [String] {
        var args = ["-nook-demo-hide-sync"]
        if language == "en" {
            args += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        }
        return args
    }

    private var homeLabel: String {
        language == "en" ? "All Materials" : "全部资料"
    }

    private func relaunch(_ app: XCUIApplication, arguments: [String]) {
        app.terminate()
        app.launchArguments = arguments
        app.launch()
        XCTAssertTrue(app.staticTexts[homeLabel].waitForExistence(timeout: 30))
        sleep(2)
    }

    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
