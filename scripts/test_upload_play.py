from pathlib import Path
import tempfile
import unittest
from unittest.mock import MagicMock

from upload_play import PlayError, upload


def response(data=None, status=200, headers=None):
    result = MagicMock(status_code=status, headers=headers or {})
    result.json.return_value = data or {}
    return result


class UploadTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.bundle = Path(self.temp.name) / 'test.aab'
        self.bundle.write_bytes(b'fake-bundle')
        self.session = MagicMock()
        self.session.post.side_effect = [
            response({'id': 'edit-1'}),
            response(headers={'Location': 'https://androidpublisher.googleapis.com/upload/session'}),
            response(), response(),
        ]
        self.session.get.return_value = response({'tracks': [{'releases': [{'versionCodes': ['100']}]}]})
        self.session.put.side_effect = [response({'versionCode': 101}), response()]

    def test_success_only_releases_internal_track(self):
        upload(self.session, 'com.tofu575.tappin', self.bundle, 101)
        calls = self.session.put.call_args_list
        self.assertTrue(calls[1].args[0].endswith('/tracks/internal'))
        self.assertEqual(calls[1].kwargs['json']['releases'][0]['versionCodes'], ['101'])
        self.assertTrue(self.session.post.call_args.args[0].endswith(':commit'))
        self.session.delete.assert_not_called()

    def test_existing_version_rejected_before_upload(self):
        with self.assertRaises(PlayError):
            upload(self.session, 'com.tofu575.tappin', self.bundle, 100)
        self.session.put.assert_not_called()
        self.session.delete.assert_called_once()

    def test_bad_upload_location_rejected(self):
        self.session.post.side_effect = [response({'id': 'edit-1'}), response(headers={'Location': 'https://evil.example/upload'})]
        with self.assertRaises(PlayError):
            upload(self.session, 'com.tofu575.tappin', self.bundle, 101)
        self.session.put.assert_not_called()
        self.session.delete.assert_called_once()

    def test_upload_error_never_commits_or_logs_response(self):
        self.session.put.side_effect = [response({'secret': 'never-print'}, status=403)]
        with self.assertRaisesRegex(PlayError, 'Upload bundle: Google Play API returned HTTP 403'):
            upload(self.session, 'com.tofu575.tappin', self.bundle, 101)
        self.assertEqual(self.session.post.call_count, 2)
        self.session.delete.assert_called_once()

    def test_unexpected_version_never_releases(self):
        self.session.put.side_effect = [response({'versionCode': 999})]
        with self.assertRaises(PlayError):
            upload(self.session, 'com.tofu575.tappin', self.bundle, 101)
        self.assertEqual(self.session.put.call_count, 1)
        self.session.delete.assert_called_once()


if __name__ == '__main__':
    unittest.main()
