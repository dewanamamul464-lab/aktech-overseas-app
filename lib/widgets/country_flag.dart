import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';

class CountryFlagWidget extends StatelessWidget {
  final String country;
  final double size;

  const CountryFlagWidget({
    super.key,
    required this.country,
    this.size = 32,
  });

  static const Map<String, String> countryCodes = {
    "nepal": "NP",
    "india": "IN",
    "japan": "JP",
    "south korea": "KR",
    "korea": "KR",
    "china": "CN",
    "malaysia": "MY",
    "singapore": "SG",
    "qatar": "QA",
    "uae": "AE",
    "united arab emirates": "AE",
    "saudi arabia": "SA",
    "germany": "DE",
    "usa": "US",
    "united states": "US",
    "canada": "CA",
    "australia": "AU",
    "united kingdom": "GB",
    "uk": "GB",
    "poland": "PL",
    "romania": "RO",
    "croatia": "HR",
    "portugal": "PT",
    "finland": "FI",
    "norway": "NO",
    "italy": "IT",
    "france": "FR",
    "spain": "ES",
    "switzerland": "CH",
    "new zealand": "NZ",
    "ireland": "IE",
    "denmark": "DK",
    "sweden": "SE",
    "netherlands": "NL",
    "belgium": "BE",
    "oman": "OM",
    "kuwait": "KW",
    "bahrain": "BH",
    "israel": "IL",
    "turkey": "TR",
    "thailand": "TH",
    "vietnam": "VN",
    "philippines": "PH",
    "indonesia": "ID",
    "bangladesh": "BD",
    "pakistan": "PK",
    "sri lanka": "LK",
    "maldives": "MV",
  };

  @override
  Widget build(BuildContext context) {
    final code = countryCodes[country.trim().toLowerCase()];

    // Unknown country → show generic globe icon
    if (code == null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.blue.shade100,
        child: Icon(
          Icons.public,
          color: Colors.blue,
          size: size * 0.7,
        ),
      );
    }
    // Country flag
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: size * 1.4,
        height: size,
        child: CountryFlag.fromCountryCode(
          code,
        ),
      ),
    );
  }
}