/*
 * Copyright 2017 balena.io
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <flutter/standard_method_codec.h>

#include <vector>
#include "drivelist.hpp"

class DriveListWorker {
public:
    explicit DriveListWorker(){}

    ~DriveListWorker() {}

    flutter::EncodableList GetDevices() {
        flutter::EncodableList encodedDevices;
        std::vector<Drivelist::DeviceDescriptor> devices = Drivelist::ListStorageDevices();

        for (Drivelist::DeviceDescriptor device : devices) {
            flutter::EncodableList encodedMountpoints;
            for (int i = 0; i < device.mountpoints.size(); i++) {
                std::string path = device.mountpoints[i];
                std::string label;

                if (i < device.mountpointLabels.size()) {
                    label = device.mountpointLabels[i];
                }

                flutter::EncodableMap encodedMountpoint = {
                    {flutter::EncodableValue("path"), flutter::EncodableValue(path)},
                    {flutter::EncodableValue("label"), flutter::EncodableValue(label)},
                };

                encodedMountpoints.push_back(encodedMountpoint);
            }

            flutter::EncodableMap encodedDevice = {
                {flutter::EncodableValue("blockSize"), flutter::EncodableValue(device.blockSize)},
                {flutter::EncodableValue("busType"), flutter::EncodableValue(device.busType)},
                {flutter::EncodableValue("busVersion"), flutter::EncodableValue(device.busVersion)},
                {flutter::EncodableValue("description"), flutter::EncodableValue(device.description)},
                {flutter::EncodableValue("device"), flutter::EncodableValue(device.device)},
                {flutter::EncodableValue("devicePath"), flutter::EncodableValue(device.devicePath)},
                {flutter::EncodableValue("error"), flutter::EncodableValue(device.error)},
                {flutter::EncodableValue("card"), flutter::EncodableValue(device.isCard)},
                {flutter::EncodableValue("readOnly"), flutter::EncodableValue(device.isReadOnly)},
                {flutter::EncodableValue("removable"), flutter::EncodableValue(device.isRemovable)},
                {flutter::EncodableValue("scsi"), flutter::EncodableValue(device.isSCSI)},
                {flutter::EncodableValue("system"), flutter::EncodableValue(device.isSystem)},
                {flutter::EncodableValue("uas"), flutter::EncodableValue(device.isUAS)},
                {flutter::EncodableValue("usb"), flutter::EncodableValue(device.isUSB)},
                {flutter::EncodableValue("virtual"), flutter::EncodableValue(device.isVirtual)},
                {flutter::EncodableValue("logicalBlockSize"), flutter::EncodableValue(device.logicalBlockSize)},
                {flutter::EncodableValue("mountpoints"), encodedMountpoints},
                {flutter::EncodableValue("raw"), flutter::EncodableValue(device.raw)},
                {flutter::EncodableValue("size"), flutter::EncodableValue(device.size)},
                {flutter::EncodableValue("partitionTableType"), flutter::EncodableValue(device.partitionTableType)},
            };

            encodedDevices.push_back(encodedDevice);

        }

         return encodedDevices;
    }
};
