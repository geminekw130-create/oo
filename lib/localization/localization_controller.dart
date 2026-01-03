import 'package:motoboy/data/api_client.dart';
import 'package:motoboy/localization/language_model.dart';
import 'package:motoboy/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

class LocalizationController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;

  LocalizationController({required this.sharedPreferences}) {
    loadCurrentLanguage();
  }

  Locale _locale = Locale(
    AppConstants.languages[0].languageCode,
    AppConstants.languages[0].countryCode,
  );

  bool _isLtr = true;
  int _selectIndex = 0;
  List<LanguageModel> _languages = [];
  bool isLoading = false;

  Locale get locale => _locale;
  bool get isLtr => _isLtr;
  int get selectIndex => _selectIndex;
  List<LanguageModel> get languages => _languages;

  /// Força sempre pt_BR
  Future<void> setLanguage(Locale locale) async {
    locale = const Locale('pt', 'BR');

    Get.updateLocale(locale);
    _locale = locale;
    _isLtr = !intl.Bidi.isRtlLanguage(_locale.languageCode);

    await saveLanguage(_locale);

    isLoading = true;
    update();

    Get.find<ApiClient>().updateHeader(
      sharedPreferences.getString(AppConstants.token) ?? '',
      sharedPreferences.getString(AppConstants.languageCode),
      'latitude',
      'longitude',
      sharedPreferences.getString(AppConstants.zoneId) ?? '',
    );

    backendLanguageUpdate();
  }

  /// Carrega idioma fixo pt_BR
  Future<void> loadCurrentLanguage() async {
    _locale = const Locale('pt', 'BR');
    _isLtr = !intl.Bidi.isRtlLanguage(_locale.languageCode);
    _selectIndex = 0;

    await saveLanguage(_locale);
    update();
  }

  /// Salva idioma localmente
  Future<void> saveLanguage(Locale locale) async {
    await sharedPreferences.setString(
      AppConstants.languageCode,
      locale.languageCode,
    );
    await sharedPreferences.setString(
      AppConstants.countryCode,
      locale.countryCode!,
    );
  }

  void setSelectIndex(int index) {
    _selectIndex = index;
    update();
  }

  void searchLanguage(String query, BuildContext context) {
    if (query.isEmpty) {
      _languages.clear();
      _languages = AppConstants.languages;
      update();
    } else {
      _selectIndex = -1;
      _languages = [];
      for (LanguageModel language in AppConstants.languages) {
        if (language.languageName
            .toLowerCase()
            .contains(query.toLowerCase())) {
          _languages.add(language);
        }
      }
      update();
    }
  }

  void initializeAllLanguages(BuildContext context) {
    if (_languages.isEmpty) {
      _languages.clear();
      _languages = AppConstants.languages;
    }
  }

  void setInitialIndex() {
    for (int i = 0; i < AppConstants.languages.length; i++) {
      if (locale.languageCode ==
          AppConstants.languages[i].languageCode) {
        _selectIndex = i;
      }
    }
  }

  void backendLanguageUpdate() {
    Get.find<ApiClient>().postData(
      AppConstants.changeLanguage,
      {},
    );
  }

  bool haveLocalLanguageCode() {
    return sharedPreferences.containsKey(AppConstants.languageCode);
  }
}