import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Connection? _connection;
  final String _salt = 'NEON_CYBER_SALT_2077';

  // Credentials
  final String _host = 'ep-holy-violet-agv7k5cl-pooler.c-2.eu-central-1.aws.neon.tech';
  final String _database = 'neondb';
  final String _user = 'neondb_owner';
  final String _pass = 'npg_xm9Q4kjOBXGR';

  Future<void> init() async {
    try {
      if (_connection != null && _connection!.isOpen) return;

      print('Connecting to Glitch DB...');
      _connection = await Connection.open(
        Endpoint(
          host: _host,
          database: _database,
          username: _user,
          password: _pass,
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.require,
        ),
      );
      print('Connected to Glitch DB.');

      await _ensureSchema();
    } catch (e) {
      print('Database Init Error: $e');
      rethrow;
    }
  }

  Future<void> _ensureSchema() async {
    // Check if table exists
    // We cannot easily check specific columns in standard SQL without querying information_schema,
    // but we can try to add the column and ignore error or check information_schema.

    // Create table if not exists
    const createTableSql = '''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email TEXT UNIQUE,
        password_hash TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      );
    ''';
    await _connection!.execute(createTableSql);

    // Ensure full_name exists.
    // If it was created by previous run without full_name, we add it.
    try {
      await _connection!.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name TEXT;');
    } catch (e) {
      // Postgres < 9.6 doesn't support IF NOT EXISTS for column. Neon is likely modern (v14/15/16).
      // If it fails, it might mean column exists or other error.
      // We'll check via information_schema to be safe if catch block is triggered.
      print('Migration note: $e');
    }

    print('Schema ensured.');
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password + _salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signUp(String fullName, String email, String password) async {
    await init();
    try {
      final hashedPassword = _hashPassword(password);
      await _connection!.execute(
        Sql.named('INSERT INTO users (full_name, email, password_hash) VALUES (@name, @email, @pass)'),
        parameters: {
          'name': fullName,
          'email': email,
          'pass': hashedPassword,
        },
      );
    } catch (e) {
      print('SignUp Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    await init();
    try {
      final hashedPassword = _hashPassword(password);
      // Fetch full_name as well
      final result = await _connection!.execute(
        Sql.named('SELECT id, full_name, email FROM users WHERE email = @email AND password_hash = @pass'),
        parameters: {
          'email': email,
          'pass': hashedPassword,
        },
      );

      if (result.isEmpty) return null;

      final row = result.first;
      return {
        'id': row[0],
        'full_name': row[1],
        'email': row[2],
      };
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    await init();
    try {
      // Ensure we only select columns that exist
      final result = await _connection!.execute('SELECT id, full_name, email, created_at FROM users ORDER BY created_at DESC');

      return result.map((row) {
        return {
          'id': row[0],
          'full_name': row[1],
          'email': row[2],
          'created_at': row[3].toString(),
        };
      }).toList();
    } catch (e) {
      print('Fetch Users Error: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _connection?.close();
  }
}
