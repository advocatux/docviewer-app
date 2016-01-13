/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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
import QtQuick.Layouts 1.1
import DocumentViewer.PDF 1.0 as PDF

import "../common"
import "../common/utils.js" as Utils

Page {
    id: pdfPage
    title: Utils.getNameOfFile(file.path)

    header: PageHeader {
        flickable: pdfView

        trailingActionBar.actions: [ fileDetails, nightModeToggle, goToPage, searchText ]

        contents: ListItemLayout {
            anchors.centerIn: parent

            ActivityIndicator {
                SlotsLayout.position: SlotsLayout.Leading
                SlotsLayout.overrideVerticalPositioning: true
                y: (parent.height - height) * 0.5
                running: pdfView.currentPageItem.status == Image.Loading || poppler.isLoading
                visible: running
            }

            title {
                font.weight: Font.DemiBold
                text: pdfPage.title
            }

            subtitle {
                textSize: Label.Small
                // TRANSLATORS: the first argument (%1) refers to the page currently shown on the screen,
                // while the second one (%2) refers to the total pages count.
                text: i18n.tr("Page %1 of %2").arg(pdfView.currentPageIndex + 1).arg(pdfView.count)
            }
        }
    }

    BottomEdge {
        id: contentsBottomEdge

        hint {
            action: Action {
                // TRANSLATORS: "Contents" refers to the "Table of Contents" of a PDF document.
                text: i18n.tr("Contents")
                iconName: "view-list-symbolic"  // FIXME: Needs ToC icon.
                onTriggered: contentsBottomEdge.commit()
            }
            flickable: pdfPage.flickable
        }

        contentComponent: bottomEdgeContent
        enabled: poppler.tocModel.count > 0

        Component {
            id: bottomEdgeContent
            PdfContentsPage { width: pdfPage.width; height: pdfPage.height }
        }
    }

    // Reset night mode shader settings when closing the page
    // Component.onDestruction: mainView.nightModeEnabled = false

    Rectangle {
        // Since UITK 1.3, the MainView background is white.
        // We need to set a different color, otherwise pages
        // boundaries are not visible.
        anchors.fill: parent
        color: "#f5f5f5"
    }

    PDF.VerticalView {
        id: pdfView
        objectName: "pdfView"

        anchors.fill: parent
        topMargin: pdfPage.header.height
        spacing: units.gu(2)

        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 1500 * units.gridUnit / 8
        maximumFlickVelocity: 2500 * units.gridUnit / 8

        contentWidth: parent.width * _zoomHelper.scale
        cacheBuffer: height * poppler.providersNumber * _zoomHelper.scale * 0.5
        interactive: !pinchy.pinch.active

        model: poppler
        delegate: PdfViewDelegate {
            Component.onDestruction: window.releaseResources()
        }

        // FIXME: On zooming, keep the same content position.
        PinchArea {
            id: pinchy
            anchors.fill: parent

            pinch {
                target: _zoomHelper
                minimumScale: 1.0
                maximumScale: 2.5
            }

            onPinchFinished: {
                pdfView.returnToBounds();

                // This is a bit expensive, so it's safer to put it here.
                // It won't be called on desktop (where PinchArea is not used),
                // but it's not a problem at the moment (our target is phone).
                window.releaseResources();
            }
        }

        Item { id: _zoomHelper }
    }


    Scrollbar { flickableItem: pdfView }
    Scrollbar { flickableItem: pdfView; align: Qt.AlignBottom }

    PDF.Document {
        id: poppler

        property bool isLoading: true
        path: file.path

        onPagesLoaded: {
            isLoading = false;

            var title = getDocumentInfo("Title")
            if (title !== "")
                pdfPage.title = title;
        }
    }


    /*** ACTIONS ***/

    Action {
        id: searchText
        iconName: "search"
        // onTriggered: pageMain.state = "search"
        //Disable it until we provide search in Poppler plugin.
        enabled: false
    }

    Action {
        id: goToPage
        objectName:"gotopage"
        iconName: "browser-tabs"
        text: i18n.tr("Go to page...")
        onTriggered: PopupUtils.open(Qt.resolvedUrl("PdfViewGotoDialog.qml"), targetPage)
    }

    Action {
        id: nightModeToggle
        iconName: "night-mode"
        text: mainView.nightModeEnabled ? i18n.tr("Disable night mode") : i18n.tr("Enable night mode")
        onTriggered: mainView.nightModeEnabled = !mainView.nightModeEnabled
    }

    Action {
        id: fileDetails
        objectName: "detailsAction"
        text: i18n.tr("Details")
        iconName: "info"
        onTriggered: pageStack.push(Qt.resolvedUrl("../common/DetailsPage.qml"))
    }
}
