class Word {
  final int id;
  final String word;
  final String definition;
  final List<String> examples;
  final List<String> synonyms;
  final List<String> antonyms;

  Word({
    required this.id,
    required this.word,
    required this.definition,
    required this.examples,
    required this.synonyms,
    required this.antonyms,
  });

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['_id'] ?? 0,
      word: map['en_word'] ?? '',
      definition: map['en_definition'] ?? '',
      examples: map['example'] == null || map['example'] == ''
          ? []
          : (map['example'] as String).split('\n'),
      synonyms: map['example'] == null || map['example'] == ''
          ? []
          : (map['synonyms'] as String).split(','),
      antonyms: map['antonyms'] == 'NA' ||
              map['antonyms'] == null ||
              map['antonyms'] == ''
          ? []
          : (map['antonyms'] as String).split(','),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'en_word': word,
      'en_definition': definition,
      'example': examples.join('\n'),
      'synonyms': synonyms.join(','),
      'antonyms': antonyms.isEmpty ? 'NA' : antonyms.join(','),
    };
  }
}
