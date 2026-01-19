import { Pool } from '@neondatabase/serverless';

const connectionString = 'postgresql://neondb_owner:npg_xm9Q4kjOBXGR@ep-holy-violet-agv7k5cl-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require';

const pool = new Pool({ connectionString });

export const checkCredentials = async (email: string, pass: string): Promise<boolean> => {
  try {
    // In a production environment, never store passwords in plain text.
    // This is a demonstration based on the provided task.
    const { rows } = await pool.query('SELECT * FROM users WHERE email = $1 AND password = $2', [email, pass]);
    return rows.length > 0;
  } catch (error) {
    console.error('Database login error:', error);
    return false;
  }
};
