class ApiConfig {
  // Production server URL
  static const String baseUrl = 'https://redcross-server.vercel.app';
  // For local development: 'http://localhost:4000';

  static String get apiUrl => '$baseUrl/api';

  // Auth endpoints
  static String get loginUrl => '$apiUrl/auth/login';
  static String get registerUrl => '$apiUrl/auth/register';
  static String get meUrl => '$apiUrl/me';
  static String get profileUrl => '$apiUrl/auth/profile';

  // Core endpoints
  static String get eventsUrl => '$apiUrl/events';
  static String get projectsUrl => '$apiUrl/projects';

  // Hubs
  static String get hubsUrl => '$apiUrl/hubs';

  // Payments
  static String get paymentsUrl => '$apiUrl/payments';

  // Activities
  static String get activitiesUrl => '$apiUrl/activities';

  // Training
  static String get trainingUrl => '$apiUrl/training';

  // Recognition
  static String get recognitionUrl => '$apiUrl/recognition';

  // Communication
  static String get communicationUrl => '$apiUrl/communication';

  // ID Cards
  static String get idcardsUrl => '$apiUrl/idcards';

  // Reports
  static String get reportsUrl => '$apiUrl/reports';

  // Form Fields
  static String get formFieldsUrl => '$apiUrl/form-fields';

  // Membership Types
  static String get membershipTypesUrl => '$apiUrl/membership-types';
}
