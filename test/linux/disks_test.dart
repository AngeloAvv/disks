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

import 'dart:io';

import 'package:disks_desktop/disks_desktop.dart';
import 'package:disks_desktop/src/linux/lsblk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'disks_test.mocks.dart';

@GenerateMocks([Lsblk])
void main() {
  late Lsblk lsblk;
  late DisksRepository disksRepository;

  setUp(() {
    lsblk = MockLsblk();
    disksRepository = DisksRepository(lsblk: lsblk);
  });

  test('get disks from linux platform', () async {
    final jsonString = File('test/linux/lsblk.json').readAsStringSync();
    when(lsblk.query).thenAnswer((_) async => jsonString);

    final disks = await disksRepository.query;

    expect(disks, isNotNull);
    expect(disks, isNotEmpty);
    expect(disks.length, 2);

    expect(disks.first.blockSize, 512);
    expect(disks.first.busType, "NVME");
    expect(disks.first.busVersion, isNull);
    expect(disks.first.description,
        "GIGABYTE GP-ASM2NE6100TTTD /boot/efi, /, [SWAP]");
    expect(disks.first.device, "/dev/nvme0n1");
    expect(disks.first.devicePath, isNull);
    expect(disks.first.error, isNull);
    expect(disks.first.card, isNull);
    expect(disks.first.readOnly, false);
    expect(disks.first.removable, false);
    expect(disks.first.scsi, false);
    expect(disks.first.system, true);
    expect(disks.first.uas, isNull);
    expect(disks.first.usb, false);
    expect(disks.first.virtual, false);
    expect(disks.first.logicalBlockSize, 512);
    expect(disks.first.mountpoints[0].path, "/boot/efi");
    expect(disks.first.mountpoints[1].path, "/");
    expect(disks.first.mountpoints[2].path, "[SWAP]");
    expect(disks.first.mountpoints[0].label, isNull);
    expect(disks.first.mountpoints[1].label, isNull);
    expect(disks.first.mountpoints[2].label, isNull);
    expect(disks.first.raw, "/dev/nvme0n1");
    expect(disks.first.size, 1000204886016);
    expect(disks.first.partitionTableType, PartitionTableType.gpt);

    expect(disks.last.blockSize, 512);
    expect(disks.last.busType, "NVME");
    expect(disks.last.busVersion, isNull);
    expect(disks.last.description, "Samsung SSD 970 EVO Plus 1TB");
    expect(disks.last.device, "/dev/nvme1n1");
    expect(disks.last.devicePath, isNull);
    expect(disks.last.error, isNull);
    expect(disks.last.card, isNull);
    expect(disks.last.readOnly, false);
    expect(disks.last.removable, false);
    expect(disks.last.scsi, false);
    expect(disks.last.system, true);
    expect(disks.last.uas, isNull);
    expect(disks.last.usb, false);
    expect(disks.last.virtual, false);
    expect(disks.last.logicalBlockSize, 512);
    expect(disks.last.mountpoints, isEmpty);
    expect(disks.last.raw, "/dev/nvme1n1");
    expect(disks.last.size, 1000204886016);
    expect(disks.last.partitionTableType, PartitionTableType.gpt);
  });
}
