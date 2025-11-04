import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/tokens.dart';
import 'features/settings/theme_toggle.dart';
import 'ui/components/bottom_dock_nav.dart';
import 'ui/widgets/header_gradient_container.dart';
import 'ui/widgets/promo_card.dart';
import 'ui/widgets/transaction_item.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeScope(
      themeMode: _themeMode,
      onChanged: _updateThemeMode,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mawaid Bank',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: _themeMode,
            home: const _AppShell(),
          );
        },
      ),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _index = 0;

  void _onDestination(int value) {
    if (value == 2) {
      // Center action placeholder.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Primary action tapped', style: Theme.of(context).textTheme.bodyMedium)),
      );
      return;
    }
    setState(() {
      _index = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const BankingHomePage(),
      const PlaceholderPage(label: 'Analytics'),
      const PlaceholderPage(label: 'Action'),
      const PlaceholderPage(label: 'Wallet'),
      const SettingsPage(),
    ];

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: AppTokens.motion.normal,
        switchInCurve: AppTokens.motion.curve,
        switchOutCurve: AppTokens.motion.curve,
        child: pages[_index],
      ),
      bottomNavigationBar: BottomDockNav(
        currentIndex: _index,
        onIndexChanged: _onDestination,
      ),
    );
  }
}

class BankingHomePage extends StatelessWidget {
  const BankingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final transactions = [
      TransactionModel('Netflix Subscription', 'Today • 12:32 PM', -13.99, IconlyBold.tick_square),
      TransactionModel('Salary Deposit', 'Yesterday • 09:00 AM', 3200, IconlyBold.wallet),
      TransactionModel('Green Grocery', 'Jun 04 • 06:20 PM', -54.2, IconlyBold.bag),
      TransactionModel('Gym Membership', 'Jun 02 • 07:00 AM', -39.0, IconlyBold.activity),
    ];

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppTokens.spacing.xl, AppTokens.spacing.xl, AppTokens.spacing.xl, AppTokens.spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderGradientContainer(
                    balance: 12030.00,
                    subtitle: 'Current Balance',
                    onAddMoney: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Add money', style: textTheme.bodyMedium)),
                      );
                    },
                    onSendMoney: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Send money', style: textTheme.bodyMedium)),
                      );
                    },
                  ),
                  SizedBox(height: AppTokens.spacing.xl),
                  PromoCard(
                    onDismissed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Promo dismissed', style: textTheme.bodyMedium)),
                      );
                    },
                  ),
                  SizedBox(height: AppTokens.spacing.xl),
                  Text('Recent Transactions', style: textTheme.titleLarge?.copyWith(color: colorScheme.onBackground)),
                ],
              ),
            ),
          ),
          SliverList.separated(
            itemCount: transactions.length,
            separatorBuilder: (_, __) => Divider(indent: AppTokens.spacing.xl, endIndent: AppTokens.spacing.xl),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return TransactionItem(model: transaction);
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppTokens.spacing.xxl + AppTokens.spacing.xl)),
        ],
      ),
    );
  }
}

class TransactionModel {
  const TransactionModel(this.title, this.subtitle, this.amount, this.iconData);

  final String title;
  final String subtitle;
  final double amount;
  final IconData iconData;
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppTokens.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: AppTokens.spacing.md),
            const ThemeModeToggle(),
          ],
        ),
      ),
    );
  }
}

class ThemeModeScope extends InheritedWidget {
  const ThemeModeScope({required this.themeMode, required this.onChanged, required super.child, super.key});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  static ThemeModeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeModeScope>();
    assert(scope != null, 'ThemeModeScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(ThemeModeScope oldWidget) => themeMode != oldWidget.themeMode;
}

extension ThemeModeX on BuildContext {
  ThemeMode get themeMode => ThemeModeScope.of(this).themeMode;
  void updateThemeMode(ThemeMode mode) => ThemeModeScope.of(this).onChanged(mode);
}
