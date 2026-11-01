import { Request } from "express";
import {PaginationParams, Pagination} from '../types/index.js';

// Extrae y valida los parámetros de paginación del query string
// Ejemplo: GET /products?page=2&limit=20
export const getPaginationParams = (req: Request): PaginationParams => {
    const page  = Math.max(1, Number(req.query['page']) || 1);
    const limit = Math.min(100, Math.max(1, Number(req.query['limit']) || 20));
    const offset = (page - 1) * limit;
    return {page, limit, offset};
};

// Construye el objeto de paginación para incluir en la respuesta
export const buildPagination = (
    page: number,
    limit: number,
    total: number,
): Pagination => ({
    page,
    limit,
    total,
    totalPages: Math.ceil(total/limit),
});