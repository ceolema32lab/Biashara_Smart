import 'package:google_generative_ai/google_generative_ai.dart';
import '../providers/app_state.dart';

class AIService {
  static const String _apiKey = "WEKA_API_KEY_YAKO_HAPA"; // Pata kwenye Google AI Studio

  static Future<String> getBusinessAdvice(AppState appState, String userQuery) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      
      // Tunatengeneza "Context" ili AI ijue hali ya biashara
      final prompt = """
      Wewe ni mshauri mtaalamu wa biashara. Hali ya biashara kwa sasa:
      Jina la Biashara: ${appState.businessName}
      Jina la Mmiliki: ${appState.userName}
      Jumla ya Mauzo: TSh ${appState.totalSales}
      Jumla ya Gharama: TSh ${appState.totalExpenses}
      Faida: TSh ${appState.totalProfit}
      Idadi ya Bidhaa: ${appState.items.length}
      
      Swali la mtumiaji ni: $userQuery
      Jibu kwa lugha ya ${appState.t("English", "Kiswahili")} kwa ufupi na kwa kutoa mbinu za kuongeza faida.
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? "Samahani, siwezi kupata jibu kwa sasa.";
    } catch (e) {
      return "Error: Hakikisha una internet na API key ni sahihi.";
    }
  }
}