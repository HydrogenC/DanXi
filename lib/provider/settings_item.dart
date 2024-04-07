import 'package:dan_xi/provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class SettingsItem<T> with ChangeNotifier {
  final String key;
  final T defaultValue;

  SettingsItem(this.key, this.defaultValue);

  T? get value;

  set value(T? val);

  ChangeNotifierProvider get provider;

  T get valueOrDefault => value ?? defaultValue;

  void removeKey() {
    SettingsProvider.getInstance().preferences.remove(key);
    notifyListeners();
  }
}

class StringSettingsItem extends SettingsItem<String> {
  StringSettingsItem(super.key, super.defaultValue);

  late final ChangeNotifierProvider<StringSettingsItem> _provider =
      ChangeNotifierProvider((ref) => this);

  @override
  ChangeNotifierProvider<StringSettingsItem> get provider => _provider;

  @override
  String? get value {
    return SettingsProvider.getInstance().preferences.getString(key);
  }

  @override
  set value(String? val) {
    notifyListeners();
    if (val == null) {
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setString(key, val);
  }
}

// T must be Json serializable
class ListSettingsItem<T> extends SettingsItem<List<T>> {
  ListSettingsItem(super.key, super.defaultValue);

  late final ChangeNotifierProvider<ListSettingsItem<T>> _provider =
      ChangeNotifierProvider((ref) => this);

  @override
  ChangeNotifierProvider<ListSettingsItem<T>> get provider => _provider;

  @override
  List<T>? get value {
    return SettingsProvider.getInstance().preferences.getList<T>(key);
  }

  @override
  set value(List<T>? val) {
    notifyListeners();
    if (val == null) {
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setList<T>(key, val);
  }
}

class IntSettingsItem extends SettingsItem<int> {
  IntSettingsItem(super.key, super.defaultValue);

  late final ChangeNotifierProvider<IntSettingsItem> _provider =
      ChangeNotifierProvider((ref) => this);

  @override
  ChangeNotifierProvider<IntSettingsItem> get provider => _provider;

  @override
  int? get value {
    return SettingsProvider.getInstance().preferences.getInt(key);
  }

  @override
  set value(int? val) {
    notifyListeners();
    if (val == null) {
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setInt(key, val);
  }
}

class DoubleSettingsItem extends SettingsItem<double> {
  DoubleSettingsItem(super.key, super.defaultValue);

  late final ChangeNotifierProvider<DoubleSettingsItem> _provider =
      ChangeNotifierProvider((ref) => this);

  @override
  ChangeNotifierProvider<DoubleSettingsItem> get provider => _provider;

  @override
  double? get value {
    return SettingsProvider.getInstance().preferences.getDouble(key);
  }

  @override
  set value(double? val) {
    notifyListeners();
    if (val == null) {
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setDouble(key, val);
  }
}

class BoolSettingsItem extends SettingsItem<bool> {
  BoolSettingsItem(super.key, super.defaultValue);

  late final ChangeNotifierProvider<BoolSettingsItem> _provider =
      ChangeNotifierProvider((ref) => this);

  @override
  ChangeNotifierProvider<BoolSettingsItem> get provider => _provider;

  @override
  bool? get value {
    return SettingsProvider.getInstance().preferences.getBool(key);
  }

  @override
  set value(bool? val) {
    notifyListeners();
    if (val == null) {
      removeKey();
      return;
    }

    SettingsProvider.getInstance().preferences.setBool(key, val);
  }
}

class DecoratedSettingsItem<T, V> extends SettingsItem<V> {
  final T Function(V) forwardConvertor;
  final V Function(T) backwardConvertor;
  final SettingsItem<T> innerItem;
  final V? overrideDefault;

  late final ChangeNotifierProvider<DecoratedSettingsItem<T, V>> _provider =
      ChangeNotifierProvider((ref) => this);

  @override
  ChangeNotifierProvider<DecoratedSettingsItem<T, V>> get provider => _provider;

  DecoratedSettingsItem(
      this.innerItem, this.forwardConvertor, this.backwardConvertor,
      {this.overrideDefault})
      : super(innerItem.key,
            overrideDefault ?? backwardConvertor(innerItem.defaultValue));

  @override
  V? get value {
    final rawValue = innerItem.value;
    return rawValue == null ? null : backwardConvertor(rawValue);
  }

  @override
  set value(V? val) {
    notifyListeners();
    if (val == null) {
      innerItem.value = null;
      return;
    }

    innerItem.value = forwardConvertor(val);
  }

  @override
  V get valueOrDefault {
    final rawValue = innerItem.value;
    return rawValue == null ? defaultValue : backwardConvertor(rawValue);
  }
}
