import { Response } from 'express';
import {ApiResponse, Pagination} from '../types/index.js';

// Respuesta exitosa genérica
export const sendSuccess = <T>(
    res: Response,
    data: T,
    message = 'OK',
    statusCode = 200,
    pagination?: Pagination
): Response =>{
    const response: ApiResponse<T> = { success: true, message, data };
    if(pagination) response.pagination = pagination;
    return res.status(statusCode).json(response);
};

// Respuesta de error genérica
export const sendError = (
    res: Response,
    message: string,
     statusCode: number = 500,
    errors?: string[],
): Response => {
    const response: ApiResponse = {success: false, message};
    if(errors) response.errors = errors;
    return res.status(statusCode).json(response);
};

// Atajos para los casos más comunes
export const sendCreated = <T>(res: Response, data: T, message = 'Creado exitosamente') =>
    sendSuccess(res, data, message, 201);

export const sendNotFound = (res: Response, message = 'Recusro no encontrado') =>
    sendError(res, message, 404);

export const sendUnauthorized = (res: Response, message = 'No autorizado') =>
    sendError(res, message, 401);

export const sendForbidden = (res: Response, message = 'Acceso Denegado') =>
    sendError(res, message, 403);

export const sendBadRequest = (res: Response, message: string, errors?: string[]) =>
  sendError(res, message, 400, errors);