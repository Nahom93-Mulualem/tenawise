import 'package:flutter_test/flutter_test.dart';
import 'package:tenawise/screens/assistant/srh_knowledge_engine.dart';

void main() {
  group('TenaWise SRH Knowledge Engine & Clinical Triage Tests', () {
    test('HPV inquiry in English returns accurate Human Papillomavirus definition without emergency flag', () {
      final res = SrhKnowledgeEngine.getResponse('What does HPV mean in Amharic?', false);
      expect(res.isUrgent, isFalse);
      expect(res.category, isNot(contains('Emergency')));
      expect(res.text, contains('Human Papillomavirus'));
      expect(res.text.toLowerCase(), isNot(contains('hewer abeba')));
      expect(res.text.toLowerCase(), isNot(contains('monthly flower')));
    });

    test('HPV inquiry in Amharic returns verified explanation with Human Papillomavirus', () {
      final res = SrhKnowledgeEngine.getResponse('HPV ምንድን ነው?', true);
      expect(res.isUrgent, isFalse);
      expect(res.category, isNot(contains('Emergency')));
      expect(res.text, contains('Human Papillomavirus'));
      expect(res.text, contains('የሰው ፓፒሎማ ቫይረስ'));
      expect(res.text, isNot(contains('አበባ'))); // Never confusing with flower / hewer abeba
    });

    test('Ordinary educational health questions do not trigger emergency clinical triage', () {
      final dmpaRes = SrhKnowledgeEngine.getResponse('what does dmpa_sc means', false);
      expect(dmpaRes.isUrgent, isFalse);
      expect(dmpaRes.category, isNot(contains('Emergency')));

      final pepEdRes = SrhKnowledgeEngine.getResponse('What is PEP and how does it work?', false);
      expect(pepEdRes.isUrgent, isFalse);
      expect(pepEdRes.category, isNot(contains('Emergency')));

      final contraRes = SrhKnowledgeEngine.getResponse('What are the symptoms of HIV?', false);
      expect(contraRes.isUrgent, isFalse);
      expect(contraRes.category, isNot(contains('Emergency')));
    });

    test('Genuine acute trauma or recent exposure within 72h correctly triggers urgent triage', () {
      final traumaRes = SrhKnowledgeEngine.getResponse('I was assaulted and forced against my will', false);
      expect(traumaRes.isUrgent, isTrue);
      expect(traumaRes.category, contains('Crisis'));

      final condomBrokeRes = SrhKnowledgeEngine.getResponse('The condom broke last night, what do I do?', false);
      expect(condomBrokeRes.isUrgent, isTrue);
      expect(condomBrokeRes.text, contains('72'));
    });
  });
}

