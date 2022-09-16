/*
 * Copyright (c) 2022 Angelo Cassano
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

import 'dart:convert';
import 'dart:io';

import 'package:disks_desktop/disks_desktop.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MethodChannel methodChannel;
  late DisksRepository disksRepository;

  setUp(() {
    methodChannel = const MethodChannel('disks');
    disksRepository = DisksRepository(channel: methodChannel);
  });

  testWidgets('get disks from windows platform', (tester) async {
    final jsonString =
        File('test/windows/method_channel.json').readAsStringSync();
    final json = jsonDecode(jsonString);

    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (call) async {
      if (call.method == 'query') {
        return await json;
      }

      return null;
    });

    final disks = await disksRepository.query;

    expect(disks, isNotNull);
    expect(disks, isNotEmpty);
    expect(disks.length, 2);

    var i = 0;
    while (i < disks.length) {
      expect(disks[i].blockSize, json[i]["blockSize"]);
      expect(disks[i].busType, json[i]["busType"]);
      expect(disks[i].busVersion, json[i]["busVersion"]);
      expect(disks[i].description, json[i]["description"]);
      expect(disks[i].device, json[i]["device"]);
      expect(disks[i].devicePath, json[i]["devicePath"]);
      expect(disks[i].error, json[i]["error"]);
      expect(disks[i].card, json[i]["card"]);
      expect(disks[i].readOnly, json[i]["readOnly"]);
      expect(disks[i].removable, json[i]["removable"]);
      expect(disks[i].scsi, json[i]["scsi"]);
      expect(disks[i].system, json[i]["system"]);
      expect(disks[i].uas, json[i]["uas"]);
      expect(disks[i].usb, json[i]["usb"]);
      expect(disks[i].virtual, json[i]["virtual"]);
      expect(disks[i].logicalBlockSize, json[i]["logicalBlockSize"]);
      expect(disks[i].raw, json[i]["raw"]);
      expect(disks[i].size, json[i]["size"]);
      expect(disks[i].partitionTableType?.name, json[i]["partitionTableType"]);

      var j = 0;
      while (j < disks[i].mountpoints.length) {
        expect(disks[i].mountpoints[j].path, json[i]["mountpoints"][j]["path"]);
        expect(
            disks[i].mountpoints[j].label, json[i]["mountpoints"][j]["label"]);

        j++;
      }

      i++;
    }
  });
}
