# Disks Desktop

<img align="center" src="https://raw.githubusercontent.com/AngeloAvv/disks/master/assets/disks_logo.png" width="350" alt="Disks logo" border="0">

Disks Desktop is Flutter desktop library able to retrieve the installed devices information

[![Pub](https://img.shields.io/pub/v/disks.svg)](https://pub.dev/packages/disks)
![Flutter CI](https://github.com/AngeloAvv/disks/workflows/Flutter%20CI/badge.svg)
[![Star on GitHub](https://img.shields.io/github/stars/AngeloAvv/disks.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/AngeloAvv/disks)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

If you want to support this project,

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/angeloavv)


With Disks Desktop  you can get access to disks' information like:
* block size
* bus type
* bus version
* description
* device name
* device path
* logical block size
* available mountpoints
* disk size
* partition table type
* is in error
* is a card
* is read only
* is removable
* is scsi
* is system
* is uas
* is usb
* is virtual
* is raw

### Installation

In general, put it under
[dependencies](https://dart.dev/tools/pub/dependencies),
in your [pubspec.yaml](https://dart.dev/tools/pub/pubspec):

```yaml
dependencies:
  disks_desktop: ^1.0.1
```

You can install packages from the command line:

```terminal
flutter pub get
```

or simply add it through the command line:

```terminal
flutter pub add disks_desktop
```

## Usage

To get the list of the available drives with their details, simply create an instance of a Disk Repository, and then invoke the query getter.

Example:
```dart
final repository = DiskRepository();
final disks = await repository.query;
```

You can also use it with a FutureBuilder:
```dart
FutureBuilder<List<Disk>>(
  future: DisksRepository().query,
  builder: (context, snapshot) => [...]
),
```

## License

Disks Desktop is available under the MIT license. See the LICENSE file for more info.
drivelist.cpp, drivelist.hpp, list.cpp and list.hpp are available under the Apache 2.0 license and belongs to balena.io

## Additional information
<a href="https://www.flaticon.com/free-icons/hard-disk" title="hard disk icons">Disks icon created by Freepik - Flaticon</a>