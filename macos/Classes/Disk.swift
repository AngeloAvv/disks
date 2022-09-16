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

enum PartitionTableType {
    case mbr
    case gpt
}

public struct Mountpoint {
    let path : String
    let label: String?
    
    public func toMap() -> [String: Any?] {
        return [
            "path": path,
            "label": label,
        ]
    }
}

public struct Disk {
    let busType : String?
    let busVersion : String?
    let busVersionNull : Bool
    let device : String
    let devicePath : String?
    let devicePathNull : Bool
    let raw : String
    let description : String?
    let error : String?
    let partitionTableType : PartitionTableType
    let size : UInt64
    let blockSize : UInt32
    let logicalBlockSize : UInt32
    var mountpoints : [Mountpoint] = []
    let readOnly : Bool
    let system : Bool
    let virtual : Bool
    let removable : Bool
    let card : Bool
    let SCSI : Bool
    let USB : Bool
    let UAS : Bool
    let UASNull : Bool
    
    public func toMap() -> [String: Any?] {
        return [
            "blockSize": blockSize,
            "busType": busType,
            "busVersion": busVersion,
            "description": description,
            "device": device,
            "devicePath": devicePath,
            "error": error,
            "card": card,
            "readOnly": readOnly,
            "removable": removable,
            "scsi": SCSI,
            "system": self.system,
            "uas": UAS,
            "usb": USB,
            "virtual": virtual,
            "logicalBlockSize": logicalBlockSize,
            "mountpoints": mountpoints.map { $0.toMap() },
            "raw": raw,
            "size": size,
            "partitionTableType": partitionTableType == PartitionTableType.gpt ? "gpt" : "mbr",
        ]
    }
};
