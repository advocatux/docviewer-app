/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import DocumentViewer 1.0
import QtQuick.Window 2.0
import Qt.labs.settings 1.0
import QtSystemInfo 5.0

import "common"
import "common/loadComponent.js" as LoadComponent

MainView {
    id: mainView
    objectName: "mainView"

    property bool pickMode: commandLineProxy.pickMode
    property alias contentHubProxy: contentHubLoader.item
    property bool nightModeEnabled: false

    // If device orientation is landscape and screen width is limited,
    // force hiding Unity 8 indicators panel.
    property bool fullscreen: commandLineProxy.fullscreen ||
                              (!desktopMode && isLandscape && narrowWindow) ||
                              pageStack.currentPage.hasOwnProperty("isPresentationMode")

    readonly property bool desktopMode: DocumentViewer.desktopMode

    readonly property bool narrowWindow: width < units.gu(51)
    readonly property bool wideWindow: width >= units.gu(80)
    readonly property bool veryWideWindow: width >= units.gu(120)
    readonly property bool isLandscape: Screen.orientation == Qt.LandscapeOrientation ||
                                        Screen.orientation == Qt.InvertedLandscapeOrientation

    function openDocument(path)  {
        if (path !== "") {
            console.log("Path of the document:", path)

            // If a document is already shown, pop() its page.
            while (pageStack.depth > 1)
                pageStack.pop();

            path = path.replace("file://", "")
                       .replace("document://", "");

            if (file.path === path) {
                // File has been already initialized, so just open the viewer
                LoadComponent.load(file.mimetype.name);

                return
            }

            file.path = path;
        }
    }

    function runUnknownTypeDialog() {
        PopupUtils.open(Qt.resolvedUrl("common/UnknownTypeDialog.qml"),
                        mainView, { parent: mainView });
    }

    function switchToBrowseMode() {
        mainView.pickMode = false
    }

    function switchToPickMode() {
        mainView.pickMode = true
    }

    function showErrorDialog(message) {
        PopupUtils.open(Qt.resolvedUrl("common/ErrorDialog.qml"),
                        mainView, { parent: mainView, text: message });
    }

    applicationName: "com.ubuntu.docviewer"
    automaticOrientation: true

    width: units.gu(150)
    height: units.gu(75)

    layer.effect: NightModeShader {}
    layer.enabled: nightModeEnabled &&
                   (pageStack.depth > 1) &&
                   !pageStack.currentPage.isPresentationMode

    onFullscreenChanged: {
        if (mainView.fullscreen)
            window.visibility = Window.FullScreen
        else
            window.visibility = Window.Windowed
    }

    onPickModeChanged: {
        if (mainView.pickMode) {
            // If a document is loaded, pop() its page.
            while (pageStack.depth > 1) {
                pageStack.pop()
            }
        }
    }

    Component.onCompleted: {
        // WORKAROUND: Mouse detection is not included in the SDK yet
        QuickUtils.mouseAttached = true

        pageStack.push(Qt.resolvedUrl("documentPage/DocumentPage.qml"));

        // Open the document, if one has been specified.
        openDocument(commandLineProxy.documentFile);
    }

    File {
        id: file
        objectName: "file"

        onMimetypeChanged: LoadComponent.load(mimetype.name)
        onErrorChanged: {
            if (error == -1)
                mainView.showErrorDialog(i18n.tr("File does not exist."));
        }
    }

    SortFilterModel {
        id: folderModel

        function search(pattern) {
            // Search the given pattern, case insensitive
            filter.pattern = new RegExp(pattern, 'i')
        }

        model: DocumentsModel {
            id: docModel

            // Used for autopilot tests! If customDir is empty, this property is not used.
            customDir: commandLineProxy.documentsDir
        }

        // TODO: Expose an enum from DocumentViewer module.
        sort.property: {
            switch (sortSettings.sortMode) {
            case 0:
                return "date"
            case 1:
                return "name"
            case 2:
                return "size"
            default:
                return "date"
            }
        }
        sort.order: {
            switch (sortSettings.sortMode) {
            case 0:     // sort by date
                return sortSettings.reverseOrder ? Qt.AscendingOrder : Qt.DescendingOrder
            case 1:     // sort by name
                return sortSettings.reverseOrder ? Qt.DescendingOrder : Qt.AscendingOrder
            case 2:     // sort by size
                return sortSettings.reverseOrder ? Qt.DescendingOrder : Qt.AscendingOrder
            default:
                return sortSettings.reverseOrder ? Qt.AscendingOrder : Qt.DescendingOrder
            }
        }
        sortCaseSensitivity: Qt.CaseInsensitive

        filter.property: "name"
    }

    // WORKAROUND: mainView backgroundColor is an alias for the window color, and does not
    // refer to a child QML Rectangle anymore. This breaks our night mode shader; for that
    // reason we need to re-add that QML Rectangle.
    Rectangle {
        anchors.fill: parent
        color: mainView.backgroundColor
        visible: nightModeEnabled
    }

    PageStack {
        id: pageStack
    }

    Settings {
        id: sortSettings
        property int sortMode: 0    // 0 = by date, 1 = by name, 2 = by size
        property bool reverseOrder: false
    }

    // CommandLine parser
    CommandLineProxy {
        id: commandLineProxy
    }

    // Content Hub support
    Loader {
        id: contentHubLoader
        source: Qt.resolvedUrl("common/ContentHubProxy.qml")
    }

    // Uri Handler support
    Connections {
        target: UriHandler
        onOpened: openDocument(uris[0])
    }

    // Screen saver controller
    ScreenSaver {
        // Turn off screen saver during a full-screen presentation when the app is focused.
        screenSaverEnabled: !(Qt.application.active && pageStack.currentPage.isPresentationMode)
    }
}
