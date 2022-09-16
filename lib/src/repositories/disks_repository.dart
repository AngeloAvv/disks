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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:disks_desktop/src/exceptions/unsupported_platform_exception.dart';
import 'package:disks_desktop/src/linux/lsblk.dart';
import 'package:disks_desktop/src/models/disk.dart';
import 'package:flutter/services.dart';

class DisksRepository {
  final Lsblk _lsblk;
  final MethodChannel _channel;

  DisksRepository({
    MethodChannel? channel,
    Lsblk? lsblk,
  })  : _channel = channel ?? const MethodChannel('disks_desktop'),
        _lsblk = lsblk ?? Lsblk();

  Future<List<Disk>> get query async {
    if (Platform.isLinux) {
      final result = await _lsblk.query;
      final json = jsonDecode(result);

      return (json['blockdevices'] as List)
          .map((disk) => Disk.fromLsblk(disk as Map<String, dynamic>))
          .where(
            (disk) =>
                !disk.device.startsWith('/dev/loop') &&
                !disk.device.startsWith('/dev/sr') &&
                !disk.device.startsWith('/dev/ram'),
          )
          .toList(growable: false);
    } else if (Platform.isMacOS || Platform.isWindows) {
      final results = await _channel.invokeListMethod('query');
      return results
              ?.map((result) => Disk.fromMap(Map.from(result)))
              .toList(growable: false) ??
          [];
    }

    throw UnsupportedPlatformException(Platform.operatingSystem);
  }
}
