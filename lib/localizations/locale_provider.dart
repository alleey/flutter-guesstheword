import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class CustomChangeNotifier<T> extends ChangeNotifier {
  T _value;

  CustomChangeNotifier(this._value);

  T get value => _value;

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }
}

class LocaleProvider extends CustomChangeNotifier<Locale> {
  LocaleProvider(super.value);
}

extension LocaleProviderExtensions on BuildContext {

  Locale get locale
    => Provider.of<LocaleProvider>(this, listen: false).value;

  void changeLanguage(String languageCode)
    => Provider.of<LocaleProvider>(this, listen: false).value = Locale(languageCode, '');
}
