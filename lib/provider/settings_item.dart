import 'package:dan_xi/provider/settings_provider.dart';
import 'package:dan_xi/util/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


abstract class SettingsItem<T> {
  final String key;
  final T defaultValue;

  const SettingsItem(this.key, this.defaultValue);

  T? get value;

  set value(T? val);

  T getValueOrDefault() {
    return value ?? defaultValue;
  }

  void removeKey(){
    SettingsProvider.getInstance().preferences.remove(key);
  }
}

class StringSettingsItem extends SettingsItem<String> {
  const StringSettingsItem(super.key, super.defaultValue);
  
  @override
  String? get value{
    return SettingsProvider.getInstance().preferences.getString(key);
  }
  
  @override
  set value(String? val) {
    if(val == null){
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setString(key, val);
  }
}

// T must be Json serializable
class ListSettingsItem<T> extends SettingsItem<List<T>> {
  const ListSettingsItem(super.key, super.defaultValue);

  @override
  List<T>? get value{
    return SettingsProvider.getInstance().preferences.getList<T>(key);
  }
  
  @override
  set value(List<T>? val) {
    if(val == null){
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setList<T>(key, val);
  }
}

class IntSettingsItem extends SettingsItem<int> {
  const IntSettingsItem(super.key, super.defaultValue);

  @override
  int? get value{
    return SettingsProvider.getInstance().preferences.getInt(key);
  }
  
  @override
  set value(int? val) {
    if(val == null){
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setInt(key, val);
  }
}

class DoubleSettingsItem extends SettingsItem<double> {
  const DoubleSettingsItem(super.key, super.defaultValue);

  @override
  double? get value{
    return SettingsProvider.getInstance().preferences.getDouble(key);
  }
  
  @override
  set value(double? val) {
    if(val == null){
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setDouble(key, val);
  }
}

class BoolSettingsItem extends SettingsItem<bool> {
  const BoolSettingsItem(super.key, super.defaultValue);

  @override
  bool? get value{
    return SettingsProvider.getInstance().preferences.getBool(key);
  }
  
  @override
  set value(bool? val) {
    if(val == null){
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setBool(key, val);
  }
}

class SettingsItemDecorator<T, V> extends SettingsItem<V> {
  final T Function(V) forwardConvertor;
  final V Function(T) backwardConvertor;
  final SettingsItem<T> innerItem;
  final V? overrideDefault;

  SettingsItemDecorator(
      this.innerItem, this.forwardConvertor, this.backwardConvertor,
      {this.overrideDefault})
      : super(innerItem.key,
            overrideDefault ?? backwardConvertor(innerItem.defaultValue));

  @override
  V? get value{
    final rawValue = innerItem.value;
    return rawValue == null ? null : backwardConvertor(rawValue);
  }
  
  @override
  set value(V? val) {
    if(val == null){
      innerItem.value = null;
      return;
    }

    innerItem.value = forwardConvertor(val);
  }

  @override
  V getValueOrDefault() {
    final rawValue = innerItem.value;
    return rawValue == null ? defaultValue : backwardConvertor(rawValue);
  }
}
