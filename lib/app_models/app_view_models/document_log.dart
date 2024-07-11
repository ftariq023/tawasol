import 'package:intl/intl.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';

import '../app_utilities/app_ui_helper.dart';
import '../service_models/service_urls.dart';

class DocumentLog {
  late int id;
  late String _vsId;
  int? _senderId;
  String _enSender = '';
  String _arSender = '';
  int? _receiverId;
  String _enReceiver = '';
  String _arReceiver = '';
  int? _actionID;
  String _enAction = '';
  String _arAction = '';
  int? _docStatusId;
  String _enDocStatus = '';
  String _arDocStatus = '';
  int? _date;
  String comment = '';

  DocumentLog.fromEmpty(dynamic item, String vsId, bool isFullHistory) {
    try {
      _vsId = vsId;

      String senderType = isFullHistory ? 'actionByInfo' : 'userFromInfo';
      if (item[senderType] != null) {
        _arSender = item[senderType]['arName'];
        _enSender = item[senderType]['enName'];
        _senderId = item[senderType]['id'];
      }
      String receiverType = isFullHistory ? 'actionToInfo' : 'userToInfo';
      if (item[receiverType] != null) {
        _arReceiver = item[receiverType]['arName'];
        _enReceiver = item[receiverType]['enName'];
        _receiverId = item[receiverType]['id'];
      }
      String actionType = isFullHistory ? 'actionTypeInfo' : 'workflowActionInfo';
      if (item[actionType] != null) {
        _actionID = item[actionType]['id'];
        _arAction = item[actionType]['arName'];
        _enAction = item[actionType]['enName'];
      } else if (item['actionTypeInfo'] != null) {
        _actionID = item['workflowActionInfo']['id'];
        _arAction = item['workflowActionInfo']['arName'];
        _enAction = item['workflowActionInfo']['enName'];
      }
      if (item['documentStatusInfo'] != null) {
        _docStatusId = item['documentStatusInfo']['id'];
        _arDocStatus = item['documentStatusInfo']['arName'];
        _enDocStatus = item['documentStatusInfo']['enName'];
      }
      _date = item['actionDate'];
      comment = item['comments'] ?? '';
    } catch (e) {
      print(e);
    }
  }

  String get sender => AppHelper.isCurrentArabic ? _arSender : _enSender;

  String get receiver => AppHelper.isCurrentArabic ? _arReceiver : _enReceiver;

  String get action => AppHelper.isCurrentArabic ? _arAction : _enAction;

  String get userComment => comment;

  String get docStatus => AppHelper.isCurrentArabic ? _arDocStatus : _enDocStatus;

  DateTime get dateString => AppUIHelper.timeStampToDate(int.parse(_date.toString()));

  String get actionName => action.isNotEmpty ? action : docStatus;

  String get actionDate => DateFormat().addPattern(AppDefaults.dateFormat).format(dateString);

  String get actionAndDate => '${action.isNotEmpty ? action : docStatus} - ${DateFormat().addPattern(AppDefaults.dateFormat).format(dateString)}';
}
