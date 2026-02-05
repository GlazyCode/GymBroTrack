import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF39FF14),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  int _selectedDayIndex = 0;

  // DATA STORAGE
  final List<List<Map<String, dynamic>>> _allHabits = List.generate(
    7,
    (_) => [],
  );
  final List<List<String>> _allJournalNotes = List.generate(7, (_) => []);
  final List<List<Map<String, String>>> _workoutSplits = List.generate(
    7,
    (_) => [],
  );

  // HEADERS & SUBTITLES
  String _programTitle = "HYBRID/HOME GYM PROGRAM SPLIT";
  String _globalNotes = "DON'T SKIP LEGDAY, DO IT EVERY DAY.";
  final List<String> _daySubtitles = List.generate(
    7,
    (index) => "Day ${index + 1} - Focus",
  );

  final List<String> _dayNames = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  // CONTROLLERS
  final TextEditingController _exController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  double _calculateProgress() {
    if (_allHabits[_selectedDayIndex].isEmpty) return 0.0;
    int done = _allHabits[_selectedDayIndex]
        .where((h) => h['isDone'] == true)
        .length;
    return done / _allHabits[_selectedDayIndex].length;
  }

  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          _currentIndex == 0
              ? "MISSIONS"
              : _currentIndex == 1
              ? "JOURNAL"
              : "WORKOUT",
          style: const TextStyle(
            color: Color(0xFF39FF14),
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white54),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDayPicker(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildMissionsPage(progress),
                _buildJournalPage(),
                _buildWorkoutPage(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF39FF14),
        onPressed: () => _showInputDialog(),
        label: const Text(
          "ADD",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF0A0A0A),
        selectedItemColor: const Color(0xFF39FF14),
        unselectedItemColor: Colors.white24,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: "Missions"),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: "Journal",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Split",
          ),
        ],
      ),
    );
  }

  // --- MISSIONS ---
  Widget _buildMissionsPage(double progress) {
    return Column(
      children: [
        _buildAnalyticsCard(progress),
        _sectionLabel("DAILY TASKS"),
        Expanded(
          child: _allHabits[_selectedDayIndex].isEmpty
              ? _buildEmptyState("NO MISSIONS")
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _allHabits[_selectedDayIndex].length,
                  itemBuilder: (c, i) => Card(
                    color: (_allHabits[_selectedDayIndex][i]['isDone'] ?? false)
                        ? const Color(0xFF39FF14).withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                    child: ListTile(
                      onTap: () => _showInputDialog(index: i),
                      onLongPress: () => setState(
                        () => _allHabits[_selectedDayIndex].removeAt(i),
                      ),
                      leading: Checkbox(
                        value:
                            _allHabits[_selectedDayIndex][i]['isDone'] ?? false,
                        activeColor: const Color(0xFF39FF14),
                        onChanged: (v) => setState(
                          () => _allHabits[_selectedDayIndex][i]['isDone'] = v,
                        ),
                      ),
                      title: Text(
                        _allHabits[_selectedDayIndex][i]['name'] ?? "",
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // --- JOURNAL ---
  Widget _buildJournalPage() {
    return Column(
      children: [
        _sectionLabel("DAILY THOUGHTS"),
        Expanded(
          child: _allJournalNotes[_selectedDayIndex].isEmpty
              ? _buildEmptyState("EMPTY LOG")
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _allJournalNotes[_selectedDayIndex].length,
                  itemBuilder: (c, i) => GestureDetector(
                    onTap: () => _showInputDialog(index: i),
                    onLongPress: () => setState(
                      () => _allJournalNotes[_selectedDayIndex].removeAt(i),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_allJournalNotes[_selectedDayIndex][i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // --- WORKOUT ---
  Widget _buildWorkoutPage() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showEditHeaderDialog(),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF39FF14).withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF39FF14).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _programTitle.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF39FF14),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _daySubtitles[_selectedDayIndex],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _globalNotes,
                  style: const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
        _sectionLabel("LIST OF EXERCISES"),
        Expanded(
          child: _workoutSplits[_selectedDayIndex].isEmpty
              ? _buildEmptyState("REST DAY")
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _workoutSplits[_selectedDayIndex].length,
                  itemBuilder: (c, i) {
                    final val = _workoutSplits[_selectedDayIndex][i];
                    return GestureDetector(
                      onTap: () => _showInputDialog(index: i),
                      onLongPress: () => setState(
                        () => _workoutSplits[_selectedDayIndex].removeAt(i),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                val['ex'] ?? "Exercise",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "${val['s'] ?? "0"} Sets",
                              style: const TextStyle(
                                color: Color(0xFF39FF14),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              "${val['r'] ?? "0"} Reps",
                              style: const TextStyle(
                                color: Color(0xFF39FF14),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- EDIT HEADER DIALOG ---
  void _showEditHeaderDialog() {
    _titleController.text = _programTitle;
    _exController.text = _daySubtitles[_selectedDayIndex];
    _notesController.text = _globalNotes;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (c) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(c).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Main Program Title",
              ),
            ),
            TextField(
              controller: _exController,
              decoration: const InputDecoration(
                labelText: "Day Subtitle (e.g. Day 1 - Push)",
              ),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: "Global Notes"),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _programTitle = _titleController.text;
                  _daySubtitles[_selectedDayIndex] = _exController.text;
                  _globalNotes = _notesController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39FF14),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "SAVE CHANGES",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ADD/EDIT ITEM DIALOG ---
  void _showInputDialog({int? index}) {
    if (index != null) {
      if (_currentIndex == 0) {
        _exController.text = _allHabits[_selectedDayIndex][index]['name'] ?? "";
      } else if (_currentIndex == 1) {
        _exController.text = _allJournalNotes[_selectedDayIndex][index];
      } else {
        _exController.text =
            _workoutSplits[_selectedDayIndex][index]['ex'] ?? "";
        _setsController.text =
            _workoutSplits[_selectedDayIndex][index]['s'] ?? "";
        _repsController.text =
            _workoutSplits[_selectedDayIndex][index]['r'] ?? "";
      }
    } else {
      _exController.clear();
      _setsController.clear();
      _repsController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (c) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(c).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _exController,
              decoration: const InputDecoration(hintText: "Description"),
              autofocus: true,
            ),
            if (_currentIndex == 2) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _setsController,
                      decoration: const InputDecoration(hintText: "Sets"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      decoration: const InputDecoration(hintText: "Reps"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_currentIndex == 0) {
                    if (index == null) {
                      _allHabits[_selectedDayIndex].add({
                        'name': _exController.text,
                        'isDone': false,
                      });
                    } else {
                      _allHabits[_selectedDayIndex][index]['name'] =
                          _exController.text;
                    }
                  } else if (_currentIndex == 1) {
                    if (index == null) {
                      _allJournalNotes[_selectedDayIndex].add(
                        _exController.text,
                      );
                    } else {
                      _allJournalNotes[_selectedDayIndex][index] =
                          _exController.text;
                    }
                  } else {
                    var d = {
                      'ex': _exController.text,
                      's': _setsController.text,
                      'r': _repsController.text,
                    };
                    if (index == null) {
                      _workoutSplits[_selectedDayIndex].add(d);
                    } else {
                      _workoutSplits[_selectedDayIndex][index] = d;
                    }
                  }
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39FF14),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "CONFIRM",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          bool isSel = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              width: 55,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF39FF14) : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayNames[index],
                    style: TextStyle(
                      color: isSel ? Colors.black : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${DateTime.now().add(Duration(days: index)).day}",
                    style: TextStyle(
                      color: isSel ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsCard(double progress) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            value: progress,
            color: const Color(0xFF39FF14),
            backgroundColor: Colors.white10,
          ),
          const SizedBox(width: 20),
          const Text(
            "KEEP GRINDING, BRO",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white24,
          fontSize: 9,
          letterSpacing: 2,
        ),
      ),
    ),
  );

  Widget _buildEmptyState(String msg) => Center(
    child: Text(msg, style: const TextStyle(color: Colors.white10)),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CREDITS"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            const Text(
              "Patrick Jaydee Mher D. Macatiag",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              "Lead Developer",
              style: TextStyle(color: Color(0xFF39FF14)),
            ),
          ],
        ),
      ),
    );
  }
}
