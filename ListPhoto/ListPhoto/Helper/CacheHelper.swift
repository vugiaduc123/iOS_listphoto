//
//  CacheHelper.swift
//  ListPhoto
//
//  Created by Vũ Đức on 18/12/24.
//

import Foundation

class CustomCache<KeyType: AnyObject, ObjectType: AnyObject> {
    private var cache = NSCache<KeyType, ObjectType>()
    private var count = 0

    func setObject(_ obj: ObjectType, forKey key: KeyType) {
        cache.setObject(obj, forKey: key)
        count += 1
    }

    func object(forKey key: KeyType) -> ObjectType? {
        return cache.object(forKey: key)
    }

    func removeObject(forKey key: KeyType) {
        cache.removeObject(forKey: key)
        count -= 1
    }

    func getObjectCount() -> Int {
        return count
    }

    func clearCache() {
        cache.removeAllObjects()
        count = 0
    }
}
