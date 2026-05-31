import 'package:flutter/material.dart';

/// Sport category enum with icons and labels
enum SportCategory {
  all('all', 'All Sports', Icons.sports_rounded),
  badminton('badminton', 'Badminton', Icons.sports_tennis_rounded),
  basketball('basketball', 'Basketball', Icons.sports_basketball_rounded),
  futsal('futsal', 'Futsal', Icons.sports_soccer_rounded),
  padel('padel', 'Padel', Icons.sports_tennis_rounded),
  volleyball('volleyball', 'Volleyball', Icons.sports_volleyball_rounded);

  const SportCategory(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}

/// Skill level enum
enum SkillLevel {
  beginner('beginner', 'Beginner'),
  intermediate('intermediate', 'Intermediate'),
  advanced('advanced', 'Advanced'),
  professional('professional', 'Pro');

  const SkillLevel(this.value, this.label);
  final String value;
  final String label;
}

/// Activity type enum
enum ActivityType {
  funMatch('fun_match', 'Fun Match'),
  sparring('sparring', 'Sparring');

  const ActivityType(this.value, this.label);
  final String value;
  final String label;
}

/// Joining purpose enum
enum JoiningPurpose {
  findFriends('find_friends', 'Find Friends'),
  casualPlay('casual_play', 'Casual Play'),
  competitive('competitive', 'Competitive'),
  fitness('fitness', 'Fitness'),
  socializing('socializing', 'Socializing'),
  learning('learning', 'Learning');

  const JoiningPurpose(this.value, this.label);
  final String value;
  final String label;
}
