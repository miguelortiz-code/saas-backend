import { Response, NextFunction } from "express";
import jwt from 'jsonwebtoken';
import { ENV } from "../config/env.js";
import { AuthRequest, AuthUser } from "../shared/types/index.js";
import { sendUnauthorized,  sendForbidden } from "../shared/helpers/response.helper.js";

// Verifica que el token JWT sea válido y adjunta el usuario al request
export const authenticate = (
    req: AuthRequest,
    res: Response,
    next: NextFunction
): void => {
  const authHeader = req.headers.authorization;

  // El token debe venir en el header: Authorization: Bearer <token>
  if (!authHeader?.startsWith('Bearer ')) {
    sendUnauthorized(res, 'Token no proporcionado');
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, ENV.JWT.SECRET) as AuthUser;
    req.user       = decoded;
    req.schemaName = decoded.schemaName;
    next();
  } catch {
    sendUnauthorized(res, 'Token inválido o expirado');
  }
};

// Verifica que el usuario tenga el rol requerido para acceder a la ruta
export const authorize = (...roles: string[]) =>
(req: AuthRequest, res: Response, next: NextFunction): void =>{
    if(!req.user) {
        sendUnauthorized(res);
        return;
    }
    if(!roles.includes(req.user.role)){
        sendForbidden(res, 'No tienes permisos para esta acción');
        return;
    }
    next();
};