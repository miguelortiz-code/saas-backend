import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import { ENV } from './config/env.js';
import logger from './config/logger.js';
import pool from './config/database.js';
import routes from './modules/index.js';
import { errorHandler, notFoundHandler } from './middleware/error.middleware.js';

const app = express();

// ── Seguridad ────────────────────────────────────────────────
app.use(helmet());
app.use(cors({ origin: ENV.CORS_ORIGIN, credentials: true }));

// Rate limiting global
app.use(rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutos
  max: 100,
  message: 'Demasiadas solicitudes, intenta de nuevo en 15 minutos',
}));

// ── Parsers ──────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Logging HTTP ─────────────────────────────────────────────
app.use(morgan('dev'));

// ── Health check ─────────────────────────────────────────────
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', env: ENV.NODE_ENV, timestamp: new Date().toISOString() });
});

// ── Rutas ────────────────────────────────────────────────────
app.use('/api/v1', routes);

// ── Errores ──────────────────────────────────────────────────
app.use(notFoundHandler);
app.use(errorHandler);

// ── Arranque ─────────────────────────────────────────────────
const start = async () => {
  try {
    await pool.query('SELECT 1');  // verifica conexión a BD
    logger.info('✅ Conexión a PostgreSQL establecida');

    app.listen(ENV.PORT, () => {
      logger.info(`🚀 Servidor corriendo en http://localhost:${ENV.PORT}`);
      logger.info(`   Entorno: ${ENV.NODE_ENV}`);
    });
  } catch (err) {
    logger.error('❌ Error al conectar con PostgreSQL:', err);
    process.exit(1);
  }
};

start();

export default app;