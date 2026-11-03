import dotenv from 'dotenv';
dotenv.config();

// Si falta una variable obligatoria, el servidor no arranca y dice cuál falta
const required = (name: string): string => {
  const value =  process.env[name];
  if(!value){
    throw new Error(`Falta la variable de entorno ${name} en el archivo .env`);
  }
  return value;
};



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
    SECRET:          required('JWT_SECRET'),
    EXPIRES_IN:      process.env.JWT_EXPIRES_IN      || '15m',
    REFRESH_SECRET:  required('JWT_REFRESH_SECRET'),
    REFRESH_EXPIRES: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },

  CORS_ORIGIN: process.env.CORS_ORIGIN || 'http://localhost:5173',
};