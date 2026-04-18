class TreatmentService {
  static const Map<String, String> _treatments = {
    'apple apple scab': 'Prune affected branches. Apply fungicides like captan or sulfur during the growing season. Keep the area around the tree free of fallen leaves.',
    'apple black rot': 'Remove and destroy any "mummy" fruit and cankers. Apply fungicides early in the season to prevent spread.',
    'apple cedar apple rust': 'Remove nearby juniper trees if possible. Apply fungicides at the first sign of orange spots on leaves.',
    'corn maize cercospora leaf spot gray leaf spot': 'Rotate crops and use resistant varieties. Use fungicides if the infection is severe and weather is humid.',
    'corn maize common rust': 'Usually doesn\'t require treatment in home gardens. For large farms, use resistant hybrids or fungicides.',
    'corn maize northern leaf blight': 'Use resistant hybrids. Rotate crops and manage surface residue to reduce inoculum.',
    'grape black rot': 'Remove all old fruit and prune infected canes. Apply fungicides starting at bud break.',
    'grape esca black measles': 'Prune affected wood during dry weather. Protect pruning wounds with sealant.',
    'grape leaf blight isariopsis leaf spot': 'Improve air circulation. Apply fungicides labeled for grapes.',
    'orange haunglongbing citrus greening': 'Remove and destroy infected trees immediately to prevent spread. Control the Asian citrus psyllid (vector) with insecticides.',
    'peach bacterial spot': 'Choose resistant varieties. Avoid high nitrogen fertilization. Apply copper-based sprays in fall and spring.',
    'pepper bell bacterial spot': 'Use certified disease-free seeds. Avoid overhead irrigation. Apply copper fungicides.',
    'potato early blight': 'Rotate crops and maintain plant vigor. Apply fungicides like chlorothalonil or mancozeb.',
    'potato late blight': 'Ensure good drainage. Use healthy seed potatoes. Apply fungicides regularly during wet weather.',
    'squash powdery mildew': 'Improve air circulation. Apply fungicides like potassium bicarbonate or neem oil.',
    'strawberry leaf scorch': 'Remove old leaves in spring. Avoid overhead watering. Use resistant cultivars.',
    'tomato bacterial spot': 'Avoid overhead watering. Apply copper-based fungicides. Remove infected plants.',
    'tomato early blight': 'Prune lower leaves to prevent soil splash. Use mulch. Apply fungicides like chlorothalonil.',
    'tomato late blight': 'Remove and destroy infected plants immediately. Use resistant varieties and keep foliage dry.',
    'tomato leaf mold': 'Improve ventilation in greenhouses. Use resistant varieties. Avoid high humidity.',
    'tomato septoria leaf spot': 'Remove lower leaves. Use mulch. Apply fungicides containing chlorothalonil or copper.',
    'tomato spider mites two spotted spider mite': 'Increase humidity. Use neem oil or insecticidal soap. Encourage natural predators like ladybugs.',
    'tomato target spot': 'Improve spacing for air flow. Apply fungicides labeled for target spot.',
    'tomato yellow leaf curl virus': 'Control whiteflies using yellow sticky traps or insecticides. Use resistant varieties.',
    'tomato mosaic virus': 'Remove and destroy infected plants. Wash hands and tools after handling. Avoid tobacco use near plants.',
    'healthy': 'Great job! Your plant looks healthy. Continue regular watering and monitoring.',
  };

  static String getTreatment(String label) {
    if (label.contains('healthy')) return _treatments['healthy']!;
    
    // Exact match
    if (_treatments.containsKey(label)) return _treatments[label]!;

    // Fallback search
    for (var key in _treatments.keys) {
      if (label.toLowerCase().contains(key.toLowerCase())) {
        return _treatments[key]!;
      }
    }

    return 'No specific treatment records found. Please consult an agricultural expert or your local nursery.';
  }
}
