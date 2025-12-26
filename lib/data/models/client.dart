class Client {
  final int? id;
  final String firstName;
  final String lastName;
  final String title;
  final String dic;  // DIČ
  final String ico;  // IČO
  final String rc;   // RČ
  final String street;
  final String city;
  final String zip;
  final String country;
  final String naceText;
  final String iban;

  const Client({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.dic,
    required this.ico,
    required this.rc,
    required this.street,
    required this.city,
    required this.zip,
    required this.country,
    required this.naceText,
    required this.iban,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'title': title,
        'dic': dic,
        'ico': ico,
        'rc': rc,
        'street': street,
        'city': city,
        'zip': zip,
        'country': country,
        'naceText': naceText,
        'iban': iban,
      };

  static Client fromMap(Map<String, Object?> m) => Client(
        id: m['id'] as int?,
        firstName: (m['firstName'] ?? '') as String,
        lastName: (m['lastName'] ?? '') as String,
        title: (m['title'] ?? '') as String,
        dic: (m['dic'] ?? '') as String,
        ico: (m['ico'] ?? '') as String,
        rc: (m['rc'] ?? '') as String,
        street: (m['street'] ?? '') as String,
        city: (m['city'] ?? '') as String,
        zip: (m['zip'] ?? '') as String,
        country: (m['country'] ?? '') as String,
        naceText: (m['naceText'] ?? '') as String,
        iban: (m['iban'] ?? '') as String,
      );
}
