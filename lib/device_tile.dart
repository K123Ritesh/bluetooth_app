import 'package:flutter/material.dart';

class DeviceTile extends StatelessWidget {
  const DeviceTile(
      {super.key,
      required this.deviceName,
      required this.deviceId,
      required this.onclick});
  final String deviceName;
  final String deviceId;
  final Future Function() onclick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName.length > 25
                    ? deviceName.substring(0, 25)
                    : deviceName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              Text(
                deviceId,
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
            ],
          ),
          InkWell(
            onTap: onclick,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 75, 136, 242),
                  borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: const Text(
                'Connect',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Response {
  final String response;
  final DateTime time;
  final bool isInput;
  Response({required this.response, required this.time, required this.isInput});
}
