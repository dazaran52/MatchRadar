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
  final String _salt = 'NEON_CYBER_SALT_2077'; // In prod, manage this securely

  // Credentials
  final String _host = 'ep-holy-violet-agv7k5cl-pooler.c-2.eu-central-1.aws.neon.tech';
  final String _database = 'neondb';
  final String _user = 'neondb_owner';
  final String _pass = 'npg_xm9Q4kjOBXGR';

  Future<void> init() async {
    try {
      if (_connection != null && _connection!.isOpen) return;

      print('Connecting to Neon DB...');
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
      print('Connected to Neon DB.');

      await _createTable();
    } catch (e) {
      print('Database Init Error: $e');
      rethrow;
    }
  }

  Future<void> _createTable() async {
    const sql = '''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        full_name TEXT,
        email TEXT UNIQUE,
        password_hash TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      );
    ''';
    await _connection!.execute(sql);
    print('Table checked/created.');
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
      // Rethrow to handle in UI (e.g. Unique constraint)
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
      // Depending on postgres package version, row access might differ.
      // v3.1+ typically returns ResultRow which is list-like or map-like if mapped.
      // Here assuming column index or using toMap if available.
      // Safest is usually index if we know the query order.
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
