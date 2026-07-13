import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/router.dart';
import '../../data/odoo/odoo_client.dart';
import 'session_repository.dart';

/// Server URL + database + login + API key. Validates by authenticating
/// before saving; the key goes to secure storage only.
@RoutePage()
class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = useTextEditingController();
    final db = useTextEditingController();
    final username = useTextEditingController();
    final apiKey = useTextEditingController();
    final busy = useState(false);
    final error = useState<String?>(null);

    Future<void> connect() async {
      busy.value = true;
      error.value = null;
      final session = OdooSession(
        serverUrl: url.text.trim().replaceAll(RegExp(r'/+$'), ''),
        db: db.text.trim(),
        username: username.text.trim(),
        apiKey: apiKey.text.trim(),
      );
      try {
        final client = OdooClient(
          baseUrl: session.serverUrl,
          db: session.db,
          username: session.username,
          apiKey: session.apiKey,
        );
        await client.authenticate();
        await ref.read(sessionRepositoryProvider).save(session);
        ref.invalidate(sessionProvider);
        if (context.mounted) {
          AutoRouter.of(context).replaceAll([const PickingsRoute()]);
        }
      } on OdooAuthException catch (e) {
        error.value = e.message;
      } catch (e) {
        error.value = 'Could not reach the server: $e';
      } finally {
        busy.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Odoo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Server URL',
              hintText: 'https://odoo.example.com',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: db,
            decoration: const InputDecoration(labelText: 'Database'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: username,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Login (email)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: apiKey,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'API key',
              helperText: 'Odoo → Preferences → Account Security → API Keys',
            ),
          ),
          const SizedBox(height: 24),
          if (error.value != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                error.value!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          FilledButton(
            onPressed: busy.value ? null : connect,
            child: busy.value
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
