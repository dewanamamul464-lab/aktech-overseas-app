import 'package:flutter/material.dart';

class CountryList extends StatelessWidget {
  final List<String> countries;        // dynamic list of country names
  final Function(String) onSelected;   // callback when tapped

  const CountryList({
    Key? key,
    required this.countries,
    required this.onSelected,
  }) : super(key: key);

  // Simple flag emoji mapping (you can expand this)
  String _getFlag(String country) {
    switch (country.toLowerCase()) {
      case "japan":
        return "🇯🇵";
      case "south korea":
        return "🇰🇷";
      case "germany":
        return "🇩🇪";
      case "nepal":
        return "🇳🇵";
      case "india":
        return "🇮🇳";
      case "united arab emirates":
        return "🇦🇪";
      case "qatar":
        return "🇶🇦";
      case "saudi arabia":
        return "🇸🇦";
      case "malaysia":
        return "🇲🇾";
      case "singapore":
        return "🇸🇬";
      case "australia":
        return "🇦🇺";
      case "canada":
        return "🇨🇦";
      case "united states":
        return "🇺🇸";
      case "united kingdom":
        return "🇬🇧";
      default:
        return "🌍"; // fallback icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: countries.map((country) {
        return GestureDetector(
          onTap: () => onSelected(country),
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getFlag(country),
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  country,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
