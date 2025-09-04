import 'package:uuid/uuid.dart';

enum DreamType {
  lucid,
  nightmare,
  recurring,
  prophetic,
  healing,
  normal,
}

enum EmotionType {
  joy,
  fear,
  sadness,
  anger,
  love,
  anxiety,
  peace,
  confusion,
  excitement,
  nostalgia,
}

class DreamAnalysis {
  final List<String> themes;
  final List<String> characters;
  final List<String> locations;
  final List<EmotionType> emotions;
  final String summary;
  final double lucidityScore;
  final double emotionalIntensity;

  DreamAnalysis({
    required this.themes,
    required this.characters,
    required this.locations,
    required this.emotions,
    required this.summary,
    required this.lucidityScore,
    required this.emotionalIntensity,
  });

  factory DreamAnalysis.fromJson(Map<String, dynamic> json) {
    return DreamAnalysis(
      themes: List<String>.from(json['themes'] ?? []),
      characters: List<String>.from(json['characters'] ?? []),
      locations: List<String>.from(json['locations'] ?? []),
      emotions: (json['emotions'] as List<dynamic>?)
              ?.map((e) => EmotionType.values.firstWhere(
                    (emotion) => emotion.name == e,
                    orElse: () => EmotionType.joy,
                  ))
              .toList() ??
          [],
      summary: json['summary'] ?? '',
      lucidityScore: (json['lucidityScore'] ?? 0.0).toDouble(),
      emotionalIntensity: (json['emotionalIntensity'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themes': themes,
      'characters': characters,
      'locations': locations,
      'emotions': emotions.map((e) => e.name).toList(),
      'summary': summary,
      'lucidityScore': lucidityScore,
      'emotionalIntensity': emotionalIntensity,
    };
  }
}

class Dream {
  final String id;
  final String title;
  final String content;
  final String rawTranscript;
  final DateTime createdAt;
  final DreamType type;
  final DreamAnalysis? analysis;
  final String? aiGeneratedImageUrl;
  final String? aiImagePrompt;
  final bool isGeneratingImage;
  final List<String> tags;
  final bool isFavorite;

  Dream({
    String? id,
    required this.title,
    required this.content,
    required this.rawTranscript,
    DateTime? createdAt,
    this.type = DreamType.normal,
    this.analysis,
    this.aiGeneratedImageUrl,
    this.aiImagePrompt,
    this.isGeneratingImage = false,
    this.tags = const [],
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Dream copyWith({
    String? title,
    String? content,
    String? rawTranscript,
    DreamType? type,
    DreamAnalysis? analysis,
    String? aiGeneratedImageUrl,
    String? aiImagePrompt,
    bool? isGeneratingImage,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Dream(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      createdAt: createdAt,
      type: type ?? this.type,
      analysis: analysis ?? this.analysis,
      aiGeneratedImageUrl: aiGeneratedImageUrl ?? this.aiGeneratedImageUrl,
      aiImagePrompt: aiImagePrompt ?? this.aiImagePrompt,
      isGeneratingImage: isGeneratingImage ?? this.isGeneratingImage,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Dream.fromJson(Map<String, dynamic> json) {
    return Dream(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      rawTranscript: json['rawTranscript'],
      createdAt: DateTime.parse(json['createdAt']),
      type: DreamType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => DreamType.normal,
      ),
      analysis: json['analysis'] != null 
          ? DreamAnalysis.fromJson(json['analysis']) 
          : null,
      aiGeneratedImageUrl: json['aiGeneratedImageUrl'],
      aiImagePrompt: json['aiImagePrompt'],
      isGeneratingImage: json['isGeneratingImage'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'rawTranscript': rawTranscript,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'analysis': analysis?.toJson(),
      'aiGeneratedImageUrl': aiGeneratedImageUrl,
      'aiImagePrompt': aiImagePrompt,
      'isGeneratingImage': isGeneratingImage,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }
}