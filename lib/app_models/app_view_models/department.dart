import 'package:tawasol/app_models/app_utilities/app_helper.dart';



class DepartmentModel{
int? ouId;
String enOuName='';
String arOuName='';
bool? isStatusActive;
String get ouName=>AppHelper.isCurrentArabic?arOuName:enOuName;
bool? hasRegistry;

int? regOuId;
String arRegOuName='';
String enRegOuName='';
String get regOuName=>AppHelper.isCurrentArabic?arRegOuName:enRegOuName;



DepartmentModel.forEmpty(dynamic item){
  ouId=item['id'];
  arOuName=item['arName'];
  enOuName=item['enName'];
  isStatusActive=item['status'];
  hasRegistry=item['hasRegistry'];
  regOuId=item['regouInfo']['id'];
  arRegOuName=item['regouInfo']['arName'];
  enRegOuName=item['regouInfo']['enName'];

}
}