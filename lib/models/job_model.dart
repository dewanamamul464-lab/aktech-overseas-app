import 'dart:convert';

class Job {
  final int id;
  final String country;
  final String company;
  final String position;
  final String salary;
  final String jobType;
  final String description;
  final String requirements;
  final String experience;
  final int vacancies;
  final String expiryDate;
  final bool verified;
  final String source;
  final String sourceUrl;

  Job({
    required this.id,
    required this.country,
    required this.company,
    required this.position,
    required this.salary,
    required this.jobType,
    required this.description,
    required this.requirements,
    required this.experience,
    required this.vacancies,
    required this.expiryDate,
    required this.verified,
    required this.source,
    required this.sourceUrl,
  });

  // =========================================================
  // SAFE STRING
  // =========================================================
  //
  // Scraped API data can sometimes contain:
  //
  // null
  // numbers
  // booleans
  // empty values
  //
  // This prevents runtime type errors.
  //
  static String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString().trim();
  }

  // =========================================================
  // SAFE INTEGER
  // =========================================================

  static int _intValue(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString().trim(),
    ) ??
        0;
  }

  // =========================================================
  // SAFE BOOLEAN
  // =========================================================

  static bool _boolValue(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is String) {
      final normalized =
      value.trim().toLowerCase();

      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes';
    }

    if (value is num) {
      return value != 0;
    }

    return false;
  }

  // =========================================================
  // DECODE HTML ENTITIES
  // =========================================================
  //
  // Sometimes scraped APIs return HTML like:
  //
  // &lt;p&gt;We are looking for...&lt;/p&gt;
  //
  // instead of:
  //
  // <p>We are looking for...</p>
  //
  // flutter_html needs the actual HTML.
  //
  static String _decodeHtmlEntities(String value) {
    if (value.isEmpty) {
      return '';
    }

    String result = value;

    // Common HTML entities.
    result = result.replaceAll(
      '&nbsp;',
      ' ',
    );

    result = result.replaceAll(
      '&amp;',
      '&',
    );

    result = result.replaceAll(
      '&lt;',
      '<',
    );

    result = result.replaceAll(
      '&gt;',
      '>',
    );

    result = result.replaceAll(
      '&quot;',
      '"',
    );

    result = result.replaceAll(
      '&#39;',
      "'",
    );

    result = result.replaceAll(
      '&apos;',
      "'",
    );

    return result;
  }

  // =========================================================
  // PREPARE HTML
  // =========================================================

  static String _prepareHtml(dynamic value) {
    final stringValue =
    _stringValue(value);

    if (stringValue.isEmpty) {
      return '';
    }

    return _decodeHtmlEntities(
      stringValue,
    );
  }

  // =========================================================
  // FROM JSON
  // =========================================================

  factory Job.fromJson(
      Map<String, dynamic> json,
      ) {
    return Job(
      id: _intValue(
        json['id'],
      ),

      country: _stringValue(
        json['country'],
      ),

      company: _stringValue(
        json['company'],
      ),

      position: _stringValue(
        json['position'],
      ),

      salary: _stringValue(
        json['salary'],
      ),

      jobType: _stringValue(
        json['jobType'],
      ),

      // IMPORTANT:
      // Keep HTML here.
      //
      // JobDetailsScreen uses flutter_html
      // to render it properly.
      description: _prepareHtml(
        json['description'],
      ),

      // IMPORTANT:
      // Keep HTML here as well because requirements
      // can contain <ul>, <li>, <strong>, etc.
      requirements: _prepareHtml(
        json['requirements'],
      ),

      experience: _stringValue(
        json['experience'],
      ),

      vacancies: _intValue(
        json['vacancies'],
      ),

      expiryDate: _stringValue(
        json['expiryDate'],
      ),

      verified: _boolValue(
        json['verified'],
      ),

      source: _stringValue(
        json['source'],
      ),

      sourceUrl: _stringValue(
        json['sourceUrl'],
      ),
    );
  }

  // =========================================================
  // TO JSON
  // =========================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'company': company,
      'position': position,
      'salary': salary,
      'jobType': jobType,
      'description': description,
      'requirements': requirements,
      'experience': experience,
      'vacancies': vacancies,
      'expiryDate': expiryDate,
      'verified': verified,
      'source': source,
      'sourceUrl': sourceUrl,
    };
  }
}