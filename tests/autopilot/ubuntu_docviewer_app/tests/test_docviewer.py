# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Docviewer app autopilot tests."""

from __future__ import absolute_import

from pprint import pprint

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals

from ubuntu_docviewer_app.tests import DocviewerTestCase


class TestMainWindow(DocviewerTestCase):

    def setUp(self):
        super(TestMainWindow, self).setUp()

    def tearDown(self):
        super(TestMainWindow, self).tearDown()

    def test_open_text_file(self):
        
		filePath = 'ubuntu_docviewer_app/files/plaintext.txt'

        self.launch_test_local(filePath)
	
		#Check if the app is correclty launched
		self.assertThat(
            self.ubuntusdk.get_qml_view().visible, Eventually(Equals(True)))

		textArea = self.ubuntusdk.get_object("TextArea", "textAreaMain")

		#Check if textarea is no longer empty
		self.assertThat(
			textArea.text, Eventually(NotEquals(False)))

	def test_read_text_file_mimeType(self):
		filePath = 'ubuntu_docviewer_app/files/plaintext.txt'

        self.launch_test_local(filePath)

		mimetypeItem = self.ubuntusdk.get_object("SingleValue", "mimetypeItem")
		
		self.assertThat(
			mimetypeItem.value, Eventually(NotEquals(False)))




