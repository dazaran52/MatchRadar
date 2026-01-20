import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Connection? _connection;
  final String _salt = 'NEON_CYBER_SALT_2077';

  Future<void> init() async {
    if (_connection != null && _connection!.isOpen) return;

    try {
      print('Connecting to Glitch DB...');

      // Load from env
      final host = dotenv.env['DB_HOST'];
      final database = dotenv.env['DB_NAME'];
      final user = dotenv.env['DB_USER'];
      final pass = dotenv.env['DB_PASS'];

      if (host == null || database == null || user == null || pass == null) {
        throw Exception('Database configuration missing in .env');
      }

      _connection = await Connection.open(
        Endpoint(
          host: host,
          database: database,
          username: user,
          password: pass,
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.require,
        ),
      );
      print('Connected to Glitch DB ($database).');

      await _ensureSchema();
    } catch (e) {
      print('Database Init Error: $e');
      // For prototype, we might want to fail gracefully or show UI error
      rethrow;
    }
  }

  Future<void> _ensureSchema() async {
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

    try {
      await _connection!.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name TEXT;');
    } catch (e) {
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
