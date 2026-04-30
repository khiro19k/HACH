class MedicalDictionaryDZ {
  static const Map<String, String> expressions = {
    "راسي يوجعني / يدرني": "Céphalée / Headache (صداع)",
    "قلبي يخبط / يضرب": "Palpitations (خفقان القلب)",
    "ما كليتش": "Je n'ai pas mangé (لم آكل - خطر انخفاض السكر)",
    "كرشي توجعني": "Douleurs abdominales (ألم في البطن)",
    "فشلان / عيان بزاف": "Asthénie / Fatigue intense (تعب شديد)",
    "عينيا يضياقوا / ضبابة": "Vision floue (ضبابية الرؤية)",
    "عطشان بزاف": "Polydipsie / Soif intense (عطش شديد)",
    "نروح للطواليت بزاف": "Polyurie (تبول متكرر)",
    "دوخة / دايخ": "Vertiges (دوخة)",
    "رعشة في يديا": "Tremblements (رعشة - علامة انخفاض السكر)",
    "راني نعرق بزاف": "Transpiration excessive (تعرق شديد)",
    "جيعان ميت بالشر": "Faim extrême (جوع شديد)",
    "فمي ناشف": "Sécheresse buccale (جفاف الفم)",
    "سقيا منفوخين": "Oedème des membres inférieurs (انتفاخ القدمين)",
    "حريق البول": "Brûlure mictionnelle (حرقان في البول)",
    "جرح ما براش": "Plaie qui ne guérit pas (جرح لا يلتئم)",
    "تنميل في الرجلين": "Paresthésie (تنميل في الأطراف)",
    "ضيق النفس": "Dyspnée (ضيق في التنفس)",
    "حمة": "Fièvre (حمى)",
    "ردان / حاشاك نتقيا": "Vomissements (قيء)",
    "الغثيان / قلبي طالع": "Nausées (غثيان)",
    "فقدت الوعي / غيبت": "Perte de connaissance (فقدان الوعي)",
    "الرعدة": "Frissons (قشعريرة)",
    "فقدان الشهية": "Anorexie / Perte d'appétit (فقدان الشهية)",
    "النهتة": "Essoufflement (نهجة)",
    "السطر في المفاصل": "Douleurs articulaires (ألم المفاصل)",
    "الدوام": "Étourdissements (دوار)",
    "الظلمة في العينين": "Voile noir devant les yeux (سواد في العينين)",
    "الوهن": "Faiblesse générale (وهن عام)",
    "الخلعة": "Anxiété / Choc émotionnel (قلق أو فزع)",
    // Add more to reach a good amount for the demo
  };

  static String get formattedForPrompt {
    return expressions.entries.map((e) => "${e.key}: ${e.value}").join("\n    ");
  }
}
