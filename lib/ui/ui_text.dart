import 'package:flutter/widgets.dart';

import '../l10n/l10n.dart';
import '../models/scan_log.dart';

String folderDisplayName(BuildContext context, String folderId, String name) {
  final l10n = context.l10n;
  if (folderId == 'history_folder') {
    return l10n.historyFolder;
  }
  if (folderId == 'favorites_folder') {
    return l10n.favoritesFolder;
  }
  return name;
}

String scanSourceDisplayName(BuildContext context, ScanLog log) {
  if (log.source == 'NFC') {
    if (log.apiType != 'nfc') {
      return context.l10n.sourceNfcWithType(log.displayType);
    }
    return 'NFC';
  }
  if (log.source == 'Direct') {
    return context.l10n.savedCardsSource;
  }
  return log.source;
}
