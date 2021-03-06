import 'dart:convert';

import 'package:flutter_cache/flutter_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {

  String string;
  Map map;
  Map map2;
  List<String> listString;
  List<Map> listMap;
  List<Map> listMap2;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    string = 'data';

    map = {
      'data1' : 'Ashraf Kamarudin',
      'data2' : 'Programmer'
    };

    map2 = { // multi depth map
      'name' : 'Ashraf Kamarudin',
      'depth2' : {
        'name' : 'depth2',
        'depth3' : {
          'name': 'depth3'
        } 
      }
    };

    listString = [
      'Ashraf',
      'Kamarudin'
    ];

    listMap = [
      {
        'name': 'Ashraf'
      },
      {
        'name': 'Kamarudin'
      }
    ];

    listMap2 = [ // multi depth list map
      {
        'name': 'Ashraf'
      },
      {
        'name': 'Kamarudin'
      },
      {
        'name': 'Kamarudin',
        'map': {
          'age': 'we'
        }
      },
    ];
  });

  test('It Can Cache Multiple Type', () async {
    expect(await Cache.write('string', string), string);
    expect(await Cache.write('map', map), map);
    expect(await Cache.write('map2', map2), map2);
    expect(await Cache.write('listString', listString), listString);
    expect(await Cache.write('listMap', listMap), listMap);
    expect(await Cache.write('listMap2', listMap2), listMap2);
  });

  test('It can load Cached data', () async {
    await Cache.write('string', string);
    await Cache.write('map', map);

    expect(await Cache.load('string'), string);
    expect(await Cache.load('map'), map);
  });

  test('It will load if data exist else create new then load', () async {
    Cache.write('existing', 'ExistingData');

    expect(await Cache.remember('string', string), string);
    expect(await Cache.remember('existing', 'NewData'), 'ExistingData');
  });
  
  test('It will remove cache data if passed expiry time', () async {
    Cache.write('willExpire', 'data', 2);

    expect(await Cache.load('willExpire'), 'data');

    await Future.delayed(const Duration(seconds: 3), (){});

    expect(await Cache.load('willExpire'), null);
  });

  test('It can use anonymous function', () async {

    await Cache.remember('key', () {
      return 'old';
    }, 5);

    expect(await Cache.remember('key', () {
      return 'new';
    }), 'old');

    await Future.delayed(const Duration(seconds: 6), (){});

    expect(await Cache.remember('key', () {
      return 'new';
    }), 'new');

    expect(await Cache.remember('string', () {
      return 'test';
    }), 'test');

    expect(await Cache.remember('string', () => 'test'), 'test');
  });

  test('It will load first then fetch', () async {

    await Cache.remember('key', () {
      return 'old';
    }, 5);

    expect(await Cache.remember('key', () {
      return 'new';
    }), 'old');

    await Future.delayed(const Duration(seconds: 6), (){});

    expect(await Cache.remember('key', () {
      return 'new';
    }), 'new');
  });

  test('It will delete all cache trace', () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await Cache.write('string', string, 10);

    // get all keys before destroy
    Map keys = jsonDecode(prefs.getString('string'));
    Cache.destroy('string');

    // to make sure it works without await
    await Future.delayed(const Duration(seconds: 5), (){});

    expect(prefs.getString('string'), null);
    expect(prefs.getString('string' + 'ExpiredAt'), null);
    expect(prefs.getString(keys['content']), null);
    expect(prefs.getString(keys['type']), null);
  });
}
