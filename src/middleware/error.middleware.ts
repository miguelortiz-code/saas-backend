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
  // Los AppError traen mensajes pensados para el cliente.
  // Los demás errores (PostgreSQL, bcrypt, etc.) pueden revelar schemas o tablas,
  // así que en producción se reemplazan por un mensaje genérico.
  const message = err instanceof AppError || !ENV.IS_PROD
    ? err.message || 'Error interno del servidor'
    : statusCode >= 500 ? 'Error interno del servidor' : 'Solicitud inválida';

// El log siempre guarda el error real, aunque el cliente vea el genérico
logger.error(`[${req.method}] ${req.path} → ${statusCode}: ${err.message}`);

  if (!ENV.IS_PROD) console.error(err.stack);

  sendError(res, message, statusCode);
};

// Responde cuando el usuario llama a una ruta que no existe
export const notFoundHandler = (req: Request, res: Response): void => {
  sendError(res, `Ruta no encontrada: ${req.method} ${req.path}`, 404);
};