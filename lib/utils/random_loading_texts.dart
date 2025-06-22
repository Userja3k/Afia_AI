class LoadingTexts {
  static final List<String> texts = [
    "L'IA est en train d'analyser vos données...",
    "Veuillez patienter quelques instants.",
    "Tout vient à point à qui sait attendre...",
    "Traitement des images en cours...",
    "Analyse médicale en cours...",
    "Presque terminé, merci de votre patience !",
    "On regarde tout ça de très près.",
    "L'intelligence artificielle cherche les meilleures réponses.",
    "Connexion sécurisée établie, analyse distante...",
  ];

  static String getRandomText() {
    texts.shuffle();
    return texts.first;
  }
}