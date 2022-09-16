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

import Foundation
import DiskArbitration

public class DeviceManager {
    
    fileprivate var diskBsds : [String] = []
    
    init() {
        if let session : DASession = DASessionCreate(CFAllocatorGetDefault().takeRetainedValue()) {
            let pointer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())

            DARegisterDiskAppearedCallback(
                session,
                nil,
                _volumeDetectedCallback,
                pointer)
            
            let runloop : CFRunLoop = CFRunLoopGetCurrent()
            
            DASessionScheduleWithRunLoop(session, runloop, CFRunLoopMode.defaultMode.rawValue)
            CFRunLoopStop(runloop)
            CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.05, false)            
            DAUnregisterCallback(session, pointer, nil)
        }
        
    }
    
    public func query() -> [Disk] {
        if let session : DASession =
            DASessionCreate(CFAllocatorGetDefault().takeRetainedValue()) {
        
            var disks : [Disk] = diskBsds.reduce(into: []) { disks, diskBsd in
                if (!_isPartition(disk: diskBsd)) {
                    if let disk : DADisk = DADiskCreateFromBSDName(kCFAllocatorDefault, session, NSString(string: diskBsd).utf8String!) {
                        if let diskDescription : [String: AnyObject] = DADiskCopyDescription(disk) as? [String: AnyObject] {
                            
                            let disk : Disk = _deviceFromNameAndDescription(diskBsd: diskBsd, diskDescription: diskDescription)
                            
                            disks.append(disk)
                        }
                    }
                }
            }
            
            let volumeKeys = [URLResourceKey.volumeNameKey, URLResourceKey.volumeLocalizedNameKey]
            if let volumePaths = FileManager().mountedVolumeURLs(includingResourceValuesForKeys: volumeKeys, options: []) {
                for path in volumePaths {
                    if let volumeDisk : DADisk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, path as CFURL) {
                        if let bsdName = DADiskGetBSDName(volumeDisk) {
                            
                            let strBsdName = String(cString: bsdName)
                            let volume = try? path.resourceValues(forKeys: [URLResourceKey.volumeLocalizedNameKey]).allValues[URLResourceKey.volumeLocalizedNameKey]
                            
                            let offsetIndex = strBsdName.index(strBsdName.startIndex, offsetBy: 5)
                            let substringIndex = strBsdName[offsetIndex...].firstIndex(of: "s")!
                            
                            let diskBsdName = strBsdName[strBsdName.startIndex..<substringIndex]
                            
                            for i in 0..<disks.count {
                                if ("/dev/\(diskBsdName)" == disks[i].device) {
                                    disks[i].mountpoints.append(Mountpoint.init(path: path.path, label: volume as? String))
                                }
                            }
                        }
                    }
                }
            }

            return disks
            
        }
        
        return []
    }
    
    private func _isPartition(disk: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: "disk\\d+s\\d+")
        return regex?.firstMatch(in: disk, options: [], range: NSRange(disk.startIndex..<disk.endIndex,
                                                                      in: disk)) != nil
    }
    
    private func _isCard(diskDescription: [String: AnyObject]) -> Bool {
        if let iconDictionary : [String: AnyObject] = diskDescription[kDADiskDescriptionMediaIconKey as String] as? [String: AnyObject] {
            if let iconFileName : String = iconDictionary["IOBundleResourceFile"] as? String {
                return "SD.icns" == iconFileName
            }
        }
        
        return false;
    }
    
    private func _deviceFromNameAndDescription(diskBsd: String, diskDescription: [String: AnyObject]) -> Disk {
        let deviceProtocol : String? = diskDescription[kDADiskDescriptionDeviceProtocolKey as String] as? String
        let blockSize : UInt32? = diskDescription[kDADiskDescriptionMediaBlockSizeKey as String] as? UInt32
        let internalValue : Bool = diskDescription[kDADiskDescriptionDeviceInternalKey as String] as? Bool ?? false
        let removable : Bool = diskDescription[kDADiskDescriptionMediaRemovableKey as String] as? Bool ?? false
        let ejectable : Bool = diskDescription[kDADiskDescriptionMediaEjectableKey as String] as? Bool ?? false
        let mediaContent : String? = diskDescription[kDADiskDescriptionMediaContentKey as String] as? String
        let partitionTableType : PartitionTableType = "GUID_partition_scheme" == mediaContent ? PartitionTableType.gpt : PartitionTableType.mbr
        let devicePath : String? = diskDescription[kDADiskDescriptionBusPathKey as String] as? String
        let description : String? = diskDescription[kDADiskDescriptionMediaNameKey as String] as? String
        let size : UInt64? = diskDescription[kDADiskDescriptionMediaSizeKey as String] as? UInt64
        let readOnly : Bool = diskDescription[kDADiskDescriptionMediaWritableKey as String] as? Bool ?? false
        let scsi : Bool = ["SATA", "SCSI", "ATA", "IDE", "PCI"].contains(deviceProtocol ?? "")
        let virtual : Bool = "Virtual Interface" == (deviceProtocol ?? "")
        let usb : Bool = "USB" == (deviceProtocol ?? "")
        let card : Bool = _isCard(diskDescription: diskDescription)

        return Disk.init(busType: deviceProtocol, busVersion: nil, busVersionNull: true, device: "/dev/\(diskBsd)", devicePath: devicePath, devicePathNull: devicePath != nil, raw: "/dev/r\(diskBsd)", description: description, error: nil, partitionTableType: partitionTableType, size: size ?? 0, blockSize: blockSize ?? 512, logicalBlockSize: blockSize ?? 512, readOnly: readOnly, system: internalValue && !removable, virtual: virtual, removable: removable || ejectable, card: card, SCSI: scsi, USB: usb, UAS: false, UASNull: true)
    }
            
}

fileprivate func _volumeDetectedCallback(disk: DADisk, pointer: UnsafeMutableRawPointer?) {
    if let name = DADiskGetBSDName(disk) {
        let strName : String = String(cString:name)
        let repository : DeviceManager = Unmanaged<DeviceManager>.fromOpaque(pointer!).takeUnretainedValue()
        
        repository.diskBsds.append(strName)
    }
}
