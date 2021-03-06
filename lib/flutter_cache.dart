library flutter_cache;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache/Parse.dart';

class Cache {

  String key;

  /* Cache Content*/
  String contentKey;
  var content;

  /* Cache Content's Type*/
  String typeKey;
  String type;

  /* Cache Expiry*/
  int expiredAfter;

  /*
  * Cache Class Constructors Section
  */
  Cache (key, data) {
    Map parsedData = Parse.content(data);

    this.key = key;
    this.setContent(parsedData['content']);
    this.setType(parsedData['type']);
  }

  Cache.rebuild (key) {
    this.key = key;
  }

  /*
  * Cache Class Setters & Getters
  */  
  setKey (String key) {
    this.key = key;
  }

  setContent (var data , [String contentKey]) {
    this.content = data;
    this.contentKey = contentKey ?? this._generateCompositeKey('content');
  }

  setType (String type , [String typeKey]) {
    this.type = type;
    this.typeKey = typeKey  ?? this._generateCompositeKey('type');
  }

  setExpiredAfter (int expiredAfter) {
    this.expiredAfter = expiredAfter + Cache._currentTimeInSeconds();
  }

  /*
  * This function will return cached data if exist, 
  * If not exist, will create new cached data.
  * 
  * @return Cache.content
  */
  static Future remember (String key, var data, [int expiredAt]) async {
    if (await Cache.load(key) == null) {
      if (data is Function) {
        data = await data();
      }

      return Cache.write(key, data, expiredAt);
    }

    return Cache.load(key);
  }

  /*
  * This will overwrite data if exist and create new if not.
  *
  * @return Cache.content
  */
  static Future write (String key, var data, [int expiredAfter]) async {

    Cache cache = new Cache(key, data);
    if (expiredAfter != null) 
      cache.setExpiredAfter(expiredAfter);

    cache._save(cache);

    return Cache.load(key);
  }

  /*
  * load saved cached data.
  *
  * @return Cache.content
  */
  static Future load (String key, [bool list = false]) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Guard
    if (prefs.getString(key) == null) 
      return null;

    if (Cache._isExpired(prefs.getInt(key + 'ExpiredAt'))) {
      Cache.destroy(key);
      return null;
    }
  
    Map keys          = jsonDecode(prefs.getString(key));
    Cache cache       = new Cache.rebuild(key);
    String cacheType  = prefs.getString(keys['type']);
    var cacheContent;

    if (cacheType == 'String')        
      cacheContent =  prefs.getString(keys['content']);

    if (cacheType == 'Map')           
      cacheContent = jsonDecode(prefs.getString(keys['content']));

    if (cacheType == 'List<String>')  
      cacheContent = prefs.getStringList(keys['content']);

    if (cacheType == 'List<Map>')     
      cacheContent = (prefs.getStringList(keys['content'])).map((i) => jsonDecode(i)).toList();

    cache.setContent(cacheContent, keys['content']);
    cache.setType(cacheType, keys['type']);

    return cache.content;
  }

  /*
  * Saved cached contents into Shared Preference
  *
  * @return void
  */
  void _save (Cache cache) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();    

    // set Origincal Cache key to cache content's key and cache type's key
    prefs.setString(cache.key, jsonEncode({
      'content' : cache.contentKey,
      'type'    : cache.typeKey
    }));

    if (cache.content is String) 
      prefs.setString(cache.contentKey, cache.content);

    if (cache.content is List) 
      prefs.setStringList(cache.contentKey, cache.content);
      
    if (cache.expiredAfter != null) 
      prefs.setInt(key + 'ExpiredAt', cache.expiredAfter);

    prefs.setString(cache.typeKey, cache.type);
  }

  /*
  * will clear all shared preference data
  *
  * @return void
  */
  static void clear () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  /*
  * unset single shared preference key
  *
  * @return void
  */
  static void destroy (String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map keys                = jsonDecode(prefs.getString(key));

    // remove all cache trace
    prefs.remove(key);
    prefs.remove(keys['content']);
    prefs.remove(keys['type']);
    prefs.remove(key + 'ExpiredAt');
  }

  /*
  * Cache Class Helper Function Section
  *
  * This is where all custom functions used by this class reside.
  * All functions should be private.
  */
  String _generateCompositeKey(String keyType) {
    return keyType + Cache._currentTimeInSeconds().toString() + this.key;
  }

  static int _currentTimeInSeconds() {
    var ms = (new DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  static bool _isExpired(int cacheExpiryInfo) {
    if (cacheExpiryInfo != null && cacheExpiryInfo < Cache._currentTimeInSeconds()) {
      return true;
    }

    return false;
  }
}