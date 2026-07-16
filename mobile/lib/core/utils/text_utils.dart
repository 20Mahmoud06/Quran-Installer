class TextUtils {
  static String normalizeArabicText(String text) {
    if (text.isEmpty) return "";
    
    String normalized = text
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
        
    // Remove diacritics
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F]'), '');
    
    return normalized.toLowerCase();
  }

  // Simple transliteration approximation for search (Arabic to English)
  static String transliterateArabic(String text) {
    const Map<String, String> arabicToEnglish = {
      'ا': 'a', 'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j', 'ح': 'h', 'خ': 'kh',
      'د': 'd', 'ذ': 'dh', 'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 'sh', 'ص': 's',
      'ض': 'd', 'ط': 't', 'ظ': 'dh', 'ع': 'a', 'غ': 'gh', 'ف': 'f', 'ق': 'q',
      'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n', 'ه': 'h', 'و': 'w', 'ي': 'y',
      'ة': 'h', 'ى': 'a', 'ء': 'a', 'ؤ': 'u', 'ئ': 'i',
    };
    
    String result = '';
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (arabicToEnglish.containsKey(char)) {
        result += arabicToEnglish[char]!;
      } else {
        result += char;
      }
    }
    return result;
  }
}
