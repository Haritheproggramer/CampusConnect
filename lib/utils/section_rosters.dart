// ignore_for_file: constant_identifier_names

/// Central student roster registry.
///
/// Add future sections here — only CSE 4C / Section C data is active now.
/// For any section without real data, leave the list empty ([]).
/// The UI will show "Roster not added yet" for empty entries.
class SectionRosterData {
  SectionRosterData._();

  // ── Class catalogue ────────────────────────────────────────────────────────
  // All known class labels in display order.
  // Add new class labels here as rosters are filled in.
  static const List<String> allClassLabels = [
    'CSE Core C', // active — real roster below
    'CSE Core A', // coming soon
    'CSE Core B', // coming soon
    'CSE Core D', // coming soon
    'AIML A',    // coming soon
    'AIML B',    // coming soon
  ];

  // Human-readable display names (label → display name).
  static const Map<String, String> classDisplayNames = {
    'CSE Core C': 'CSE 4C — Section C',
    'CSE Core A': 'CSE 4A — Section A',
    'CSE Core B': 'CSE 4B — Section B',
    'CSE Core D': 'CSE 4D — Section D',
    'AIML A':    'AIML — Section A',
    'AIML B':    'AIML — Section B',
  };

  // ── Rosters keyed by class label ───────────────────────────────────────────
  // Only add real data. Empty list = "Roster not added yet".
  static const Map<String, List<Map<String, dynamic>>> sectionRosters = {
    // ── CSE 4C / Section C — 53 real students ────────────────────────────────
    'CSE Core C': [
      {'s_no': 1,  'roll_no': '2K24CSUN01143', 'name': 'Aakash Kothari',            'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 2,  'roll_no': '2K24CSUN01144', 'name': 'Abhishek Bora',             'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 3,  'roll_no': '2K24CSUN01145', 'name': 'Abhishek Sharma',           'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 4,  'roll_no': '2K24CSUN01146', 'name': 'Aditya Choudhary',          'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 5,  'roll_no': '2K24CSUN01148', 'name': 'Akash Yadav',               'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 6,  'roll_no': '2K24CSUN01152', 'name': 'Avishi Gupta',              'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': true},
      {'s_no': 7,  'roll_no': '2K24CSUN01153', 'name': 'Ayaan Anwar',               'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 8,  'roll_no': '2K24CSUN01154', 'name': 'Bhoomi Sharma',             'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 9,  'roll_no': '2K24CSUN01156', 'name': 'Gaderu Krishna Nanda',      'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 10, 'roll_no': '2K24CSUN01157', 'name': 'Hariom Jha',                'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': true},
      {'s_no': 11, 'roll_no': '2K24CSUN01160', 'name': 'Harshit Raj',               'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 12, 'roll_no': '2K24CSUN01161', 'name': 'Harshit Singhal',           'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 13, 'roll_no': '2K24CSUN01163', 'name': 'Hunny Kaushik',             'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 14, 'roll_no': '2K24CSUN01165', 'name': 'Ishita Babbar',             'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 15, 'roll_no': '2K24CSUN01167', 'name': 'Japleen Kaur',              'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 16, 'roll_no': '2K24CSUN01168', 'name': 'Jasmine Kaur',              'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 17, 'roll_no': '2K24CSUN01169', 'name': 'Jatin Chhabra',             'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 18, 'roll_no': '2K24CSUN01170', 'name': 'Jatin Singhal',             'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 19, 'roll_no': '2K24CSUN01172', 'name': 'Kavy Khanna',               'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 20, 'roll_no': '2K24CSUN01174', 'name': 'Khushi Vats',               'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 21, 'roll_no': '2K24CSUN01175', 'name': 'Kirti Singhal',             'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 22, 'roll_no': '2K24CSUN01177', 'name': 'Krishna Khanna',            'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 23, 'roll_no': '2K24CSUN01178', 'name': 'Kunal Sharma',              'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 24, 'roll_no': '2K24CSUN01180', 'name': 'Nampelly Akshay',           'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 25, 'roll_no': '2K24CSUN01181', 'name': 'Narla Vamshi',              'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 26, 'roll_no': '2K24CSUN01182', 'name': 'Naveen Jindal',             'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 27, 'roll_no': '2K24CSUN01183', 'name': 'Nirbhay',                   'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 28, 'roll_no': '2K24CSUN01185', 'name': 'Pendli Jashvanth Manikanta','group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 29, 'roll_no': '2K24CSUN01186', 'name': 'Piyush Juneja',             'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 30, 'roll_no': '2K24CSUN01187', 'name': 'Piyush Kumar Sharma',       'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 31, 'roll_no': '2K24CSUN01188', 'name': 'Prabhleen Kaur',            'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 32, 'roll_no': '2K24CSUN01191', 'name': 'Prince Sharma',             'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 33, 'roll_no': '2K24CSUN01192', 'name': 'Pujari Shiva Kumar',        'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 34, 'roll_no': '2K24CSUN01194', 'name': 'Raja Babu Rai',             'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 35, 'roll_no': '2K24CSUN01195', 'name': 'Rohan',                     'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 36, 'roll_no': '2K24CSUN01196', 'name': 'Rohan Sharma',              'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 37, 'roll_no': '2K24CSUN01198', 'name': 'Sagar Kumar',               'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 38, 'roll_no': '2K24CSUN01199', 'name': 'Sarthak Mittal',            'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 39, 'roll_no': '2K24CSUN01200', 'name': 'Shambhavi',                 'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 40, 'roll_no': '2K24CSUN01201', 'name': 'Shenigaram Manish',         'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 41, 'roll_no': '2K24CSUN01202', 'name': 'Shinu Sura',                'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 42, 'roll_no': '2K24CSUN01203', 'name': 'Sonakshi Chand',            'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 43, 'roll_no': '2K24CSUN01204', 'name': 'Tanisha',                   'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 44, 'roll_no': '2K24CSUN01205', 'name': 'Tanya Rathore',             'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 45, 'roll_no': '2K24CSUN01206', 'name': 'Vansh Pratap',              'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 46, 'roll_no': '2K24CSUN01207', 'name': 'Vatsal Goel',               'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 47, 'roll_no': '2K24CSUN01208', 'name': 'Venkata Ramana Reddy',      'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 48, 'roll_no': '2K24CSUN01209', 'name': 'Vidit Chauhan',             'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 49, 'roll_no': '2K24CSUN01211', 'name': 'Yanis Hasan Khan',          'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 50, 'roll_no': '2K24CSUN01212', 'name': 'Yashveer Tanwar',           'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 51, 'roll_no': '2K24CSUN01213', 'name': 'Yuvraj Nagar',              'group': 'G2', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 52, 'roll_no': '2K25CSUL01008', 'name': 'Naman Tyagi',               'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
      {'s_no': 53, 'roll_no': '2K25CSUL01010', 'name': 'Aakash',                    'group': 'G1', 'section': 'C', 'class_name': 'CSE 4C', 'department': 'CSE', 'is_cr': false},
    ],

    // ── Future sections — add real data when available ─────────────────────
    'CSE Core A': [],
    'CSE Core B': [],
    'CSE Core D': [],
    'AIML A':    [],
    'AIML B':    [],
  };

  // ── Convenience accessors ──────────────────────────────────────────────────

  /// Returns true if the given class label has real roster data.
  static bool hasRoster(String classLabel) =>
      (sectionRosters[classLabel]?.isNotEmpty) == true;

  /// Students for a class label; empty list if not yet added.
  static List<Map<String, dynamic>> studentsForClass(String classLabel) =>
      List<Map<String, dynamic>>.from(sectionRosters[classLabel] ?? const []);

  /// Backwards-compat alias used by mock_data and firebase_service.
  static List<Map<String, dynamic>> studentsForSection(String className) =>
      studentsForClass(className);

  /// All students across every class that has real data.
  static List<Map<String, dynamic>> get allStudents => sectionRosters.values
      .expand((rows) => rows)
      .toList(growable: false);

  static List<Map<String, dynamic>> studentsForGroup(
      String classLabel, String group) {
    return studentsForClass(classLabel)
        .where((s) => s['group']?.toString() == group)
        .toList(growable: false);
  }

  static List<String> get availableSections => allStudents
      .map((s) => s['section']?.toString() ?? '')
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  static List<String> get availableGroups => allStudents
      .map((s) => s['group']?.toString() ?? '')
      .where((g) => g.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}
