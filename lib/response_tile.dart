import 'package:flutter/material.dart';

class ResponseTile extends StatelessWidget {
  const ResponseTile(
      {super.key,
      required this.isInput,
      required this.time,
      required this.response});
  final bool isInput;
  final DateTime time;
  final String response;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isInput ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
              color: isInput ? Colors.green[300] : Colors.green[400],
              borderRadius: BorderRadius.circular(15)),
          margin: EdgeInsets.only(
              left: isInput ? 20 : 0, right: isInput ? 0 : 20, top: 10),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          width: 200,
          child: Column(
            crossAxisAlignment:
                isInput ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                response,
                style: const TextStyle(color: Colors.black),
              ),
              Row(
                mainAxisAlignment:
                    isInput ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  Text(
                    '${time.hour}:${time.minute}:${time.second}',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
