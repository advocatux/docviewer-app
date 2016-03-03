/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

PageHeader {
    id: defaultHeader

    property var view: parent.view
    property Page parentPage: parent

    title: i18n.tr("Documents")
   // flickable: view

    // FIXME: Why need this?!
    leadingActionBar.actions: null

    trailingActionBar.actions: [
        Action {
            text: i18n.tr("Search...")
            iconName: "search"
            onTriggered: parentPage.searchMode = true
            visible: folderModel.count !== 0
        },

        Action {
            text: i18n.tr("Sorting settings...")
            iconName: "settings"
            onTriggered: PopupUtils.open(Qt.resolvedUrl("SortSettingsDialog.qml"))
            visible: folderModel.count !== 0
        }
    ]
}
