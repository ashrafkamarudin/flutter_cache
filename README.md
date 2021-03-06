# flutter_cache
[![Dependencies Status](https://img.shields.io/librariesio/github/sekolahcode/flutter_cache)](https://libraries.io/github/SekolahCode/flutter_cache)
[![file size](https://img.shields.io/github/size/sekolahcode/flutter_cache/lib/flutter_cache.dart)](https://img.shields.io/github/size/sekolahcode/flutter_cache/lib/flutter_cache.dart)
[![GitHub Issues](https://img.shields.io/github/issues/sekolahcode/flutter_cache)](https://github.com/SekolahCode/flutter_cache/issues)
[![follows on twitter](https://img.shields.io/twitter/follow/sekolahcode?label=Follow&style=social)](https://twitter.com/sekolahcode)

A simple cache package for flutter. This package is a wrapper for shared preference and makes working with shared preference easier. Once it has been installed, you can do these things.

```dart
// create new cache.
Cache.remember('key', 'data'); 
Cache.write('key', 'data'); 

// add Cache lifetime on create
Cache.remember('key', 'data', 120); 
Cache.write('key', 'data', 120); 

// load Cache by key
Cache.load('key'); // This will load the cache data.

// destroy single cache by key
Cache.destroy('key');

// destroy all cache
Cache.clear();

```
## Getting Started

### Installation

First include the package dependency in your project's `pubspec.yaml` file

```yaml
dependencies:
  flutter_cache: ^0.0.6
```

You can install the package via pub get:

```bash
flutter pub get
```

Then you can import it in your dart code like so

```dart
import 'package:flutter_cache/flutter_cache.dart';
```

### What Can this Package Do ?

1. Cache `String`, `Map`, `List<String>` and `List<Map>` for forever or for a limited time.
2. Load the cache you've cached.
3. Clear All Cache.
4. Clear Single Cache.

### Usage

#### Cache Fetch Data from API

If data already exist, then it will use the data in the cache. If it's not, It will fetch the data. You can also set Cache lifetime so your app would fetch again everytime the Cache dies.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

var test = await Cache.remember('servers', () async {
  var response = await http.get('http://dummy.restapiexample.com/api/v1/employees');
  return jsonDecode(response.body)['data'];
}, 120); // cache for 2 mins

// or 

// cache for 2 mins
var test = await Cache.remember(
    'servers', 
    () async => jsonDecode( 
        (await http.get( 'http://dummy.restapiexample.com/api/v1/employees' )
    ).body )['data']
, 120);
```

#### Saved data for limited time

The data will be destroyed when it reached the time you set.

```dart
Cache.remember('key', 'data', 120); // saved for 2 mins or 120 seconds
Cache.write('key', 'data', 120);
```

#### Cache multipe datatype

You can cache multiple datatype. Supported datatype for now are `String`, `Map`, `List<String>` and `List<Map>`. When you use `cache.load()` to get back the data, it will return the data in the original datatype.

```dart
Cache.remember('key', { 
  'name' : 'Ashraf Kamarudin',
  'depth2' : {
    'name' : 'depth2',
    'depth3' : {
      'name': 'depth3'
    } 
  }
});

Cache.load('key'); // will return data in map datatype.
```
