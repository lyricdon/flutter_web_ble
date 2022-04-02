import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:gl_web_ble/c_cmd.dart';
import 'package:gl_web_ble/c_uuid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 搜索设备和服务时的条件
  Company filterCompany = Company(CompanyType.xsj);

  // 当前选中设备
  BluetoothDevice? device;

  // 当前特征值
  BluetoothCharacteristic? character;

  final customCMD = TextEditingController();

  void _requestDevice() async {
    List<String> serves = BluetoothDefaultServiceUUIDS.VALUES.map((e) => e.uuid).toList();
    List<RequestFilterBuilder> filters = <RequestFilterBuilder>[];

    // 设备可查询的服务
    if (filterCompany.serviceUUID.isNotEmpty) {
      serves.add(filterCompany.serviceUUID);
    }

    // 设备过滤前缀
    if (filterCompany.devicePrefixName.isNotEmpty) {
      for (var prefix in filterCompany.devicePrefixName) {
        filters.add(RequestFilterBuilder(namePrefix: prefix));
      }
    }

    RequestOptionsBuilder requestOptions;
    if (filters.isNotEmpty) {
      requestOptions = RequestOptionsBuilder(filters, optionalServices: serves);
    } else {
      requestOptions = RequestOptionsBuilder.acceptAllDevices(optionalServices: serves);
    }
    device = await FlutterWebBluetooth.instance.requestDevice(requestOptions);
    setState(() {
      device?.connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: FlutterWebBluetooth.instance.isAvailable,
      initialData: false,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final available = snapshot.requireData;
        return Scaffold(
          backgroundColor: const Color(0xFFEEEEEE),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF111111),
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              Row(
                children: [
                  const Text(
                    '蓝牙功能: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    available ? '正常' : '异常',
                    style: TextStyle(
                      fontSize: 12,
                      color: available ? const Color(0xFF111111) : Colors.red,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 12,
                ),
                Text(
                  '当前蓝牙搜索筛选项:   ${filterCompany.companyName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Builder(
                  builder: (_) {
                    var xsj = Company(CompanyType.xsj);
                    bool xsjSel = filterCompany.type == CompanyType.xsj;
                    return Column(
                      children: [
                        // xsj
                        Tooltip(
                          message: '新世举',
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(23)),
                                border: Border.all(
                                  color: xsjSel ? Colors.blue : Colors.transparent,
                                  width: 1,
                                ),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Wrap(
                                alignment: WrapAlignment.spaceEvenly,
                                spacing: 8.0,
                                runAlignment: WrapAlignment.center,
                                runSpacing: 8.0,
                                children: [
                                  Offstage(
                                    offstage: !xsjSel,
                                    child: const Icon(
                                      Icons.check_circle_outlined,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    '来源厂家: ${xsj.companyName}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                  Text(
                                    '设备名称前缀: ${xsj.devicePrefixName.join(', ')}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                  Text(
                                    '服务UUID: ${xsj.serviceUUID}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                  Text(
                                    '特征UUID: ${xsj.characterUUID}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                ],
                              ),
                              width: double.infinity,
                            ),
                            onTap: () {
                              if (!xsjSel) {
                                setState(() {
                                  filterCompany = xsj;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: device == null
                      ? const Center(
                          child: Text('请先选择设备'),
                        )
                      : StreamBuilder<bool>(
                          stream: device?.connected,
                          initialData: false,
                          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                            final connected = snapshot.requireData;
                            if (!connected) {
                              character = null;
                            }
                            return Column(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(23)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4, //阴影范围
                                        spreadRadius: 0, //阴影浓度
                                        color: Color(0x0D000000), //阴影颜色
                                      ),
                                    ],
                                  ),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SelectableText('设备名称:   ' + (device?.name ?? '-')),
                                            connected ? StreamBuilder<List<BluetoothService>>(
                                              stream: device?.services,
                                              initialData: const [],
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<List<BluetoothService>> serviceSnapshot) {
                                                if (serviceSnapshot.hasError) {
                                                  final error = serviceSnapshot.error.toString();
                                                  debugPrint('Error!: $error');
                                                  return Center(
                                                    child: Text(error),
                                                  );
                                                }

                                                final services = serviceSnapshot.requireData;
                                                if (services.isEmpty) {
                                                  return const Text('查找服务中...');
                                                }

                                                BluetoothService? serve;
                                                String matchUUID = '无';
                                                for (var value in services) {
                                                  if (filterCompany.serviceUUID.toLowerCase() == value.uuid.toLowerCase()) {
                                                    matchUUID = value.uuid;
                                                    serve = value;
                                                  }
                                                }
                                                if (character == null ||
                                                    filterCompany.characterUUID.toLowerCase() !=
                                                        character?.uuid.toLowerCase()) {
                                                  serve?.getCharacteristics().then((value) {
                                                    for (var tmp in value) {
                                                      if (filterCompany.characterUUID.toLowerCase() ==
                                                          tmp.uuid.toLowerCase()) {
                                                        setState(() {
                                                          character = tmp;
                                                          character?.startNotifications();
                                                          character?.value.listen((event) {
                                                            debugPrint('readValue' + event.toString());
                                                          });
                                                        });
                                                      }
                                                    }
                                                  });
                                                }
                                                return SelectableText(
                                                  '已匹配服务:   $matchUUID',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                );
                                              },
                                            ) : const SizedBox(),
                                            Offstage(
                                              child: SelectableText(
                                                characterDesc,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              offstage: character == null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          connected ? device?.disconnect() : device?.connect();
                                          if (connected) {
                                            character = null;
                                            sendModels = <CommandModel>[];
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text(
                                            connected ? '断开连接' : '连接',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF111111),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                character == null ? const SizedBox() : Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: 24,
                                  runSpacing: 16,
                                  children: [
                                    const SizedBox(
                                      height: 1,
                                      width: double.infinity,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        sendCommand(CommandType.open);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text(
                                          '开门',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        sendCommand(CommandType.restart);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text(
                                          '重启',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        sendCommand(CommandType.time);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text(
                                          '设置时间',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height:22,
                                          child: TextField(
                                            controller: customCMD,
                                            decoration: InputDecoration(
                                              isCollapsed: true,
                                              border: const OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              hintText: '请输入自定义指令,如: abc, 如: [97,98,99]',
                                              suffix: ElevatedButton(
                                                onPressed: () {
                                                  sendCommand(CommandType.custom, customCMD.text);
                                                },
                                                child: const Text(
                                                  ' 发送 ',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF111111),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    // height: 250,
                                    child: Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(23)),
                                          color: Color(0xaaaaaaaa),
                                        ),
                                        margin: const EdgeInsets.symmetric(vertical: 18),
                                        padding: const EdgeInsets.all(18),
                                        child: buildTextField()),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _requestDevice,
            tooltip: '添加蓝牙设备',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  String get characterDesc {
    if (character == null) {
      return '';
    }
    var str = '已匹配特征:   ${character?.uuid}    ';
    var pro = character!.properties;
    if (pro.broadcast) {
      str += '广播  ';
    }
    if (pro.read) {
      str += '可读  ';
    }
    if (pro.write) {
      str += '可写  ';
    }
    if (pro.writeWithoutResponse) {
      str += '可写(无回复)  ';
    }
    if (pro.indicate) {
      str += '暗示  ';
    }
    if (pro.notify) {
      str += '通知  ';
    }
    if (pro.broadcast) {
      str += '广播  ';
    }
    return str;
  }

  List<CommandModel> sendModels = <CommandModel>[];

  // 发送指令
  sendCommand(CommandType type, [String? strData]) async {
    // await device!.connect();
    // var serves = await device!.discoverServices();
    // print('serves: ${serves.length}');
    // BluetoothService serve = serves.where((element) => element.uuid.toLowerCase() == filterCompany.serviceUUID.toLowerCase()).first;
    // print('serve: ${serve.uuid}');
    // BluetoothCharacteristic cha = await serve.getCharacteristic(filterCompany.characterUUID);
    // print('cha: ${cha.uuid}');

    List models = CommandUtil.getCMD(type, filterCompany.type, strData);
    for (var i = 0; i < models.length; ++i) {
      var model = models[i];
      var data = Uint8List.fromList(model.request ?? []);

      try {
        debugPrint('开始发送指令' + data.toString() + data.length.toString());
        await character?.writeValueWithResponse(data);
        model.finish = true;
      } catch (e) {
        model.finish = false;
        model.response = e.toString();
      }
      sendModels.add(model);
    }

    setState(() {});
  }

  SelectableText buildTextField() {
    List<InlineSpan> spans = <InlineSpan>[];
    if (sendModels.isNotEmpty) {
      for (var i = sendModels.length - 1; i >= 0; i--) {
        var o = sendModels[i];
        spans.add(
          const TextSpan(
            text: '\n指令名称',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: ': [${o.name}]    ',
          ),
        );
        if (o.finish != null && o.finish!) {
          spans.add(
            const TextSpan(
              text: '发送成功',
              style: TextStyle(
                color: Colors.green,
              ),
            ),
          );
        }
        spans.add(
          const TextSpan(
            text: '\n指令内容',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: ':\n ${o.request}',
          ),
        );
        spans.add(
          const TextSpan(
            text: '\n指令回调',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        );
        spans.add(
          TextSpan(
            text: ':\n ${o.response} \n',
          ),
        );
      }
    }

    return SelectableText.rich(
      TextSpan(
        style: const TextStyle(color: Color(0xff111111), fontSize: 12),
        children: [
          WidgetSpan(
            child: TextButton(
              onPressed: () {
                setState(() {
                  sendModels = <CommandModel>[];
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.cleaning_services_rounded,
                    size: 14,
                  ),
                  Text('清空'),
                ],
              ),
            ),
          ),
          ...spans
        ],
      ),
      scrollPhysics: const BouncingScrollPhysics(),
    );
  }
}
