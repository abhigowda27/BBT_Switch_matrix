class RouterDetails {
  late String switchID;
  late String switchName;
  late String routerName;
  late String routerPassword;
  late String? selectedFan;
  late List<String> switchTypes;
  late String? iPAddress;
  late String switchPasskey;

  RouterDetails({
    required this.switchID,
    required this.routerName,
    required this.routerPassword,
    required this.iPAddress,
    required this.selectedFan,
    required this.switchTypes,
    required this.switchPasskey,
    required this.switchName,
  });

  RouterDetails.fromJson(Map<String, dynamic> json) {
    switchID = json['SwitchId'];
    switchName = json['SwitchName'];
    routerName = json['RouterName'];
    routerPassword = json['RouterPassword'];
    selectedFan = json['SelectedFan'];
    switchTypes = List<String>.from(json['SwitchTypes'] ?? []);
    switchPasskey = json['SwitchPassKey'];
    iPAddress = json['IPAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SwitchId'] = switchID;
    data['SwitchName'] = switchName;
    data['RouterName'] = routerName;
    data['RouterPassword'] = routerPassword;
    data['SwitchTypes'] = switchTypes;
    data['SelectedFan'] = selectedFan;
    data['SwitchPassKey'] = switchPasskey;
    data['IPAddress'] = iPAddress;
    return data;
  }

  String toRouterQR() {
    return "ROUTER,$switchID,$switchName,$routerName,$routerPassword,$switchPasskey,$selectedFan,$iPAddress,$switchTypes";
  }

  String routerQRGroup() {
    return "$switchID,$switchName,$switchPasskey,${switchTypes.length},$selectedFan,$iPAddress";
  }
}
