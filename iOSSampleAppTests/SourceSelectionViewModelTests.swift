//
//  CustomSourceViewModelTest.swift
//  iOSSampleAppTests
//
//  Created by Igor Kulman on 04/10/2017.
//  Copyright © 2017 Igor Kulman. All rights reserved.
//

import Foundation
@testable import iOSSampleApp
import Nimble
import Quick
import RxBlocking
import RxSwift
import RxTest

class SourceSelectionViewModelTests: QuickSpec {
    override func spec() {
        describe("SourceSelectionViewModel") {
            context("when intialized") {
                let vm = SourceSelectionViewModel(settingsService: SettingsServiceMock())

                it("should load default RSS sources") {
                    let sources = try! vm.sources.toBlocking().first()!
                    expect(sources.count).to(equal(4))
                    expect(sources[0].source.title).to(equal("Coding Journal"))
                    expect(sources[1].source.title).to(equal("Hacker News"))
                    expect(sources[2].source.title).to(equal("The Verge"))
                    expect(sources[3].source.title).to(equal("Wired"))
                    expect(sources[0].isSelected.value).to(beFalse())
                    expect(sources[1].isSelected.value).to(beFalse())
                    expect(sources[2].isSelected.value).to(beFalse())
                    expect(sources[3].isSelected.value).to(beFalse())
                }
            }

            context("when initialized and a feed already selected") {
                let settingsService = SettingsServiceMock()
                settingsService.selectedSource = RssSource(title: "Coding Journal", url: "https://blog.kulman.sk", rss: "https://blog.kulman.sk/index.xml", icon: nil)
                let vm = SourceSelectionViewModel(settingsService: settingsService)

                it("should pre-select that feed") {
                    let sources = try! vm.sources.toBlocking().first()!
                    expect(sources.count).to(equal(4))
                    expect(sources[0].source.title).to(equal("Coding Journal"))
                    expect(sources[0].isSelected.value).to(beTrue())
                    expect(sources[1].isSelected.value).to(beFalse())
                    expect(sources[2].isSelected.value).to(beFalse())
                    expect(sources[3].isSelected.value).to(beFalse())
                }
            }

            context("when a new source is added") {
                let vm = SourceSelectionViewModel(settingsService: SettingsServiceMock())

                it("should be available, at firts position and selected") {
                    vm.addNewSource(source: RssSource(title: "Example", url: "http://example.com", rss: "http://example.com", icon: nil))
                    let sources = try! vm.sources.toBlocking().first()!
                    expect(sources.count).to(equal(5))
                    expect(sources[1].isSelected.value).to(beFalse())
                    expect(sources[2].isSelected.value).to(beFalse())
                    expect(sources[3].isSelected.value).to(beFalse())
                    expect(sources[4].isSelected.value).to(beFalse())
                    expect(sources[0].isSelected.value).to(beTrue())
                    expect(sources[0].source.title).to(equal("Example"))
                }
            }

            context("when initialized and a feed already selected") {
                let settingsService = SettingsServiceMock()
                settingsService.selectedSource = RssSource(title: "Coding Journal", url: "https://blog.kulman.sk", rss: "https://blog.kulman.sk/index.xml", icon: nil)
                let vm = SourceSelectionViewModel(settingsService: settingsService)

                it("should toggle the selection") {
                    let sources = try! vm.sources.toBlocking().first()!
                    vm.toggleSource(source: sources[2])
                    expect(sources[0].isSelected.value).to(beFalse())
                    expect(sources[1].isSelected.value).to(beFalse())
                    expect(sources[2].isSelected.value).to(beTrue())
                    expect(sources[3].isSelected.value).to(beFalse())
                }
            }

            context("when no source is selected") {
                let settingsService = SettingsServiceMock()
                let vm = SourceSelectionViewModel(settingsService: settingsService)

                it("should not be saved") {
                    expect(vm.saveSelectedSource()).to(beFalse())
                    expect(settingsService.selectedSource).to(beNil())
                }
            }

            context("when source is selected") {
                let settingsService = SettingsServiceMock()
                let vm = SourceSelectionViewModel(settingsService: settingsService)

                it("should be saved") {
                    let sources = try! vm.sources.toBlocking().first()!
                    vm.toggleSource(source: sources[2])
                    expect(vm.saveSelectedSource()).to(beTrue())
                    expect(settingsService.selectedSource).to(equal(sources[2].source))
                }
            }
        }
    }
}
