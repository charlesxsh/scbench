import unittest
from errinj.pm import apply_changelog, ChangeLog

class TestApplyChangeLog(unittest.TestCase):
    def test_empty_input(self):
        lines = []
        changelogs = []
        self.assertEqual(apply_changelog(lines, changelogs), [])

    def test_single_changelog(self):
        lines = ["line1", "line2", "line3"]
        changelogs = [ChangeLog((1, 1), ["replacement"])]
        self.assertEqual(apply_changelog(lines, changelogs), ["replacement", "line2", "line3"])

    def test_multiple_changelogs(self):
        lines = ["line1", "line2", "line3", "line4"]
        changelogs = [ChangeLog((1, 2), ["new1", "new2"]), ChangeLog((3, 3), ["new4"])]
        self.assertEqual(apply_changelog(lines, changelogs), ["new1", "new2", "new4", "line4"])

    def test_remove_changelogs(self):
        lines = ["line1", "line2", "line3", "line4"]
        changelogs = [ChangeLog((1, 3), [])]
        self.assertEqual(apply_changelog(lines, changelogs), ["line4"])
    
    def test_more_to_less_changelogs(self):
        lines = ["line1", "line2", "line3", "line4"]
        changelogs = [ChangeLog((1, 3), ["new1"])]
        self.assertEqual(apply_changelog(lines, changelogs), ["new1", "line4"])

    def test_overlapping_changelogs(self):
        lines = ["line1", "line2", "line3", "line4"]
        changelogs = [ChangeLog((1, 2), ["new1"]), ChangeLog((2, 3), ["new2", "new3"])]
        self.assertEqual(apply_changelog(lines, changelogs), ["new1", "new2", "new3", "line4"])

    def test_out_of_order_changelogs(self):
        lines = ["line1", "line2", "line3", "line4"]
        changelogs = [ChangeLog((2, 3), ["new3"]), ChangeLog((1, 1), ["new2"])]
        self.assertEqual(apply_changelog(lines, changelogs), ["new2", "new3","line4"])