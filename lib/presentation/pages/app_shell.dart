import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_state.dart';
import 'todo_page.dart';

class AppShell extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const AppShell({super.key, required this.darkMode, required this.onThemeChanged});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int page = 0;
  DateTime selectedDate = DateTime.now();
  final Map<int, DateTime> plannedDates = {};

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final pages = [
      const DashboardPage(),
      const TodoPage(),
      PlannerPage(
        selectedDate: selectedDate,
        plannedDates: plannedDates,
        onDateChanged: (date) => setState(() => selectedDate = date),
        onPlanChanged: (id, date) => setState(() {
          if (date == null) {
            plannedDates.remove(id);
          } else {
            plannedDates[id] = date;
          }
        }),
      ),
      SettingsPage(darkMode: widget.darkMode, onThemeChanged: widget.onThemeChanged),
    ];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [const Color(0xFF19152F), const Color(0xFF29204A), const Color(0xFF111827)]
                : [const Color(0xFFE3DFFF), const Color(0xFFF6E9FF), const Color(0xFFDDF4FF)],
          ),
        ),
        child: SafeArea(child: pages[page]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (value) => setState(() => page = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Planner'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        final total = state.todos.length;
        final done = state.todos.where((task) => task.completed).length;
        final active = total - done;
        final progress = total == 0 ? 0.0 : done / total;
        final recent = state.todos.where((task) => !task.completed).take(4).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          children: [
            const Text('TaskFlow', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const Text('Make today count.', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('A clear view of everything you need to do.'),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6556E8), Color(0xFFAA64D9)]),
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [BoxShadow(color: Color(0x336556E8), blurRadius: 22, offset: Offset(0, 10))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Overall progress', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
                Text('$done of $total tasks completed', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 18),
                LinearProgressIndicator(value: progress, minHeight: 9, borderRadius: BorderRadius.circular(12), backgroundColor: Colors.white24, color: Colors.white),
              ]),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: _StatCard(title: 'To do', value: '$active', icon: Icons.pending_actions_rounded, color: const Color(0xFFEF8C51))),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'Completed', value: '$done', icon: Icons.task_alt_rounded, color: const Color(0xFF35A78E))),
            ]),
            const SizedBox(height: 28),
            const Text('Up next', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (state.loading && total == 0) const Center(child: CircularProgressIndicator()),
            if (!state.loading && recent.isEmpty) const Text('You are all caught up.'),
            for (final task in recent)
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.radio_button_unchecked_rounded),
                  title: Text(task.todo),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text(title),
      ]),
    );
  }
}

class PlannerPage extends StatelessWidget {
  final DateTime selectedDate;
  final Map<int, DateTime> plannedDates;
  final ValueChanged<DateTime> onDateChanged;
  final void Function(int, DateTime?) onPlanChanged;

  const PlannerPage({
    super.key,
    required this.selectedDate,
    required this.plannedDates,
    required this.onDateChanged,
    required this.onPlanChanged,
  });

  bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(builder: (context, state) {
      final planned = state.todos.where((task) {
        final date = plannedDates[task.id];
        return date != null && sameDay(date, selectedDate);
      }).toList();
      return ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 10),
        const Text('Planner', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Choose a day and organize your tasks.'),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
              onDateChanged: onDateChanged,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('Planned tasks (${planned.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (final task in planned)
          Card(
            elevation: 0,
            child: ListTile(
              leading: Icon(task.completed ? Icons.check_circle : Icons.schedule),
              title: Text(task.todo),
              trailing: IconButton(
                tooltip: 'Remove from planner',
                icon: const Icon(Icons.close),
                onPressed: () => onPlanChanged(task.id, null),
              ),
            ),
          ),
        if (planned.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Nothing planned for this day yet.')),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: state.todos.isEmpty ? null : () async {
            final id = await showModalBottomSheet<int>(
              context: context,
              isScrollControlled: true,
              builder: (sheetContext) => SafeArea(
                child: SizedBox(
                  height: MediaQuery.sizeOf(sheetContext).height * 0.55,
                  child: Column(children: [
                    const Padding(padding: EdgeInsets.all(16), child: Text('Choose a task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    Expanded(child: ListView.builder(
                      itemCount: state.todos.length,
                      itemBuilder: (context, index) {
                        final task = state.todos[index];
                        return ListTile(title: Text(task.todo), onTap: () => Navigator.pop(sheetContext, task.id));
                      },
                    )),
                  ]),
                ),
              ),
            );
            if (id != null) onPlanChanged(id, selectedDate);
          },
          icon: const Icon(Icons.add),
          label: const Text('Plan a task'),
        ),
        const SizedBox(height: 12),
        const Text('Planning dates are temporary and reset when the app restarts.', style: TextStyle(fontSize: 12)),
      ]);
    });
  }
}

class SettingsPage extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPage({super.key, required this.darkMode, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 10),
      const Text('Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Make TaskFlow your own.'),
      const SizedBox(height: 24),
      Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        child: SwitchListTile(
          title: const Text('Dark mode'),
          subtitle: const Text('Switch between light and dark colors'),
          secondary: const Icon(Icons.dark_mode_outlined),
          value: darkMode,
          onChanged: onThemeChanged,
        ),
      ),
      const SizedBox(height: 16),
      Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        child: const Column(children: [
          ListTile(leading: Icon(Icons.info_outline), title: Text('About TaskFlow'), subtitle: Text('Version 2.0 · Flutter task manager')),
          Divider(height: 1),
          ListTile(leading: Icon(Icons.cloud_outlined), title: Text('Data source'), subtitle: Text('DummyJSON REST API')),
          Divider(height: 1),
          ListTile(leading: Icon(Icons.layers_outlined), title: Text('Architecture'), subtitle: Text('BLoC · Dio · Retrofit · JSON serialization')),
        ]),
      ),
      const SizedBox(height: 16),
      const Padding(
        padding: EdgeInsets.all(8),
        child: Text('DummyJSON simulates changes. Tasks and planner dates are not permanently saved.'),
      ),
    ]);
  }
}
