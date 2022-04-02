
import 'package:gatt/gatt.dart';

enum CompanyType {
  xsj, /// 新世举
}

class Company {
  String serviceUUID = '';
  String characterUUID = '';
  List<String> devicePrefixName = <String>[];
  String companyName;
  CompanyType type;

  factory Company(CompanyType type) {
    Company? com = _cacheCompanies[type];
    if (com == null) {
      if (type == CompanyType.xsj) {
        com = Company._inter(type, '新世举');
        com.serviceUUID = const SigGattId(0xFFE0).asUuid;
        com.characterUUID = const SigGattId(0xFFE1).asUuid;
        com.devicePrefixName = ['SK8'];
        _cacheCompanies[type] = com;
      }
    }
    return com!;
  }

  Company._inter(this.type, this.companyName);

  static final Map<CompanyType, Company> _cacheCompanies = <CompanyType, Company>{};
}