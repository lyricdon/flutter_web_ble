
import 'dart:convert';

import 'package:gl_web_ble/c_uuid.dart';

enum CommandType {
  open, wifi, config, restart, time, reset, custom
}

class CommandModel {
    String? name;
    List<int>? request;
    bool? finish;
    dynamic response;

    CommandModel({this.name, this.request});
}

class CommandUtil {

  static List<CommandModel> getCMD(CommandType type, CompanyType companyType, [String? data]) {
    List<CommandModel> models = <CommandModel>[];
    CommandModel model = CommandModel();
    switch(companyType) {
      case CompanyType.xsj: {
        switch(type) {
          case CommandType.open: {
            model.name = '开门';
            // 7EC056CDBDAC02EF7A45EC5C5CEA18BD17C01555
            model.request = [2, 2, 242, 1, 0, 40, 55, 69, 68, 70, 53, 54, 67, 68, 65, 57, 57, 68, 69, 52, 49, 48, 55, 65, 52, 51, 51, 57, 67, 48, 53, 67, 69, 68, 65, 55, 55, 49, 52, 68, 70, 54, 55, 53, 51, 66, 48, 3];
            break;
          }
          case CommandType.config: {
            break;
          }
          case CommandType.restart: {
            model.name = '重启设备';
            model.request = [83, 75, 67, 70, 71, 123, 34, 109, 97, 99, 34, 58, 34, 54, 54, 55, 48, 67, 69, 66, 65, 34, 44, 34, 103, 114, 111, 117, 112, 34, 58, 56, 48, 48, 49, 44, 34, 114, 101, 115, 116, 97, 114, 116, 34, 58, 49, 125];
            break;
          }
          case CommandType.reset: {
            model.name = '恢复出厂设置';

            break;
          }
          case CommandType.time: {
            model.name = '设置时间';
            model.request = [83, 75, 67, 70, 71, 123, 34, 109, 97, 99, 34, 58, 34, 54, 54, 55, 48, 67, 69, 66, 65, 34, 44, 34, 103, 114, 111, 117, 112, 34, 58, 49, 48, 48, 49, 44, 34, 100, 97, 116, 101, 84, 105, 109, 101, 34, 58, 34, 50, 48, 50, 50, 45, 48, 51, 45, 50, 56, 32, 49, 52, 58, 53, 50, 58, 50, 50, 34, 125];
            break;
          }
          case CommandType.wifi: {
            model.name = '配置wifi';
            //"SKCFG{"mac":"6670CEBA","group":6002,"wifiSsid":"a","wifiPassword":"a"}"
            var content = 'SKCFG{"mac":"6670CEBA","group":6002}';
            content = content.replaceFirst('}', "$data}");
            model.request = utf8.encode(content);
            break;
          }
          case CommandType.custom: {
            model.name = '自定义';
            try {
              bool start = data!.startsWith('[');
              bool end = data.endsWith(']');
              if (start && end) {
                var dataStr = data.substring(1,data.length-1);
                var list = dataStr.split(',');
                model.request = list.map((e) => int.parse(e)).toList();
              } else {
                model.request = utf8.encode(data);
              }
            } catch (e) {
              model.response = e.toString();
            }
            break;
          }
          default:
            break;
        }
        break;
      }
      default:
        break;
    }

    models.add(model);
    return models;
  }
}