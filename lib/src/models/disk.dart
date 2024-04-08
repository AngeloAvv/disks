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

import "package:equatable/equatable.dart";
import "package:path/path.dart" as path;

enum PartitionTableType { mbr, gpt }

class Mountpoint extends Equatable {
  final String path;
  final String? label;

  const Mountpoint({
    required this.path,
    this.label,
  });

  factory Mountpoint.fromMap(Map<String, dynamic> map) => Mountpoint(
        path: map['path'],
        label: map['label'],
      );

  factory Mountpoint.fromLsblk(Map<String, dynamic> mountpoint) => Mountpoint(
        path: mountpoint["mountpoint"],
        label: mountpoint["label"] ?? mountpoint["partlabel"],
      );

  @override
  List<Object?> get props => [path, label];

  @override
  String toString() => "Mountpoint{path: $path, label: $label}";
}

class Disk extends Equatable {
  final int blockSize;
  final String busType;
  final String? busVersion;
  final String description;
  final String device;
  final String? devicePath;
  final String? error;
  final bool? card;
  final bool readOnly;
  final bool removable;
  final bool? scsi;
  final bool system;
  final bool? uas;
  final bool? usb;
  final bool? virtual;
  final int logicalBlockSize;
  final List<Mountpoint> mountpoints;
  final String raw;
  final int? size;
  final PartitionTableType? partitionTableType;

  const Disk({
    required this.blockSize,
    required this.busType,
    this.busVersion,
    required this.description,
    required this.device,
    this.devicePath,
    this.error,
    this.card,
    required this.readOnly,
    required this.removable,
    this.scsi,
    required this.system,
    this.uas,
    this.usb,
    this.virtual,
    required this.logicalBlockSize,
    required this.mountpoints,
    required this.raw,
    this.size,
    this.partitionTableType,
  });

  factory Disk.fromMap(Map<String, dynamic> map) => Disk(
        blockSize: map['blockSize'],
        busType: map['busType'],
        busVersion: map['busVersion'],
        description: map['description'],
        device: map['device'],
        devicePath: map['devicePath'],
        error: map['error'],
        card: map['card'],
        readOnly: map['readOnly'],
        removable: map['removable'],
        scsi: map['scsi'],
        system: map['system'],
        uas: map['uas'],
        usb: map['usb'],
        virtual: map['virtual'],
        logicalBlockSize: map['logicalBlockSize'],
        mountpoints: ((map['mountpoints'] ?? []) as List)
            .map((e) => Mountpoint.fromMap(Map.from(e)))
            .toList(growable: false),
        raw: map['raw'],
        size: map['size'],
        partitionTableType: map['partitionTableType'] == 'gpt' ? PartitionTableType.gpt : PartitionTableType.mbr,
      );

  factory Disk.fromLsblk(Map<String, dynamic> device) {
    String? getDeviceName(String? value) {
      if (value != null) {
        return !path.isAbsolute(value) ? path.absolute("/dev", value) : value;
      }

      return null;
    }

    PartitionTableType? getPartitionTableType(String? value) => value == "gpt"
        ? PartitionTableType.gpt
        : value == "dos"
            ? PartitionTableType.mbr
            : null;

    String getDescription() {
      var description = <String>[
        device["label"] ?? "",
        device["vendor"] ?? "",
        device["model"] ?? "",
      ];
      if (device["children"] != null) {
        final subLabels = (device["children"] as List)
            .where((children) => children["label"] != null
                ? children["label"] != device["label"]
                : children["mountpoint"] != null)
            .map((children) => children["label"] ?? children["mountpoint"]);
        if (subLabels.isNotEmpty) {
          description.add(subLabels.join(", "));
        }
      }
      return description.join(" ").replaceAll(r"/\s+/g", " ").trim();
    }

    final name = getDeviceName(device["name"]);
    final kname = getDeviceName(device["kname"]);
    final virtual =
        RegExp(r"/^(block)$/i").hasMatch(device["subsystems"] ?? "");
    final scsi =
        RegExp(r"/^(sata|scsi|ata|ide|pci)$/i").hasMatch(device["tran"] ?? "");
    final usb = RegExp(r"/^(usb)$/i").hasMatch(device["tran"] ?? "");
    final readonly = device["ro"]?.toString() == '1';
    final removable = device["rm"]?.toString() == '1'|| device["hotplug"]?.toString() == '1' || virtual;

    return Disk(
      busType: (device["tran"] ?? "UNKNOWN").toUpperCase(),
      device: name ?? "",
      raw: kname ?? name ?? "",
      description: getDescription(),
      size: int.tryParse(device["size"]?.toString() ?? ""),
      blockSize: int.tryParse(device["phy-sec"]?.toString() ?? "") ?? 512,
      logicalBlockSize: int.tryParse(device["log-sec"]?.toString() ?? "") ?? 512,
      mountpoints: ((device["children"] ?? [device]) as List)
          .where((mountpoint) => mountpoint["mountpoint"] != null)
          .map((mountpoint) => Mountpoint.fromLsblk(mountpoint))
          .toList(growable: false),
      readOnly: readonly,
      system: !removable && !virtual,
      virtual: virtual,
      removable: removable,
      scsi: scsi,
      usb: usb,
      partitionTableType: getPartitionTableType(device["pttype"]),
    );
  }

  @override
  List<Object?> get props => [
        blockSize,
        busType,
        busVersion,
        description,
        device,
        devicePath,
        error,
        card,
        readOnly,
        removable,
        scsi,
        system,
        uas,
        usb,
        virtual,
        logicalBlockSize,
        mountpoints,
        raw,
        size,
        partitionTableType,
      ];

  @override
  String toString() =>
      "Disk{blockSize: $blockSize, busType: $busType, busVersion: $busVersion, description: $description, device: $device, devicePath: $devicePath, error: $error, card: $card, readOnly: $readOnly, removable: $removable, scsi: $scsi, system: $system, uas: $uas, usb: $usb, virtual: $virtual, logicalBlockSize: $logicalBlockSize, mountpoints: $mountpoints, raw: $raw, size: $size, partitionTableType: $partitionTableType}";
}


