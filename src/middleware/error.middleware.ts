import { Request, Response, NextFunction } from 'express';
import { ENV } from '../config/env.js';
import logger from '../config/logger.js';
import { sendError } from '../shared/helpers/response.helper.js';

// Clase personalizada para lanzar errores con código HTTP desde cualquier parte
export class AppError extends Error {
  statusCode: number;
  constructor(message: string, statusCode = 500) {
    super(message);
    this.statusCode = statusCode;
    Error.captureStackTrace(this, this.constructor);
  }
}

// Captura todos los errores del servidor y responde de forma estándar
export const errorHandler = (
  err: AppError | Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  const statusCode = (err as AppError).statusCode || 500;
  const message    = err.message || 'Error interno del servidor';

  logger.error(`[${req.method}] ${req.path} → ${statusCode}: ${message}`);

  if (!ENV.IS_PROD) console.error(err.stack);

  sendError(res, message, statusCode);
};

// Responde cuando el usuario llama a una ruta que no existe
export const notFoundHandler = (req: Request, res: Response): void => {
  sendError(res, `Ruta no encontrada: ${req.method} ${req.path}`, 404);
};