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
    if (_connection != null && _connection!.isOpen) return;

    try {
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
    // Create table with ALL columns if it doesn't exist
    const createTableSql = '''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        full_name TEXT,
        email TEXT UNIQUE,
        password_hash TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      );
    ''';
    await _connection!.execute(createTableSql);

    // Migration for existing tables that might miss 'full_name'
    // We try to add it. If it exists, Postgres 9.6+ supports IF NOT EXISTS.
    // If we are on an older version or if there's another issue, we catch it.
    try {
      await _connection!.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name TEXT;');
      print('Migration check passed.');
    } catch (e) {
      // If error is "column already exists" (code 42701), it's fine.
      // But IF NOT EXISTS handles that.
      // If it's another error, print it.
      print('Migration note (ALTER TABLE): $e');
    }
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
