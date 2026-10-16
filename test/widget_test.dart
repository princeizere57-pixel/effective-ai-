// Checked in so `flutter create .` does not generate the default counter test,
// which refers to a MyApp class this project does not have.

import 'package:effective_ai/data/knowledge.dart';
import 'package:effective_ai/services/knowledge_engine.dart';
import 'package:effective_ai/services/learner_state.dart';
import 'package:effective_ai/services/study_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final allDocs = sampleDocs.map((d) => d.id).toSet();

  group('KnowledgeEngine', () {
    test('answers only from selected documents and cites every sentence', () {
      final answer = KnowledgeEngine.answer('How do I choose a learning rate?', allDocs);
      expect(answer.isEmpty, isFalse);
      for (final (_, source) in answer.parts) {
        expect(source, lessThan(answer.sources.length));
      }
      expect(answer.sources.first.concepts, contains('lr'));
    });

    test('returns nothing when the selected documents do not cover the question', () {
      final answer = KnowledgeEngine.answer('What is an eigenvector?', {'lec5'});
      expect(answer.isEmpty, isTrue);
    });

    test('search finds passages across documents', () {
      final hits = KnowledgeEngine.search('overfitting');
      expect(hits.map((h) => h.passage.docId).toSet().length, greaterThan(1));
    });

    test('rubric marks only the points the answer covers', () {
      final rubric = rubrics.firstWhere((r) => r.conceptId == 'overfitting');
      final result = KnowledgeEngine.evaluate(
        rubric,
        'The model is overfitting. Add dropout to regularise it.',
      );
      expect(result.covered, [true, true, false]);
      expect(result.score, 10);
    });

    test('past paper analysis finds topics asked in every paper', () {
      final report = KnowledgeEngine.analysePastPapers({'exam24', 'exam25'});
      expect(report.paperCount, 2);
      final lr = report.topics.firstWhere((t) => t.concept.id == 'lr');
      expect(lr.papers, 2);
    });
  });

  group('Learner and plan', () {
    test('a wrong answer is remembered and lowers mastery', () {
      final state = LearnerState();
      final q = questionsFor('gd').first;
      final before = state.mastery('gd')!;
      final wrong = (q.answer + 1) % q.options.length;
      expect(state.answer(q, wrong), isFalse);
      expect(state.mastery('gd')!, lessThan(before));
      expect(state.mistakes.first.question, q);
    });

    test('the plan covers 7 days and adapts to the daily goal', () {
      final state = LearnerState();
      final small = StudyPlanner.build(state);
      state.setDailyGoal(60);
      final large = StudyPlanner.build(state);
      expect(small.days.length, 7);
      expect(large.unscheduled, lessThanOrEqualTo(small.unscheduled));
      expect(state.planUpdates, isNotEmpty);
    });
  });
}
