class AppConstants {
  // Textes de l'application
  static const String appName = 'Centre Éducatif';
  static const String loginTitle = 'Connexion';
  static const String signupTitle = 'Inscription';
  
  // Messages d'authentification
  static const String emailRequired = 'Ce champ est requis';
  static const String emailInvalid = 'Email invalide';
  static const String passwordRequired = 'Ce champ est requis';
  static const String passwordTooShort = 'Le mot de passe doit contenir au moins 6 caractères';
  static const String loginError = 'Erreur lors de la connexion';
  static const String signupError = 'Erreur lors de l\'inscription';
  static const String networkError = 'Erreur de connexion au serveur';
  
  // Labels des champs
  static const String emailLabel = 'Email';
  static const String emailHint = 'Entrez votre email';
  static const String passwordLabel = 'Mot de passe';
  static const String passwordHint = 'Entrez votre mot de passe';
  static const String firstNameLabel = 'Prénom';
  static const String firstNameHint = 'Entrez votre prénom';
  static const String lastNameLabel = 'Nom';
  static const String lastNameHint = 'Entrez votre nom';
  
  // Boutons
  static const String loginButton = 'Se connecter';
  static const String signupButton = 'S\'inscrire';
  static const String signupLink = 'Pas encore de compte ? S\'inscrire';
  static const String loginLink = 'Déjà un compte ? Se connecter';
  
  // Images et icônes
  static const String logoPath = 'assets/images/logo.png';
  static const String backgroundPath = 'assets/images/background.png';
  
  // Rôles utilisateurs (comme spécifié dans les MEMORIES)
  static const String roleAdmin = 'ADMIN';
  static const String roleProjectManager = 'PROJECT_MANAGER';
  static const String roleUser = 'USER';
  
  // Stockage local (comme spécifié dans les MEMORIES)
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
}
