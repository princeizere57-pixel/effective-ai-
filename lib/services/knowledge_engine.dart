import '../data/knowledge.dart';

class SearchHit {
  const SearchHit(this.passage, this.score, this.terms);

  final Passage passage;
  final double score;

  /// Query terms found in the passage, for highlighting.
  final Set<String> terms;
}

class GroundedAnswer {
  const GroundedAnswer(this.parts, this.sources);

  /// Each sentence with the index of the source it came from.
  final List<(String, int)> parts;
  final List<Passage> sources;

  bool get isEmpty => parts.isEmpty;

  int get documentCount => sources.map((p) => p.docId).toSet().length;
}

class Evaluation {
  const Evaluation(this.rubric, this.covered);

  final RubricQuestion rubric;
  final List<bool> covered;

  int get score {
    var s = 0;
    for (var i = 0; i < covered.length; i++) {
      if (covered[i]) s += rubric.points[i].marks;
    }
    return s;
  }

  double get fraction => rubric.marks == 0 ? 0 : score / rubric.marks;
}

class TopicFrequency {
  const TopicFrequency(this.concept, this.papers, this.marks, this.questions);

  final Concept concept;
  final int papers;
  final int marks;
  final List<Passage> questions;
}

class PastPaperReport {
  const PastPaperReport(this.paperCount, this.questionCount, this.topics, this.commandWords);

  final int paperCount;
  final int questionCount;

  /// Most-assessed first.
  final List<TopicFrequency> topics;

  /// Command word → number of questions using it.
  final Map<String, int> commandWords;
}

/// Sample engine that works entirely on the learner's own passages: keyword
/// retrieval, extractive answers with citations, and rubric checks.
///
/// Swap it for embeddings + an LLM on a backend (see README) without changing
/// the screens: they only depend on these result types.
abstract final class KnowledgeEngine {
  static const _stop = {
    'the', 'and', 'for', 'are', 'but', 'not', 'you', 'your', 'with', 'that', 'this', 'what',
    'how', 'why', 'when', 'does', 'did', 'can', 'its', 'into', 'from', 'about', 'which', 'who',
    'was', 'were', 'has', 'have', 'had', 'will', 'would', 'should', 'could', 'there', 'their',
    'them', 'then', 'than', 'they', 'use', 'used', 'using', 'explain', 'tell', 'mean', 'means',
    'work', 'works', 'make', 'makes', 'more', 'most', 'some', 'each', 'all', 'any', 'one', 'two',
  };

  static String _stem(String w) {
    if (w.length > 4 && w.endsWith('ies')) return '${w.substring(0, w.length - 3)}y';
    if (w.length > 4 && w.endsWith('s') && !w.endsWith('ss')) return w.substring(0, w.length - 1);
    return w;
  }

  static List<String> terms(String text) => RegExp(r'[a-zA-Zλ]+')
      .allMatches(text.toLowerCase())
      .map((m) => _stem(m.group(0)!))
      .where((w) => w.length > 2 && !_stop.contains(w))
      .toList();

  static String stemOf(String word) => _stem(word.toLowerCase());

  /// Finds passages across the library that match [query].
  static List<SearchHit> search(String query, {Set<String>? docIds}) {
    final q = terms(query).toSet();
    if (q.isEmpty) return const [];
    final hits = <SearchHit>[];
    for (final p in passages) {
      if (docIds != null && !docIds.contains(p.docId)) continue;
      final pt = terms('${p.section} ${p.text}').toSet();
      final matched = q.intersection(pt);
      var score = matched.length.toDouble();
      for (final id in p.concepts) {
        final nameTerms = terms(conceptById(id).name).toSet();
        if (nameTerms.isNotEmpty && nameTerms.every(q.contains)) score += 2;
      }
      if (score > 0) hits.add(SearchHit(p, score, matched));
    }
    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits;
  }

  static List<String> sentences(String text) =>
      text.split(RegExp(r'(?<=[.!?])\s+')).where((s) => s.trim().isNotEmpty).toList();

  /// Builds an answer only from the selected documents, citing every sentence.
  static GroundedAnswer answer(String question, Set<String> docIds) {
    final hits = search(question, docIds: docIds);
    if (hits.isEmpty) return const GroundedAnswer([], []);
    final cutoff = hits.first.score / 2;
    final chosen = hits.where((h) => h.score >= cutoff).take(3).toList();
    final q = terms(question).toSet();
    final parts = <(String, int)>[];
    for (var i = 0; i < chosen.length; i++) {
      final options = sentences(chosen[i].passage.text);
      var best = options.first;
      var bestScore = -1;
      for (final s in options) {
        final score = terms(s).toSet().intersection(q).length;
        if (score > bestScore) {
          best = s;
          bestScore = score;
        }
      }
      parts.add((best, i));
    }
    return GroundedAnswer(parts, [for (final h in chosen) h.passage]);
  }

  /// Checks a written answer against the marking points (keyword based).
  static Evaluation evaluate(RubricQuestion rubric, String answer) {
    final text = answer.toLowerCase();
    return Evaluation(rubric, [
      for (final point in rubric.points) point.keywords.any((k) => text.contains(k)),
    ]);
  }

  /// Recurring topics and question types across the given past papers.
  static PastPaperReport analysePastPapers(Set<String> paperIds) {
    final examPassages = passages.where((p) => paperIds.contains(p.docId)).toList();
    final topics = <TopicFrequency>[];
    for (final c in concepts) {
      final qs = examPassages.where((p) => p.concepts.contains(c.id)).toList();
      if (qs.isEmpty) continue;
      topics.add(TopicFrequency(
        c,
        qs.map((p) => p.docId).toSet().length,
        qs.fold(0, (sum, p) => sum + marksOf(p)),
        qs,
      ));
    }
    topics.sort((a, b) {
      final byPapers = b.papers.compareTo(a.papers);
      return byPapers != 0 ? byPapers : b.marks.compareTo(a.marks);
    });
    final words = <String, int>{};
    for (final entry in examCommandWords.entries) {
      final n = examPassages
          .where((p) => entry.value.any((w) => p.text.toLowerCase().contains(w)))
          .length;
      if (n > 0) words[entry.key] = n;
    }
    return PastPaperReport(
      paperIds.length,
      examPassages.length,
      topics,
      Map.fromEntries(words.entries.toList()..sort((a, b) => b.value.compareTo(a.value))),
    );
  }
}
