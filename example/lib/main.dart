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

import 'package:disks_desktop/disks_desktop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => Provider(
        create: (context) => DisksRepository(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Builder(
              builder: (context) => FutureBuilder<List<Disk>>(
                future: context.watch<DisksRepository>().query,
                builder: (context, snapshot) => snapshot.hasData
                    ? _body(context, disks: snapshot.data!)
                    : _loading(),
              ),
            ),
          ),
        ),
      );

  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _body(
    BuildContext context, {
    required List<Disk> disks,
  }) =>
      Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              'Available disks',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.black),
            ),
            _devices(disks),
          ],
        ),
      );

  Widget _devices(List<Disk> disks) => Expanded(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => _device(context, disk: disks[index]),
          separatorBuilder: (_, __) => const SizedBox(width: 32),
          itemCount: disks.length,
        ),
      );

  Widget _device(
    BuildContext context, {
    required Disk disk,
  }) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.save, size: 128),
              Text(
                disk.device,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('blockSize: ${disk.blockSize}'),
              Text('busType: ${disk.busType}'),
              Text('busVersion: ${disk.busVersion}'),
              Text('description: ${disk.description}'),
              Text('devicePath: ${disk.devicePath}'),
              Text('error: ${disk.error}'),
              Text('card: ${disk.card}'),
              Text('readOnly: ${disk.readOnly}'),
              Text('removable: ${disk.removable}'),
              Text('scsi: ${disk.scsi}'),
              Text('system: ${disk.system}'),
              Text('uas: ${disk.uas}'),
              Text('usb: ${disk.usb}'),
              Text('virtual: ${disk.virtual}'),
              Text('logicalBlockSize: ${disk.logicalBlockSize}'),
              Text('raw: ${disk.raw}'),
              Text('size: ${disk.size}'),
              Text('partitionTableType: ${disk.partitionTableType}'),
              Text(
                  'mountpoints: ${disk.mountpoints.map((mountpoint) => '${mountpoint.label} => ${mountpoint.path}').join(', ')}'),
            ],
          ),
        ),
      );
}
