abstract class Brand {
  String get appName;

  Uri get baseUrl;
}

class Vialer extends Brand {
  @override
  final String appName = 'Vialer';

  @override
  final Uri baseUrl = Uri.parse('https://partner.voipgrid.nl');
}

class Voys extends Brand {
  @override
  final String appName = 'Voys';

  @override
  final Uri baseUrl = Uri.parse('https://freedom.voys.nl');
}
