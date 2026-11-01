import dotenv from 'dotenv';
dotenv.config();

export const ENV = {
  NODE_ENV:  process.env.NODE_ENV  || 'development',
  PORT:      Number(process.env.PORT) || 3000,
  IS_PROD:   process.env.NODE_ENV === 'production',

  DB: {
    HOST:     process.env.DB_HOST     || 'localhost',
    PORT:     Number(process.env.DB_PORT) || 5432,
    NAME:     process.env.DB_NAME     || 'multitenantsaas',
    USER:     process.env.DB_USER     || 'postgres',
    PASSWORD: process.env.DB_PASSWORD || '',
  },

  JWT: {
    SECRET:          process.env.JWT_SECRET          || '',
    EXPIRES_IN:      process.env.JWT_EXPIRES_IN      || '15m',
    REFRESH_SECRET:  process.env.JWT_REFRESH_SECRET  || '',
    REFRESH_EXPIRES: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },

  CORS_ORIGIN: process.env.CORS_ORIGIN || 'http://localhost:5173',
};