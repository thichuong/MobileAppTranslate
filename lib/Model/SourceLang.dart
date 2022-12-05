class SourceLang
{
  SourceLang._();
  /// the one and only instance of this singleton
  static final instance = SourceLang._();
  String _text = '';
  String _languagefrom = 'en';
  String _languageto = 'vi';

  set  Text(String text) => {this._text = text};
  String get Text => _text;

  set  languageFrom(String language) => {this._languagefrom = language};
  String get languageFrom => _languagefrom;

  set  languageTo(String language) => {this._languageto = language};
  String get languageTo => _languageto;
}